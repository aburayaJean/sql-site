---
title: "A ordem em que o SQL Server lê a sua query (não é a ordem em que você escreve)"
description: "FROM, WHERE, GROUP BY, HAVING, SELECT, ORDER BY: entenda a ordem lógica de processamento e por que o alias do SELECT não funciona no WHERE."
date: 2026-09-22T08:07:00-04:00
weight: 7
roadmap: "ordem-logica"
tags: ["fundamentos", "iniciante", "select"]
---

Se você só puder ler um post dos Fundamentos, leia este. Ele explica uma dúvida que todo mundo tem quando começa (e que muita gente experiente nunca entendeu direito):

> "Por que eu não posso usar no WHERE o apelido que eu criei no SELECT?"

## Você escreve numa ordem, o banco lê em outra

A gente escreve uma query assim:

```sql
SELECT   ...
FROM     ...
WHERE    ...
GROUP BY ...
HAVING   ...
ORDER BY ...
```

Mas o SQL Server **processa** as cláusulas nesta ordem:

| Ordem | Cláusula | O que acontece |
|---|---|---|
| 1 | `FROM` (e os `JOIN`s) | Monta o conjunto de linhas de onde tudo vai sair |
| 2 | `WHERE` | Filtra as linhas, uma a uma |
| 3 | `GROUP BY` | Junta as linhas que sobraram em grupos |
| 4 | `HAVING` | Filtra os **grupos** |
| 5 | `SELECT` | Calcula as colunas e expressões e dá os apelidos (aliases) |
| 6 | `DISTINCT` | Remove as linhas repetidas |
| 7 | `ORDER BY` | Ordena o resultado |
| 8 | `TOP` / `OFFSET-FETCH` | Corta o resultado |

Cada etapa recebe o resultado da anterior. Leia a tabela de novo com calma, porque dela sai tudo o que vem a seguir.

## O que isso explica

**O alias não funciona no WHERE.** O `WHERE` é a etapa 2, e o apelido só nasce na etapa 5. Quando o `WHERE` roda, o apelido ainda não existe.

**O alias funciona no ORDER BY.** O `ORDER BY` é a etapa 7, depois do `SELECT`. O apelido já existe.

**O WHERE não aceita COUNT, SUM etc.** Funções de agregação trabalham sobre grupos, e os grupos só existem a partir da etapa 3. Para filtrar por um total, o lugar é o `HAVING`.

**Um alias não pode ser usado no mesmo SELECT onde foi criado.** Todas as expressões do `SELECT` são calculadas "ao mesmo tempo". Não dá para criar `PrecoComDesconto` e usar `PrecoComDesconto * 2` na coluna seguinte.

**Alias de tabela funciona em todo lugar.** Já o apelido de **tabela** (`FROM dbo.Pedidos AS p`) nasce na etapa 1, então `p.Status` funciona no `WHERE`, no `GROUP BY` e em qualquer outra cláusula.

{{< callout type="info" >}}
**Ordem lógica não é ordem física.** Esta é a ordem em que o SQL Server **interpreta** a query. Na hora de executar, o otimizador pode fazer as coisas em outra ordem, como aplicar um filtro antes de um JOIN, desde que o resultado seja o mesmo. Isso é assunto da trilha de planos de execução.
{{< /callout >}}

## Bora pra prática

Vamos provocar os erros de propósito e depois consertar. Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### A query de referência

Total de cada pedido, só para pedidos acima de R$ 1.000, do maior para o menor:

```sql
USE Loja;

SELECT   PedidoId,
         SUM(Quantidade * PrecoUnitario) AS Total
FROM     dbo.ItensPedido
GROUP BY PedidoId
HAVING   SUM(Quantidade * PrecoUnitario) > 1000
ORDER BY Total DESC;
```

Seis pedidos aparecem. Repare que no `HAVING` a gente teve que repetir a conta inteira, mas no `ORDER BY` o apelido `Total` funcionou.

### Erro 1: alias no WHERE

```sql
SELECT Nome,
       Preco * 0.9 AS PrecoComDesconto
FROM   dbo.Produtos
WHERE  PrecoComDesconto > 1000;
```

Erro 207: *Invalid column name 'PrecoComDesconto'*. No `WHERE` (etapa 2), o apelido ainda não existe.

**Conserto 1:** repetir a expressão.

```sql
SELECT Nome,
       Preco * 0.9 AS PrecoComDesconto
FROM   dbo.Produtos
WHERE  Preco * 0.9 > 1000;
```

**Conserto 2:** calcular primeiro numa CTE (uma consulta nomeada, que tem post próprio) e filtrar depois. Assim o apelido já existe quando o `WHERE` de fora roda.

```sql
WITH ProdutosComDesconto AS (
    SELECT Nome,
           Preco * 0.9 AS PrecoComDesconto
    FROM   dbo.Produtos
)
SELECT Nome, PrecoComDesconto
FROM   ProdutosComDesconto
WHERE  PrecoComDesconto > 1000;
```

### Erro 2: agregação no WHERE

```sql
SELECT   PedidoId,
         SUM(Quantidade * PrecoUnitario) AS Total
FROM     dbo.ItensPedido
WHERE    SUM(Quantidade * PrecoUnitario) > 1000
GROUP BY PedidoId;
```

Erro 147: o SQL Server avisa que um agregado não pode aparecer no `WHERE`, só no `HAVING`. Faz sentido: na etapa 2 ainda não existem grupos para somar.

### Erro 3: alias no mesmo SELECT

```sql
SELECT Nome,
       Preco * 0.9              AS PrecoComDesconto,
       PrecoComDesconto * 2     AS Dobro
FROM   dbo.Produtos;
```

Erro 207 de novo. As colunas do `SELECT` são calculadas juntas, e uma não enxerga o apelido da outra.

### Acerto: alias no ORDER BY

```sql
SELECT   Nome AS Produto,
         Preco
FROM     dbo.Produtos
ORDER BY Produto;
```

Funciona, porque o `ORDER BY` vem depois do `SELECT`.

### Para fixar

Antes de ler a resposta, tente dizer em que etapa cada parte desta query acontece:

```sql
SELECT   TOP (2)
         Status,
         COUNT(*) AS Quantidade
FROM     dbo.Pedidos
WHERE    DataPedido >= '2026-03-01'
GROUP BY Status
HAVING   COUNT(*) >= 2
ORDER BY Quantidade DESC;
```

<details>
<summary>Ver a ordem</summary>

1. `FROM dbo.Pedidos`: todos os 12 pedidos.
2. `WHERE DataPedido >= '2026-03-01'`: sobram 8 pedidos, de março em diante.
3. `GROUP BY Status`: Entregue (4), Enviado (2), Pendente (2).
4. `HAVING COUNT(*) >= 2`: os três grupos passam.
5. `SELECT`: calcula `Status` e `COUNT(*)`, e dá o apelido `Quantidade`.
6. `ORDER BY Quantidade DESC`: Entregue fica em primeiro. Enviado e Pendente empatam com 2.
7. `TOP (2)`: fica só com duas linhas.

Na etapa 7, qual dos empatados entra? Não dá para saber: quando há empate no `ORDER BY`, a ordem entre eles não é garantida. Para um resultado previsível, desempate com mais uma coluna, como `ORDER BY Quantidade DESC, Status`.

</details>

