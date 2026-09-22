---
title: "GROUP BY e HAVING"
date: 2026-01-05
weight: 50
tags: ["iniciante", "group-by", "having", "agregação"]
categories: ["Teoria"]
description: "Agrupe dados por categorias e filtre grupos com HAVING."
---

`GROUP BY` divide as linhas em **grupos** e aplica funções de agregação a cada grupo. `HAVING` filtra esses grupos — é o WHERE dos grupos.

## GROUP BY

```sql
SELECT status, COUNT(*) AS qtd
FROM pedidos
GROUP BY status;
```

Resultado:

| status | qtd |
|---|---|
| entregue | 6 |
| pendente | 2 |
| cancelado | 1 |

### Regra de ouro

> Toda coluna no `SELECT` que **não** é função de agregação **deve** aparecer no `GROUP BY`.

```sql
SELECT categoria, COUNT(*) AS qtd, AVG(preco) AS preco_medio
FROM produtos
GROUP BY categoria;  -- categoria está no SELECT e no GROUP BY
```

## HAVING

`WHERE` filtra **linhas** antes da agregação.  
`HAVING` filtra **grupos** depois da agregação.

```sql
-- Apenas categorias com mais de 2 produtos
SELECT categoria, COUNT(*) AS qtd
FROM produtos
GROUP BY categoria
HAVING COUNT(*) > 2;

-- Clientes com total gasto acima de R$ 500
SELECT id_cliente, SUM(total) AS total_gasto
FROM pedidos
GROUP BY id_cliente
HAVING SUM(total) > 500
ORDER BY total_gasto DESC;
```

## WHERE + GROUP BY + HAVING juntos

```sql
SELECT id_cliente, COUNT(*) AS pedidos, SUM(total) AS total
FROM pedidos
WHERE status = 'entregue'      -- 1º: filtra linhas
GROUP BY id_cliente             -- 2º: agrupa
HAVING SUM(total) > 1000       -- 3º: filtra grupos
ORDER BY total DESC;            -- 4º: ordena
```

## Ordem de execução (lógica)

`FROM` → `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY` → `LIMIT`

## Próximo passo

[Módulo 06 — JOINs](/teoria/06-joins/)
