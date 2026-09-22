---
title: "O que é SQL — e o que é T-SQL"
description: "A linguagem que conversa com o banco: de onde veio o SQL, por que ele é declarativo e o que o T-SQL do SQL Server acrescenta."
date: 2026-09-22T08:03:00-04:00
weight: 3
roadmap: "sql-intro"
tags: ["fundamentos", "iniciante", "t-sql"]
---

Já sabemos o que é um banco de dados. Agora vamos falar da língua que a gente usa para conversar com ele: o **SQL**.

## Um pouco de história (bem pouco)

Lembra do Codd, que propôs o modelo relacional em 1970? Faltava uma linguagem para usar aquilo. Em 1974, dois colegas dele na IBM, Donald Chamberlin e Raymond Boyce, criaram a **SEQUEL** (*Structured English Query Language*). Por questão de marca registrada, o nome virou **SQL**, sigla de *Structured Query Language*.

Em 1986 o SQL virou padrão ANSI e, no ano seguinte, ISO. Desde então o padrão é revisado de tempos em tempos (SQL:1999, 2003, 2011, 2016, 2023...), e cada banco implementa um pedaço dele, com extensões próprias.

E a pronúncia? "Ess-quê-éle" ou "síquel", os dois estão certos. Pode escolher e não deixar ninguém te corrigir.

## SQL é declarativo

Essa é a ideia mais importante do post, então vou com calma.

Na maioria das linguagens de programação você diz **como** fazer as coisas: percorre essa lista, testa essa condição, soma nessa variável. O SQL é **declarativo**: você diz **o que** quer, e o banco decide como buscar.

```sql
SELECT Nome, Preco
FROM dbo.Produtos
WHERE Categoria = N'Informática';
```

Você não disse "abra o arquivo, leia linha por linha, compare a categoria". Você descreveu o resultado que quer. Quem decide o caminho é um componente do banco chamado **otimizador de consultas**: ele avalia estatísticas, índices disponíveis e dezenas de alternativas, e escolhe o que acha mais barato. O resultado dessa decisão é o **plano de execução**, assunto de uma trilha inteira aqui no blog.

Essa diferença explica muita coisa. Por que a mesma query roda rápido hoje e lenta amanhã? Porque o otimizador pode ter escolhido outro caminho. Por que criar um índice acelera uma query sem mudar uma vírgula dela? Porque você deu ao otimizador um caminho melhor.

## E o T-SQL?

Cada banco fala SQL com um "sotaque", ou seja, com extensões próprias. O do SQL Server se chama **T-SQL** (*Transact-SQL*), herança da época da parceria com a Sybase. O Oracle tem o PL/SQL, o PostgreSQL tem o PL/pgSQL.

O T-SQL acrescenta ao SQL padrão, principalmente:

- **Programação:** variáveis (`DECLARE`), `IF`, `WHILE`, tratamento de erro com `TRY...CATCH`.
- **Objetos programáveis:** stored procedures, funções e triggers.
- **Funções e sintaxes próprias:** `TOP`, `GETDATE()`, `ISNULL()` e muitas outras.

Na prática, quase todo SQL que você escreve no SQL Server é T-SQL, e não precisa ficar pensando nisso o tempo todo. Mas vale saber a diferença quando você for levar uma query para outro banco, ou ler um material escrito para PostgreSQL e estranhar a sintaxe.

## Bora pra prática

Vamos rodar a mesma pergunta do jeito T-SQL e do jeito padrão ANSI, e depois um pedacinho de T-SQL procedural. Tudo no banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### Os 3 produtos mais caros

```sql
USE Loja;

-- Jeito T-SQL: TOP
SELECT TOP (3) Nome, Preco
FROM dbo.Produtos
ORDER BY Preco DESC;

-- Jeito padrão ANSI: OFFSET / FETCH (o SQL Server também entende)
SELECT Nome, Preco
FROM dbo.Produtos
ORDER BY Preco DESC
OFFSET 0 ROWS FETCH NEXT 3 ROWS ONLY;
```

Mesmo resultado: Notebook, Monitor e Mesa em L. O `TOP` é mais curto; o `OFFSET/FETCH` funciona em outros bancos e serve para paginação.

### Data e hora

```sql
SELECT GETDATE()         AS JeitoTSQL,
       CURRENT_TIMESTAMP AS JeitoANSI;
```

Os dois devolvem a mesma coisa. Se o seu código precisar rodar em mais de um banco, prefira o ANSI.

### Trocar NULL por um texto

```sql
SELECT Nome,
       ISNULL(Email, N'sem e-mail')   AS JeitoTSQL,
       COALESCE(Email, N'sem e-mail') AS JeitoANSI
FROM dbo.Clientes;
```

A Ana e o Rafael não têm e-mail cadastrado, e as duas funções trocam o vazio por "sem e-mail". Elas têm diferenças sutis (de tipo de dado, principalmente), e isso vai ganhar um post só para elas.

### Um pedacinho de T-SQL procedural

```sql
DECLARE @qtdProdutos INT;

SELECT @qtdProdutos = COUNT(*)
FROM dbo.Produtos;

IF @qtdProdutos >= 5
    PRINT N'Catálogo razoável: ' + CAST(@qtdProdutos AS NVARCHAR(10)) + N' produtos.';
ELSE
    PRINT N'Catálogo pequeno ainda.';
```

Olha a aba **Messages** do SSMS: vai aparecer "Catálogo razoável: 8 produtos." Variável, `IF`, `PRINT`: isso é T-SQL puro, não existe no SQL padrão.

{{< callout type="info" >}}
Reparou no `N` antes dos textos, como em `N'sem e-mail'`? Ele diz ao SQL Server que o texto é Unicode (`NVARCHAR`), o que evita problemas com acentos e com conversões de tipo. O post sobre tipos de texto explica isso direitinho.
{{< /callout >}}

