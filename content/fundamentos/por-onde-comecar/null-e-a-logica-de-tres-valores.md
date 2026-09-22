---
title: "NULL não é zero, não é vazio e não é igual a NULL"
description: "O que NULL significa, a lógica de três valores (TRUE, FALSE, UNKNOWN) e as armadilhas que somem com linhas do seu resultado sem aviso."
date: 2026-01-28T08:00:00-04:00
weight: 8
roadmap: "null-logica"
tags: ["fundamentos", "iniciante", "null"]
---

Se existe um assunto que causa bug silencioso em SQL, é o **NULL**. Silencioso porque não dá erro: a query roda, devolve um resultado e o resultado está errado. Vamos entender de uma vez.

## O que é NULL

NULL significa **"valor desconhecido"** ou **"sem valor"**. Não é zero. Não é texto vazio (`''`). Não é espaço em branco. É a **ausência** de valor.

No banco Loja, a Ana não tem e-mail cadastrado. Isso não quer dizer que o e-mail dela é vazio; quer dizer que **a gente não sabe** qual é. Pode ser que ela nem tenha e-mail.

Guarde essa ideia de "não sei", porque ela explica tudo o que vem a seguir.

## A lógica de três valores

Na lógica que você aprendeu na escola, uma comparação é verdadeira ou falsa. No SQL existe um terceiro resultado: **UNKNOWN** (desconhecido).

Qualquer comparação com NULL dá UNKNOWN. Pense no "não sei":

- `NULL = 10`: o valor desconhecido é igual a 10? **Não sei.** UNKNOWN.
- `NULL <> 10`: é diferente de 10? **Não sei.** UNKNOWN.
- `NULL = NULL`: um valor desconhecido é igual a outro valor desconhecido? **Não sei!** UNKNOWN.

E a regra de ouro: **o WHERE só devolve as linhas em que a condição é TRUE.** UNKNOWN não passa, assim como FALSE não passa.

Com `AND`, `OR` e `NOT`, o UNKNOWN se comporta assim:

| Expressão | Resultado |
|---|---|
| `TRUE AND UNKNOWN` | UNKNOWN |
| `FALSE AND UNKNOWN` | FALSE |
| `TRUE OR UNKNOWN` | TRUE |
| `FALSE OR UNKNOWN` | UNKNOWN |
| `NOT UNKNOWN` | UNKNOWN |

Não precisa decorar. Basta trocar UNKNOWN por "não sei" e pensar: "falso E não sei" é falso com certeza; "verdadeiro OU não sei" é verdadeiro com certeza; o resto continua "não sei".

## Como testar NULL

Como `= NULL` nunca é verdadeiro, o SQL tem um operador próprio:

- `IS NULL`
- `IS NOT NULL`

E a partir do SQL Server 2022 existe o `IS [NOT] DISTINCT FROM`, que compara tratando dois NULLs como iguais. Ele ganha post próprio na trilha de SELECT.

## As armadilhas

1. **`WHERE coluna = NULL` nunca traz nada.** Use `IS NULL`.
2. **`WHERE UF <> 'MT'` some com quem tem UF NULL.** Você queria "todo mundo que não é de MT", mas quem não tem UF também não aparece.
3. **`COUNT(coluna)` ignora NULL.** `COUNT(*)` conta linhas; `COUNT(Email)` conta e-mails preenchidos.
4. **`AVG`, `SUM`, `MIN` e `MAX` ignoram NULL.** A média de desconto considera só os pedidos que têm desconto preenchido, e isso pode mudar muito o número.
5. **Conta com NULL vira NULL.** `10 + NULL` é NULL. `'Maria' + NULL` também.
6. **`NOT IN` com NULL na lista não devolve nada.** Essa é a pior, porque parece impossível.
7. **No `GROUP BY`, todos os NULLs caem no mesmo grupo.** E no `ORDER BY` do SQL Server, NULL vem primeiro na ordem crescente.

{{< callout type="warning" >}}
**Curiosidade do SQL Server:** uma constraint `UNIQUE` aceita **um único** NULL na coluna. O padrão SQL (e o PostgreSQL, por exemplo) aceita vários. Se você precisa de "único quando preenchido", a solução no SQL Server é um índice único filtrado, assunto da trilha de índices.
{{< /callout >}}

## Bora pra prática

Vamos provocar cada armadilha no banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql). No banco, a Ana e o Rafael estão sem e-mail, a Fernanda está sem cidade e sem UF, e vários pedidos estão com desconto NULL.

### NULL = NULL

```sql
USE Loja;

SELECT CASE WHEN NULL = NULL THEN N'verdadeiro'
            ELSE N'não é verdadeiro'
       END AS Resultado;
```

"Não é verdadeiro". Nem NULL é igual a NULL.

### Armadilha 1: = NULL vs IS NULL

```sql
-- Zero linhas, sempre
SELECT Nome, Email
FROM   dbo.Clientes
WHERE  Email = NULL;

-- O jeito certo: Ana e Rafael
SELECT Nome, Email
FROM   dbo.Clientes
WHERE  Email IS NULL;
```

### Armadilha 2: o <> que some com linhas

```sql
-- "Clientes que não são de MT": 4 linhas
SELECT Nome, UF
FROM   dbo.Clientes
WHERE  UF <> 'MT';
```

São 8 clientes e 3 são de MT. Deveriam sobrar 5, mas vieram 4: a Fernanda sumiu, porque `NULL <> 'MT'` é UNKNOWN. Se ela deveria aparecer, diga isso explicitamente:

```sql
SELECT Nome, UF
FROM   dbo.Clientes
WHERE  UF <> 'MT'
   OR  UF IS NULL;
```

### Armadilha 3: COUNT(*) vs COUNT(coluna)

```sql
SELECT COUNT(*)      AS TotalClientes,   -- 8
       COUNT(Email)  AS ComEmail,        -- 6
       COUNT(Cidade) AS ComCidade        -- 7
FROM   dbo.Clientes;
```

### Armadilha 4: a média que depende do NULL

```sql
SELECT AVG(Desconto)              AS MediaSoDosPreenchidos,
       AVG(ISNULL(Desconto, 0))   AS MediaDeTodosOsPedidos,
       COUNT(Desconto)            AS PedidosComDesconto,
       COUNT(*)                   AS TotalPedidos
FROM   dbo.Pedidos;
```

Dos 12 pedidos, 4 têm desconto preenchido: 50, 100, 0 e 30. A primeira média é 180 ÷ 4 = **45**. A segunda trata NULL como zero: 180 ÷ 12 = **15**.

Qual está certa? Depende da pergunta. "Quando existe desconto, de quanto ele é em média?" é a primeira. "Quanto de desconto a gente dá por pedido?" é a segunda. O NULL te obriga a pensar qual pergunta você está fazendo. E repare no pedido 7: desconto **zero** é diferente de desconto **NULL**. Zero entra na média; NULL fica de fora.

{{< callout type="info" >}}
Na primeira coluna, o SQL Server mostra na aba Messages o aviso *"Null value is eliminated by an aggregate or other SET operation"*. Ele está te dizendo exatamente isso: ignorei os NULLs.
{{< /callout >}}

### Armadilha 5: conta com NULL

```sql
SELECT Nome,
       Nome + N' - ' + Cidade              AS ComMais,     -- NULL para a Fernanda
       CONCAT(Nome, N' - ', Cidade)        AS ComConcat    -- CONCAT trata NULL como vazio
FROM   dbo.Clientes;
```

### Armadilha 6: NOT IN com NULL

```sql
-- Clientes que não são o 1 nem o 2: 6 linhas
SELECT ClienteId, Nome
FROM   dbo.Clientes
WHERE  ClienteId NOT IN (1, 2);

-- Agora com um NULL na lista: ZERO linhas
SELECT ClienteId, Nome
FROM   dbo.Clientes
WHERE  ClienteId NOT IN (1, 2, NULL);
```

Por quê? `NOT IN (1, 2, NULL)` é o mesmo que `ClienteId <> 1 AND ClienteId <> 2 AND ClienteId <> NULL`. A última parte é sempre UNKNOWN, e "algo AND UNKNOWN" nunca chega a TRUE.

Na vida real ninguém escreve NULL na lista de propósito. O problema aparece com subquery: `WHERE ClienteId NOT IN (SELECT ClienteId FROM OutraTabela)`, e basta **uma** linha NULL na outra tabela para o resultado virar vazio. A solução (`NOT EXISTS`) tem post próprio na trilha de subqueries.

### Armadilha 7: NULL no GROUP BY e no ORDER BY

```sql
SELECT   UF,
         COUNT(*) AS Clientes
FROM     dbo.Clientes
GROUP BY UF
ORDER BY UF;
```

A primeira linha é `NULL` com 1 cliente, a Fernanda: os NULLs formam um grupo e aparecem primeiro na ordenação.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [NULL e UNKNOWN](https://learn.microsoft.com/pt-br/sql/t-sql/language-elements/null-and-unknown-transact-sql)
- [IS [NOT] NULL](https://learn.microsoft.com/pt-br/sql/t-sql/queries/is-null-transact-sql) e [IS [NOT] DISTINCT FROM](https://learn.microsoft.com/pt-br/sql/t-sql/queries/is-distinct-from-transact-sql)
- [SET ANSI_NULLS](https://learn.microsoft.com/pt-br/sql/t-sql/statements/set-ansi-nulls-transact-sql)
- [COUNT](https://learn.microsoft.com/pt-br/sql/t-sql/functions/count-transact-sql) e [AVG](https://learn.microsoft.com/pt-br/sql/t-sql/functions/avg-transact-sql)
- [CONCAT](https://learn.microsoft.com/pt-br/sql/t-sql/functions/concat-transact-sql)
- [Restrições UNIQUE e CHECK](https://learn.microsoft.com/pt-br/sql/relational-databases/tables/unique-constraints-and-check-constraints)
