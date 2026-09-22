---
title: "DDL, DML, DQL, DCL e TCL: as cinco famílias de comandos"
description: "Todo comando SQL pertence a uma família: estrutura, dados, consulta, permissão ou transação. Entenda cada uma e rode um exemplo de todas."
date: 2026-09-22T08:04:00-04:00
weight: 4
roadmap: "sublinguagens"
tags: ["fundamentos", "iniciante"]
---

SQL tem muito comando, mas quase todos cabem em **cinco famílias**. Saber a qual família um comando pertence ajuda a entender o que ele mexe, quem pode rodar e o que acontece se der errado.

## As cinco famílias

### DDL — Data Definition Language

Comandos que mexem na **estrutura**: criam, alteram e apagam objetos como bancos, tabelas, views e índices.

`CREATE`, `ALTER`, `DROP` e `TRUNCATE`.

### DML — Data Manipulation Language

Comandos que mexem nos **dados** que estão dentro das tabelas.

`INSERT`, `UPDATE`, `DELETE` e `MERGE`.

### DQL — Data Query Language

O comando que **consulta** os dados.

`SELECT`.

### DCL — Data Control Language

Comandos que controlam **quem pode fazer o quê**.

`GRANT` (dá permissão), `DENY` (nega explicitamente) e `REVOKE` (retira o que foi dado ou negado).

### TCL — Transaction Control Language

Comandos que controlam **transações**, ou seja, blocos de operações que acontecem inteiros ou não acontecem.

`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK` e `SAVE TRANSACTION`.

## Algumas polêmicas (porque sempre tem)

- **O SELECT é DML ou DQL?** Muita gente, e a própria documentação da Microsoft, coloca o `SELECT` dentro da DML. Separar em DQL é mais didático. Não perca tempo com essa briga.
- **O TRUNCATE parece DML, mas é DDL.** Ele apaga todas as linhas da tabela, igual a um `DELETE` sem `WHERE`, mas por baixo desaloca as páginas de dados em vez de apagar linha por linha, zera o `IDENTITY` e exige permissão de alterar a tabela. Tem um post inteiro sobre `DROP` x `TRUNCATE` x `DELETE` na trilha de DDL.
- **O DENY é coisa do SQL Server.** O padrão SQL só tem `GRANT` e `REVOKE`.

## Por que isso importa no dia a dia

- **Permissão:** poder ler (`SELECT`) é uma coisa, poder alterar dados é outra, poder alterar estrutura é outra bem mais séria. Em produção, a maioria dos usuários deveria ter só DQL e DML, e olhe lá.
- **Risco:** um `UPDATE` errado estraga dados. Um `DROP` errado some com a tabela inteira. Saber a família te lembra do tamanho do estrago possível.
- **Transação:** você pode abrir uma transação, rodar o seu `UPDATE`, conferir e só então decidir entre `COMMIT` e `ROLLBACK`. É o cinto de segurança de quem mexe em produção.

## Bora pra prática

Vamos rodar um comando de cada família no banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql). Execute um bloco de cada vez e olhe o resultado antes de ir para o próximo.

### DDL: criar e alterar uma tabela

```sql
USE Loja;

CREATE TABLE dbo.Fornecedores (
    FornecedorId INT           IDENTITY(1,1) CONSTRAINT PK_Fornecedores PRIMARY KEY,
    Nome         NVARCHAR(100) NOT NULL
);

-- Esquecemos o CNPJ. ALTER TABLE resolve:
ALTER TABLE dbo.Fornecedores ADD CNPJ CHAR(14) NULL;
```

### DML: inserir, alterar e apagar

```sql
INSERT INTO dbo.Fornecedores (Nome, CNPJ) VALUES
    (N'Tech Distribuidora',  '11222333000144'),
    (N'Móveis Centro-Oeste', '55666777000188'),
    (N'Fornecedor Teste',    NULL);

UPDATE dbo.Fornecedores
SET    CNPJ = '99888777000166'
WHERE  Nome = N'Fornecedor Teste';

DELETE FROM dbo.Fornecedores
WHERE  Nome = N'Fornecedor Teste';
```

### DQL: consultar

```sql
SELECT FornecedorId, Nome, CNPJ
FROM   dbo.Fornecedores;
```

Duas linhas: a Tech Distribuidora e a Móveis Centro-Oeste.

### DCL: dar permissão e testar

Vamos criar um usuário que **só pode ler** e testar com ele. O `EXECUTE AS` faz o SQL Server fingir que você é aquele usuário até o `REVERT`.

```sql
-- Usuário sem login, só para teste
CREATE USER LeitorLoja WITHOUT LOGIN;

GRANT SELECT ON SCHEMA::dbo TO LeitorLoja;

EXECUTE AS USER = 'LeitorLoja';

    SELECT Nome FROM dbo.Fornecedores;   -- funciona

    DELETE FROM dbo.Fornecedores;        -- erro 229: permissão negada

REVERT;
```

O `SELECT` funciona, e o `DELETE` falha com o erro 229, *"The DELETE permission was denied..."*. É exatamente isso que você quer para um usuário de relatório.

### TCL: a transação como cinto de segurança

```sql
BEGIN TRANSACTION;

    DELETE FROM dbo.Fornecedores;   -- apagou tudo!

    SELECT COUNT(*) AS DentroDaTransacao
    FROM   dbo.Fornecedores;        -- 0

ROLLBACK TRANSACTION;

SELECT COUNT(*) AS DepoisDoRollback
FROM   dbo.Fornecedores;            -- 2 de novo
```

Dentro da transação as linhas sumiram. O `ROLLBACK` desfez tudo e elas voltaram. Se fosse `COMMIT`, o `DELETE` estaria confirmado para sempre.

{{< callout type="warning" >}}
Uma transação aberta segura bloqueios nas linhas que ela mexeu. Se você der `BEGIN TRANSACTION` e esquecer de fechar, outras pessoas podem ficar travadas esperando. Sempre termine com `COMMIT` ou `ROLLBACK`.
{{< /callout >}}

### Limpeza

```sql
DROP USER LeitorLoja;          -- DDL: remove o usuário
DROP TABLE dbo.Fornecedores;   -- DDL: some a tabela inteira
```

Pronto: você acabou de usar as cinco famílias de comandos SQL.

