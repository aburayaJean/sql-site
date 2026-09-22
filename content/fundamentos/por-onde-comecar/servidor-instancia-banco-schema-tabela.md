---
title: "Servidor, instância, banco, schema e tabela: quem mora dentro de quem"
description: "A hierarquia de objetos do SQL Server explicada com uma analogia simples, o nome de quatro partes e por que você deve sempre escrever o schema."
date: 2026-09-22T08:05:00-04:00
weight: 5
roadmap: "instancia-banco"
tags: ["fundamentos", "iniciante"]
---

"Qual servidor?" "Qual instância?" "Qual banco?" "Tá no dbo?" Se essas perguntas ainda te confundem, este post resolve. A hierarquia do SQL Server é simples depois que você enxerga.

## A analogia do condomínio

- **Servidor** é o terreno: a máquina (física, virtual ou container) onde tudo roda.
- **Instância** é o prédio: uma instalação do SQL Server, com seus próprios serviços, memória, configurações e logins. Um terreno pode ter mais de um prédio.
- **Banco de dados** é o apartamento: cada prédio tem vários, e cada um tem seus próprios arquivos, usuários e backup.
- **Schema** é o cômodo: uma divisão lógica dentro do apartamento, para organizar as coisas.
- **Tabela** (e view, procedure, função...) é o móvel: onde o dado realmente fica.

## Instância

Quando você instala o SQL Server, está criando uma **instância**. Numa mesma máquina podem existir várias:

- **Instância padrão (default):** só uma por máquina. Você conecta usando só o nome do servidor, como `SRVBANCO`. O nome interno dela é `MSSQLSERVER`.
- **Instâncias nomeadas:** quantas você quiser. Você conecta com `SERVIDOR\NOME`, como `SRVBANCO\VENDAS`.

Cada instância é independente: tem memória, configuração, logins e bancos próprios. É comum ter uma instância de desenvolvimento e outra de homologação na mesma máquina, por exemplo.

## Banco de dados

Dentro da instância ficam os bancos. Todo SQL Server já vem com os **bancos de sistema**:

- **master:** o cérebro da instância. Guarda logins, configurações e a lista de todos os bancos.
- **model:** o molde. Todo banco novo nasce como uma cópia dele.
- **msdb:** a memória do SQL Server Agent: jobs, histórico de backup, alertas.
- **tempdb:** o rascunho de todo mundo. Tabelas temporárias, ordenações grandes... e ele é recriado do zero toda vez que a instância reinicia.

E os **bancos de usuário**, que são os seus: como o **Loja** que a gente criou.

## Schema

Schema é uma pasta lógica dentro do banco. Serve para organizar objetos por assunto (`vendas`, `financeiro`, `rh`) e para dar permissão de uma vez para um grupo de tabelas.

Todo banco já vem com o schema **`dbo`** (*database owner*), que é o padrão. Se você cria uma tabela sem dizer o schema, normalmente ela vai para o `dbo`.

## O nome de quatro partes

Juntando tudo, todo objeto tem um "endereço completo":

```text
servidor.banco.schema.objeto
```

| Como você escreve | O que o SQL Server entende |
|---|---|
| `Clientes` | Tabela Clientes, no schema padrão do seu usuário, no banco atual |
| `dbo.Clientes` | Tabela Clientes, schema dbo, no banco atual |
| `Loja.dbo.Clientes` | Tabela Clientes, schema dbo, banco Loja (de qualquer banco onde você estiver) |
| `SRV2.Loja.dbo.Clientes` | A mesma coisa, só que em outro servidor, via *linked server* |

{{< callout type="info" >}}
**Sempre escreva pelo menos o schema:** `dbo.Clientes`, e não só `Clientes`. Sem o schema, o SQL Server precisa descobrir onde o objeto está (primeiro no schema padrão do usuário, depois no `dbo`), o que pode trazer a tabela errada se existirem duas com o mesmo nome e atrapalha o reaproveitamento de planos de execução. É um hábito de três caracteres que evita dor de cabeça.
{{< /callout >}}

## Bora pra prática

Vamos andar pela hierarquia: descobrir onde você está, listar bancos, criar um schema novo e usar nomes de uma, duas e três partes. Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### Onde eu estou?

```sql
SELECT @@SERVERNAME  AS Servidor,
       @@SERVICENAME AS Instancia,   -- MSSQLSERVER = instância padrão
       DB_NAME()     AS BancoAtual;
```

### Quais bancos existem nesta instância?

```sql
SELECT database_id, name, create_date
FROM   sys.databases
ORDER  BY database_id;
```

Os quatro primeiros (IDs 1 a 4) são os bancos de sistema: master, tempdb, model e msdb. Depois vêm os seus, incluindo o Loja.

### Quais schemas e tabelas existem no Loja?

```sql
USE Loja;

SELECT s.name AS SchemaNome,
       t.name AS Tabela
FROM   sys.tables  AS t
JOIN   sys.schemas AS s ON s.schema_id = t.schema_id
ORDER  BY SchemaNome, Tabela;
```

As quatro tabelas estão no `dbo`.

### Criar um schema e uma tabela dentro dele

```sql
CREATE SCHEMA financeiro;
GO

CREATE TABLE financeiro.Pagamentos (
    PagamentoId INT           IDENTITY(1,1) CONSTRAINT PK_Pagamentos PRIMARY KEY,
    PedidoId    INT           NOT NULL,
    Valor       DECIMAL(10,2) NOT NULL,
    Forma       NVARCHAR(20)  NOT NULL
);

INSERT INTO financeiro.Pagamentos (PedidoId, Valor, Forma)
VALUES (1, 4389.80, N'Pix');
```

O `GO` depois do `CREATE SCHEMA` não é enfeite: esse comando precisa ser o único do seu lote (*batch*). Vamos entender o `GO` direitinho no próximo post.

### Nomes de uma, duas e três partes

```sql
-- Duas partes: schema + tabela (o jeito recomendado)
SELECT * FROM financeiro.Pagamentos;

-- Três partes: funciona mesmo estando em outro banco
USE master;
SELECT * FROM Loja.financeiro.Pagamentos;

-- Uma parte: procura no schema padrão do usuário (normalmente dbo)
USE Loja;
SELECT * FROM Pagamentos;   -- erro 208: Invalid object name
```

O último falha: a tabela está em `financeiro`, e o SQL Server procurou em `dbo`. É o exemplo perfeito de por que o schema deve estar sempre no nome.

### Limpeza

```sql
DROP TABLE financeiro.Pagamentos;
DROP SCHEMA financeiro;
```

