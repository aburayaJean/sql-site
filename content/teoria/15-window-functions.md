---
title: "Window Functions (Funções de Janela)"
date: 2026-01-15
weight: 150
tags: ["avançado", "window-functions", "rank", "lag", "lead"]
categories: ["Teoria"]
description: "ROW_NUMBER, RANK, LAG, LEAD, SUM acumulado — análises avançadas sem perder o detalhe das linhas."
---

Window functions calculam um valor para cada linha **baseado em um conjunto de linhas relacionadas** (a "janela") — sem colapsar o resultado como `GROUP BY` faz.

## Sintaxe

```sql
FUNÇÃO() OVER (
    PARTITION BY coluna   -- divide em grupos (opcional)
    ORDER BY coluna       -- define ordem dentro do grupo
    ROWS BETWEEN ...      -- define o tamanho da janela (opcional)
)
```

## Funções de numeração

```sql
SELECT nome, preco,
    ROW_NUMBER()  OVER (ORDER BY preco DESC) AS linha,
    RANK()        OVER (ORDER BY preco DESC) AS rank,      -- pula números em empate
    DENSE_RANK()  OVER (ORDER BY preco DESC) AS dense_rank -- não pula
FROM produtos;
```

## SUM acumulado (Running Total)

```sql
SELECT data_pedido, total,
    SUM(total) OVER (
        ORDER BY data_pedido
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado
FROM pedidos WHERE status = 'entregue';
```

## Média móvel (3 períodos)

```sql
SELECT data_pedido, total,
    ROUND(AVG(total) OVER (
        ORDER BY data_pedido
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS media_movel_3
FROM pedidos WHERE status = 'entregue';
```

## LAG e LEAD — comparar com linha adjacente

```sql
SELECT data_pedido, total,
    LAG(total,  1) OVER (ORDER BY data_pedido) AS anterior,
    LEAD(total, 1) OVER (ORDER BY data_pedido) AS proximo,
    total - LAG(total, 1, 0) OVER (ORDER BY data_pedido) AS variacao
FROM pedidos WHERE status = 'entregue';
```

## NTILE — dividir em grupos iguais

```sql
SELECT nome, preco,
    NTILE(4) OVER (ORDER BY preco) AS quartil
FROM produtos;
```

## Caso de uso clássico — top 1 por grupo

```sql
SELECT * FROM (
    SELECT c.nome, p.data_pedido, p.total,
        ROW_NUMBER() OVER (
            PARTITION BY p.id_cliente
            ORDER BY p.total DESC
        ) AS rn
    FROM pedidos p
    INNER JOIN clientes c ON c.id = p.id_cliente
    WHERE p.status = 'entregue'
) t
WHERE rn = 1;
```

## Parabéns! 🎉

Você concluiu os 15 módulos do **SQL with Jean**. Baixe todos os scripts na [página de Downloads](/downloads/) e pratique!
