---
title: "Cliente-servidor: o caminho da sua query até o banco"
description: "Conexão, sessão, request e batch: o que acontece entre apertar F5 e ver o resultado, e o que o GO realmente faz."
date: 2026-09-22T08:06:00-04:00
weight: 6
roadmap: "cliente-servidor"
tags: ["fundamentos", "iniciante"]
---

Você aperta F5 no SSMS e o resultado aparece. Mas entre uma coisa e outra acontece bastante coisa, e entender esse caminho explica muitos problemas do dia a dia, de "login failed" até "a query é rápida no SSMS e lenta na aplicação".

## Os dois lados

O SQL Server trabalha no modelo **cliente-servidor**:

- **Servidor:** a instância do SQL Server, rodando como um serviço, esperando pedidos.
- **Cliente:** qualquer programa que conversa com ele. O SSMS é um cliente. Sua aplicação em C#, Java ou Python é um cliente. O Power BI é um cliente. O `sqlcmd` é um cliente.

Eles conversam pela rede usando um protocolo próprio da Microsoft chamado **TDS** (*Tabular Data Stream*), por padrão na **porta TCP 1433**. Mesmo quando o SQL Server está na sua própria máquina, a conversa acontece por esse mesmo protocolo.

Entre a aplicação e a rede fica um **driver** (ODBC, OLE DB, ADO.NET/SqlClient, JDBC...), que sabe falar TDS.

## O caminho, passo a passo

1. **Conexão:** o cliente abre uma conexão de rede com a instância.
2. **Autenticação:** o SQL Server confere quem é você, pelo login do Windows ou por usuário e senha do SQL Server. Se falhar, vem o famoso erro 18456, *Login failed*.
3. **Sessão:** autenticado, você ganha uma **sessão**, identificada por um número: o `session_id`, também chamado de **SPID**. A sessão guarda o seu contexto: em que banco você está, suas configurações `SET`, suas tabelas temporárias.
4. **Batch:** você manda um lote de comandos T-SQL, o **batch**.
5. **Request:** enquanto o batch está executando, existe um **request** ativo na sua sessão. É ele que aparece quando você investiga "o que está rodando agora".
6. **Resultado:** o servidor devolve as linhas pelo mesmo caminho, e o cliente tem que consumir. Se a aplicação lê devagar, o SQL Server fica esperando. Isso tem até nome (o wait `ASYNC_NETWORK_IO`), e a gente vai ver na trilha de performance.

{{< callout type="info" >}}
Abrir conexão é caro. Por isso os drivers usam **connection pooling**: quando a aplicação "fecha" a conexão, o driver guarda ela numa piscina e reaproveita no próximo pedido. É por isso que você pode ver sessões abertas de uma aplicação que, em tese, não está fazendo nada.
{{< /callout >}}

## Batch e o misterioso GO

Um **batch** é um conjunto de comandos que o cliente envia de uma vez para o servidor. O SQL Server compila o batch inteiro e depois executa.

E o `GO`? **O GO não é T-SQL.** O servidor nunca vê um `GO`. Ele é um separador que o SSMS e o `sqlcmd` usam para cortar o seu script em pedaços: tudo antes do `GO` vai num batch, tudo depois vai em outro.

Isso tem consequências práticas:

- **Variáveis morrem no GO.** Uma variável declarada num batch não existe no próximo.
- **Alguns comandos exigem batch próprio.** `CREATE VIEW`, `CREATE PROCEDURE`, `CREATE FUNCTION`, `CREATE TRIGGER` e `CREATE SCHEMA` precisam ser o primeiro (ou o único) comando do batch. Por isso aparecem tanto entre `GO`s nos scripts.
- **Erro de compilação derruba o batch inteiro**, mas não os outros batches do script.
- **Sua aplicação não entende GO.** Se você copiar um script do SSMS com `GO` para dentro do código C#, vai dar erro de sintaxe.

## Bora pra prática

Vamos ver sua sessão por dentro, abrir outra e brincar com o `GO`. Não precisa de nenhuma tabela.

### Quem sou eu?

```sql
SELECT @@SPID AS MinhaSessao;
```

Guarde esse número. Agora veja os detalhes da sua sessão e da sua conexão:

```sql
SELECT session_id,
       login_name,
       host_name,
       program_name,
       login_time,
       status
FROM   sys.dm_exec_sessions
WHERE  session_id = @@SPID;

SELECT session_id,
       net_transport,        -- TCP, Shared memory...
       protocol_type,        -- TSQL = protocolo TDS
       client_net_address,
       local_tcp_port        -- normalmente 1433
FROM   sys.dm_exec_connections
WHERE  session_id = @@SPID;
```

Se você está na mesma máquina do SQL Server, é bem possível que o `net_transport` seja *Shared memory*: um atalho que o SQL Server usa quando cliente e servidor estão no mesmo computador. No Docker, vai aparecer TCP.

### Todas as sessões de usuário

Abra uma **segunda janela de query** no SSMS e rode lá:

```sql
SELECT session_id, login_name, program_name, status
FROM   sys.dm_exec_sessions
WHERE  is_user_process = 1;
```

Cada janela do SSMS é uma sessão diferente, com seu próprio `session_id`. É por isso que uma tabela temporária criada numa janela não aparece na outra.

### O GO na prática

```sql
DECLARE @mensagem NVARCHAR(50) = N'Olá do batch 1';
PRINT @mensagem;
GO

PRINT @mensagem;   -- erro 137: Must declare the scalar variable "@mensagem"
GO
```

O primeiro `PRINT` funciona; o segundo falha, porque a variável morreu junto com o primeiro batch.

E um truque que pouca gente conhece: um número depois do `GO` repete o batch.

```sql
PRINT N'Rodando de novo...';
GO 3
```

Três mensagens na aba Messages. Útil para gerar dados de teste rapidinho.

