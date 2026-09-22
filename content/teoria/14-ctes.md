---
title: "CTEs — Common Table Expressions"
date: 2026-01-14
weight: 140
tags: ["avançado", "cte", "with", "recursivo"]
categories: ["Teoria"]
description: "Escreva queries complexas de forma legível com WITH e CTE RECURSIVE para hierarquias."
---

Uma **CTE** (Common Table Expression) é uma query nomeada definida com `WITH` que existe apenas durante a execução do comando. Deixa o SQL muito mais legível que subqueries aninhadas.

## Sintaxe básica

```sql
WITH nome_cte AS (
    SELECT ...
)
SELECT * FROM nome_cte WHERE ...;
```

## Múltiplas CTEs

```sql
WITH
resumo AS (
    SELECT id_cliente, SUM(total) AS total_gasto
    FROM pedidos
    GROUP BY id_cliente
),
vips AS (
    SELECT id_cliente FROM resumo WHERE total_gasto > 1000
)
SELECT c.nome, r.total_gasto
FROM clientes c
INNER JOIN resumo r ON r.id_cliente = c.id
INNER JOIN vips   v ON v.id_cliente = c.id;
```

## CTE vs Subquery

| | CTE | Subquery |
|---|---|---|
| Legibilidade | ✅ Alta | ❌ Baixa quando aninhada |
| Reutilização | ✅ Sim (mesma query) | ❌ Não |
| Performance | Similar | Similar |

## CTE RECURSIVE — hierarquias e séries

```sql
WITH RECURSIVE contador (n) AS (
    SELECT 1                     -- âncora
    UNION ALL
    SELECT n + 1 FROM contador   -- recursão
    WHERE n < 10
)
SELECT n FROM contador;
```

### Hierarquia de categorias

```sql
WITH RECURSIVE hierarquia AS (
    -- Âncora: nó raiz
    SELECT id, nome, id_pai, 0 AS nivel
    FROM categorias WHERE id_pai IS NULL

    UNION ALL

    -- Recursão: filhos
    SELECT c.id, c.nome, c.id_pai, h.nivel + 1
    FROM categorias c
    INNER JOIN hierarquia h ON h.id = c.id_pai
)
SELECT nivel, nome FROM hierarquia ORDER BY nivel, nome;
```

## Próximo passo

[Módulo 15 — Window Functions](/teoria/15-window-functions/)
