---
title: "Prática 06 — JOINs"
date: 2026-01-06
weight: 60
tags: ["intermediário", "join"]
categories: ["Prática"]
description: "INNER, LEFT, RIGHT e FULL OUTER JOIN em cenários reais."
---

{{< download-script src="/scripts/06-joins.sql" name="06-joins.sql" >}}

## Exercícios

**1.** Liste todos os pedidos com o nome do cliente (INNER JOIN).

**2.** Liste todos os clientes e seus pedidos — inclusive quem nunca comprou (LEFT JOIN).

**3.** Quais clientes nunca fizeram um pedido?

**4.** Para cada cliente, mostre: nome, cidade, total de pedidos e valor total gasto.

**5.** Liste apenas os pedidos entregues com o nome do cliente, ordenados por data decrescente.

## Gabarito

```sql
-- 1. Pedidos com nome do cliente
SELECT p.id, c.nome, p.data_pedido, p.total, p.status
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente
ORDER BY p.data_pedido;

-- 2. Todos os clientes + pedidos
SELECT c.nome, p.id AS pedido, p.total
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id;

-- 3. Nunca compraram
SELECT c.nome FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
WHERE p.id IS NULL;

-- 4. Resumo por cliente
SELECT c.nome, c.cidade,
       COUNT(p.id) AS total_pedidos,
       COALESCE(SUM(p.total), 0) AS valor_total
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
GROUP BY c.id, c.nome, c.cidade
ORDER BY valor_total DESC;

-- 5. Entregues com nome, mais recentes primeiro
SELECT c.nome, p.data_pedido, p.total
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente
WHERE p.status = 'entregue'
ORDER BY p.data_pedido DESC;
```
