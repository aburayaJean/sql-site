---
title: "Prática 05 — GROUP BY e HAVING"
date: 2026-01-05
weight: 50
tags: ["iniciante", "group-by", "having"]
categories: ["Prática"]
description: "Agrupe e filtre grupos em exercícios progressivos."
---

{{< download-script src="/scripts/05-group-by-having.sql" name="05-group-by-having.sql" >}}

## Exercícios

**1.** Quantos pedidos existem por status?

**2.** Qual o total gasto por cada cliente? Ordene do maior para o menor.

**3.** Quantos produtos existem por categoria? Qual o preço médio de cada?

**4.** Quais clientes gastaram mais de R$ 500 no total?

**5.** Quais categorias têm mais de 2 produtos?

**6.** Entre os pedidos entregues, quais clientes gastaram mais de R$ 1.000?

**7.** Quantos pedidos e qual a receita total por mês?

## Gabarito

```sql
-- 1. Pedidos por status
SELECT status, COUNT(*) AS qtd FROM pedidos GROUP BY status;

-- 2. Total por cliente
SELECT id_cliente, SUM(total) AS total_gasto
FROM pedidos GROUP BY id_cliente ORDER BY total_gasto DESC;

-- 3. Produtos por categoria
SELECT categoria, COUNT(*) AS qtd, ROUND(AVG(preco),2) AS preco_medio
FROM produtos GROUP BY categoria;

-- 4. Clientes com total > 500
SELECT id_cliente, SUM(total) AS total
FROM pedidos GROUP BY id_cliente
HAVING SUM(total) > 500;

-- 5. Categorias com mais de 2 produtos
SELECT categoria, COUNT(*) AS qtd
FROM produtos GROUP BY categoria HAVING COUNT(*) > 2;

-- 6. Entregues, total > 1000
SELECT id_cliente, SUM(total) AS total
FROM pedidos WHERE status = 'entregue'
GROUP BY id_cliente HAVING SUM(total) > 1000;

-- 7. Por mês
SELECT EXTRACT(YEAR FROM data_pedido) AS ano,
       EXTRACT(MONTH FROM data_pedido) AS mes,
       COUNT(*) AS pedidos, SUM(total) AS receita
FROM pedidos
GROUP BY EXTRACT(YEAR FROM data_pedido), EXTRACT(MONTH FROM data_pedido)
ORDER BY ano, mes;
```
