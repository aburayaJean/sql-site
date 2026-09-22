---
title: "Conectando no SQL Server: nome do servidor, autenticação e o tal do Trust server certificate"
description: "Cada campo da tela de conexão explicado: como escrever o nome do servidor, Windows vs SQL Server Authentication, criptografia e os erros mais comuns."
date: 2026-02-11T08:00:00-04:00
weight: 5
roadmap: "ssms-intro"
tags: ["fundamentos", "ambiente", "ssms", "conexao"]
---

A tela de conexão parece simples: servidor, usuário, senha, conectar. Mas é ali que acontece metade dos problemas de quem está começando. Vamos passar campo por campo.

## O nome do servidor

O campo **Server name** aceita vários formatos, e cada um quer dizer uma coisa:

| Você escreve | Significa |
|---|---|
| `.` ou `(local)` ou `localhost` | Instância padrão na sua própria máquina |
| `NOTEBOOK01` | Instância padrão no computador NOTEBOOK01 |
| `NOTEBOOK01\SQLEXPRESS` | Instância **nomeada** SQLEXPRESS no NOTEBOOK01 |
| `localhost,1433` | Porta específica. É **vírgula**, não dois-pontos. |
| `tcp:NOTEBOOK01,1433` | Força a conexão por TCP/IP |
| `10.0.0.15,14330` | Por IP e porta, comum com containers e servidores na rede |

**Instância nomeada e o SQL Server Browser.** A instância padrão escuta na porta 1433. As instâncias nomeadas usam uma porta que muda a cada reinício (porta dinâmica). Quem descobre essa porta para você é o serviço **SQL Server Browser**, que responde na porta UDP 1434. Se o Browser estiver parado, a conexão com `SERVIDOR\INSTANCIA` falha, a não ser que você informe a porta direto.

## Autenticação

**Windows Authentication.** Você entra com o seu usuário do Windows (ou do domínio da empresa). O SQL Server confia no Windows e não pede senha. É o modo mais seguro e o recomendado pela Microsoft.

**SQL Server Authentication.** Usuário e senha guardados dentro do próprio SQL Server, como o `sa`. É o que aplicações fora do domínio, containers e servidores Linux costumam usar.

Para aceitar os dois tipos, a instância precisa estar em **Mixed Mode**. Se ela foi instalada só com Windows Authentication, o `sa` existe, mas fica **desabilitado**.

As opções com **Microsoft Entra** (o antigo Azure Active Directory) aparecem na mesma lista e são usadas principalmente no Azure. Vamos falar delas na trilha de nuvem.

## Criptografia e o Trust server certificate

A partir do SSMS 20, a opção **Encryption** vem como **Mandatory** por padrão: a conexão é sempre criptografada, e o SSMS confere se o certificado do servidor é confiável.

Num SQL Server recém-instalado, o certificado é **autoassinado**, gerado pelo próprio SQL Server. O SSMS não confia nele e mostra o erro:

> *The certificate chain was issued by an authority that is not trusted.*

Você tem duas saídas:

- **No laboratório:** marque **Trust server certificate**. A conexão continua criptografada; o SSMS só deixa de conferir quem emitiu o certificado.
- **Em produção:** instale no SQL Server um certificado emitido por uma autoridade que a sua empresa confia. Marcar "confiar em qualquer certificado" abre espaço para alguém no meio do caminho se passar pelo servidor.

Existe ainda o modo **Strict**, que usa o protocolo TDS 8.0 e sempre exige um certificado válido. Criptografia e certificados ganham post próprio na trilha de Segurança.

## Os erros mais comuns

| Erro | O que costuma ser |
|---|---|
| **A network-related or instance-specific error** (error 26, 40...) | O SQL Server não foi encontrado: serviço parado, nome errado, TCP/IP desligado, firewall ou Browser parado |
| **Login failed for user** (erro 18456) | Chegou no servidor, mas usuário, senha ou permissão não batem. Se for login SQL, confira se a instância está em Mixed Mode |
| **The certificate chain was issued by an authority that is not trusted** | Certificado autoassinado com criptografia obrigatória (veja acima) |

## Bora pra prática

### 1. Como está a sua conexão?

Conecte do jeito que você já conecta e rode:

```sql
SELECT session_id,
       net_transport,        -- Shared memory, TCP, Named pipe
       auth_scheme,          -- NTLM, KERBEROS ou SQL
       encrypt_option,       -- TRUE = criptografada
       client_net_address,
       local_tcp_port
FROM   sys.dm_exec_connections
WHERE  session_id = @@SPID;
```

Agora desconecte e conecte de outro jeito. Por exemplo, troque `.` por `tcp:localhost,1433` (se o TCP/IP estiver ligado). Rode de novo e veja o `net_transport` mudar de *Shared memory* para *TCP*.

### 2. A instância aceita login SQL?

```sql
SELECT CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
            WHEN 1 THEN N'Só Windows Authentication'
            ELSE N'Mixed Mode (Windows e SQL Server)'
       END AS ModoDeAutenticacao;
```

Se aparecer "Só Windows", dá para mudar pelo SSMS: botão direito na instância > **Properties** > **Security** > **SQL Server and Windows Authentication mode**. Depois é preciso **reiniciar o serviço**.

### 3. Em que porta o SQL Server está ouvindo?

O SQL Server anota isso no log de erros quando inicia:

```sql
EXEC xp_readerrorlog 0, 1, N'Server is listening on';
```

Aparece uma linha para cada endereço e porta. Se não aparecer nenhuma com porta TCP, o protocolo TCP/IP está desligado.

### 4. Crie um login SQL e teste

```sql
CREATE LOGIN aluno
WITH PASSWORD = N'Aluno@Forte2026',
     CHECK_POLICY = ON;
```

Abra uma **nova conexão** (no Object Explorer, **Connect** > **Database Engine**) com **SQL Server Authentication**, usuário `aluno` e a senha acima. Conectou? Rode:

```sql
SELECT SUSER_SNAME() AS QuemSouEu;

SELECT name FROM sys.databases;
```

O login consegue conectar e listar os bancos, mas tente entrar no Loja (`USE Loja;`) e veja o erro: ter login na **instância** não dá acesso a nenhum **banco**. Essa diferença entre login e usuário tem post próprio na trilha de Segurança.

Para limpar, feche a conexão do `aluno` e, na sua conexão de administrador:

```sql
DROP LOGIN aluno;
```

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Conectar com o SQL Server Management Studio (inclui as mudanças de criptografia)](https://learn.microsoft.com/pt-br/ssms/quickstarts/ssms-connect)
- [Escolher um modo de autenticação](https://learn.microsoft.com/pt-br/sql/relational-databases/security/choose-an-authentication-mode) e [alterar o modo de autenticação](https://learn.microsoft.com/pt-br/sql/database-engine/configure-windows/change-server-authentication-mode)
- [Protocolos de rede e bibliotecas de rede](https://learn.microsoft.com/pt-br/sql/sql-server/install/network-protocols-and-network-libraries)
- [Erro de certificado emitido por autoridade não confiável](https://learn.microsoft.com/pt-br/troubleshoot/sql/database-engine/connect/error-message-when-you-connect)
- [sys.dm_exec_connections](https://learn.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-objects/sys-dm-exec-connections-transact-sql)
- [CREATE LOGIN](https://learn.microsoft.com/pt-br/sql/t-sql/statements/create-login-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem vários roteiros de "não consigo conectar", passo a passo.
- [Dirceu Resende](https://dirceuresende.com/): em português, com artigos sobre autenticação, logins e segurança.
