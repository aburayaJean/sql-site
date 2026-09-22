---
title: "Batches e GO: por que o seu script às vezes quebra no lugar errado"
description: "O que é um batch, o que acontece quando dá erro de compilação ou de execução, os comandos que exigem batch próprio e o que sobrevive ao GO."
date: 2026-02-25T08:00:00-04:00
weight: 11
roadmap: "batch-go"
tags: ["fundamentos", "ambiente", "batch", "go"]
---

No post de [cliente e servidor]({{< relref "/fundamentos/por-onde-comecar/cliente-servidor" >}}) a gente viu que o `GO` não é T-SQL: é só o separador que o SSMS e o sqlcmd usam para cortar o script em **batches**. Agora vamos um passo além, porque entender o batch explica um monte de erro "sem sentido" que aparece em script grande.

## O caminho de um batch

Quando você aperta F5, para **cada** batch acontece isto:

1. O SSMS manda o texto do batch para o servidor.
2. O SQL Server **analisa e compila** o batch inteiro: confere a sintaxe e monta o plano de execução.
3. Só depois ele **executa**, comando por comando.

Esse "compila tudo antes, executa depois" é a chave. Um erro pode acontecer em dois momentos, e o efeito é bem diferente:

| Quando o erro acontece | Exemplo | O que roda |
|---|---|---|
| **Na compilação** | Erro de digitação, coluna que não existe | **Nada** daquele batch. Os outros batches do script rodam normalmente |
| **Na execução** | Divisão por zero, violação de chave | Em geral, só aquele comando falha; o resto do batch continua |

Esse "em geral" é importante: alguns erros de execução derrubam o batch inteiro, e dentro de transação a história muda. O tratamento de erro com `TRY...CATCH` tem post próprio; aqui o objetivo é enxergar o batch.

## Regras que você vai encontrar

- **Alguns comandos precisam ser os primeiros do batch.** `CREATE VIEW`, `CREATE PROCEDURE`, `CREATE FUNCTION`, `CREATE TRIGGER` e `CREATE SCHEMA` não podem vir depois de outro comando no mesmo batch. Por isso os scripts têm tantos `GO`.
- **Variáveis vivem só dentro do batch.** Depois do `GO`, `@variavel` não existe mais.
- **A sessão continua.** Tabelas temporárias (`#tabela`), o banco atual (`USE`), as opções `SET` e as transações abertas pertencem à **sessão**, e passam de um batch para o outro.
- **O `GO` fica sozinho na linha.** Pode ter comentário junto, mas não pode ter comando. E não se coloca ponto e vírgula depois dele: `GO;` dá erro.
- **`GO 5` repete o batch** cinco vezes.
- **A aplicação não entende `GO`.** Ele é coisa das ferramentas. Se o seu código C# ou Python mandar um texto com `GO` para o servidor, dá erro de sintaxe. Na aplicação, cada batch é um comando separado.

## Bora pra prática

Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql). Rode cada bloco **inteiro** (sem selecionar só um pedaço) e olhe a aba **Messages**.

### 1. Erro de compilação: o batch inteiro cai

```sql
PRINT 'Batch 1: antes';
SELEC 1;                 -- faltou o T
PRINT 'Batch 1: depois';
GO
PRINT 'Batch 2: rodou normal';
GO
```

Resultado: só o erro de sintaxe e o "Batch 2: rodou normal". Nem o "antes" aparece, porque o batch 1 nem chegou a executar: morreu na compilação.

### 2. Erro de execução: só o comando cai

```sql
PRINT 'Antes';
SELECT 1/0 AS Divisao;   -- erro 8134, divisão por zero
PRINT 'Depois';
GO
```

Agora aparecem o "Antes", o erro **e** o "Depois". O batch compilou certinho; o erro só aconteceu quando aquele `SELECT` executou, e o SQL Server seguiu para o próximo comando.

### 3. CREATE VIEW precisa de batch próprio

```sql
USE Loja;
CREATE VIEW dbo.vw_ProdutosCaros
AS
SELECT Nome, Preco FROM dbo.Produtos WHERE Preco > 1000;
```

Erro 111: *'CREATE VIEW' must be the first statement in a query batch*. A correção é um `GO` entre os dois:

```sql
USE Loja;
GO
CREATE VIEW dbo.vw_ProdutosCaros
AS
SELECT Nome, Preco FROM dbo.Produtos WHERE Preco > 1000;
GO

SELECT * FROM dbo.vw_ProdutosCaros;

DROP VIEW dbo.vw_ProdutosCaros;
```

### 4. A coluna que "não existe"

Este é o clássico de script de deploy:

```sql
ALTER TABLE dbo.Produtos ADD Estoque INT NULL;
UPDATE dbo.Produtos SET Estoque = 10;
GO
```

Erro 207: *Invalid column name 'Estoque'*. Mas a gente acabou de criar a coluna! Lembra do "compila tudo antes"? Quando o SQL Server compilou o `UPDATE`, o `ALTER TABLE` ainda não tinha rodado, então a coluna não existia. E como foi erro de compilação, **nem o `ALTER TABLE` rodou**. Confira:

```sql
SELECT name FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Produtos');
```

Nada de `Estoque`. Agora com um `GO` separando:

```sql
ALTER TABLE dbo.Produtos ADD Estoque INT NULL;
GO
UPDATE dbo.Produtos SET Estoque = 10;
GO

SELECT Nome, Estoque FROM dbo.Produtos;

ALTER TABLE dbo.Produtos DROP COLUMN Estoque;   -- limpando
```

### 5. O que morre e o que sobrevive ao GO

Rode este bloco:

```sql
DECLARE @Mensagem NVARCHAR(50) = N'Eu sou uma variável';
CREATE TABLE #Temporaria (Id INT);
INSERT INTO #Temporaria (Id) VALUES (1), (2), (3);
GO

SELECT COUNT(*) AS LinhasNaTemporaria FROM #Temporaria;   -- funciona
GO

PRINT @Mensagem;   -- erro 137: Must declare the scalar variable
GO

DROP TABLE #Temporaria;
```

A tabela temporária sobreviveu ao `GO`, porque é da **sessão**. A variável morreu, porque é do **batch**. Repare também que o `PRINT` ficou num batch sozinho: se ele estivesse junto com o `SELECT`, o erro de compilação derrubaria o `SELECT` também.

### 6. Transação atravessa batches

```sql
BEGIN TRANSACTION;
UPDATE dbo.Produtos SET Preco = Preco * 2;
GO

SELECT @@TRANCOUNT AS TransacoesAbertas;   -- 1: continua aberta
GO

ROLLBACK;                                  -- desfaz o aumento de preço
SELECT @@TRANCOUNT AS TransacoesAbertas;   -- 0
```

A transação é da sessão, então o `GO` não fecha nada. Esse é um jeito comum de esquecer uma transação aberta segurando locks. (O SSMS ajuda: por padrão, ele avisa se você tentar fechar a janela com transação aberta.)

### 7. GO com número

```sql
CREATE TABLE #Log (
    Id     INT IDENTITY(1,1),
    Quando DATETIME2(3) DEFAULT SYSDATETIME()
);
GO

INSERT INTO #Log DEFAULT VALUES;
GO 5

SELECT Id, Quando FROM #Log;

DROP TABLE #Log;
```

Cinco linhas. O `GO 5` repetiu o batch do `INSERT` cinco vezes. É muito útil para gerar massa de teste rapidinho.

{{< callout type="info" >}}
**O separador pode mudar.** O `GO` é só o padrão. Em **Tools** > **Options** > **Query Execution** > **SQL Server** > **General**, o campo **Batch separator** aceita outra palavra. Se um dia o `GO` de um colega "parar de funcionar", confira ali.
{{< /callout >}}

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [GO (Transact-SQL)](https://learn.microsoft.com/pt-br/sql/t-sql/language-elements/sql-server-utilities-statements-go)
- [CREATE VIEW: deve ser o primeiro comando do batch](https://learn.microsoft.com/pt-br/sql/t-sql/statements/create-view-transact-sql)
- [Opções de execução de consulta do SSMS (separador de batch)](https://learn.microsoft.com/pt-br/ssms/menu-help/options-query-execution)
- [Comandos do sqlcmd (GO [count])](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-commands)
- [TRY...CATCH](https://learn.microsoft.com/pt-br/sql/t-sql/language-elements/try-catch-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [Erland Sommarskog](https://www.sommarskog.se/): MVP de longa data, tem os textos mais completos que existem sobre tratamento de erro no SQL Server, incluindo quais erros derrubam o comando e quais derrubam o batch.
- [SQLAuthority (Pinal Dave)](https://blog.sqlauthority.com/): várias dicas curtas sobre `GO`, batches e o separador de batch.
