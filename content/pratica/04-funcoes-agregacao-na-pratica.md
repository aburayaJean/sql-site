---
title: "Prática 04 — Funções de Agregação"
date: 2026-01-04
weight: 40
tags: ["iniciante", "agregação"]
categories: ["Prática"]
description: "COUNT, SUM, AVG, MIN e MAX em exercícios do mundo real."
---

{{< download-script src="/scripts/04-agregacao.sql" name="04-agregacao.sql" >}}

## Exercícios

**1.** Quantos clientes estão cadastrados?

**2.** Quantos clientes têm e-mail?

**3.** Qual a receita total de pedidos com status `entregue`?

**4.** Qual o ticket médio de todos os pedidos?

**5.** Qual o produto mais barato e o mais caro?

**6.** Quantos clientes distintos fizeram ao menos um pedido?

**7.** Qual a data do primeiro e do último pedido registrado?

## Gabarito

```sql
-- 1. Total de clientes
SELECT COUNT(*) AS total FROM clientes;

-- 2. Com e-mail
SELECT COUNT(email) AS com_email FROM clientes;

-- 3. Receita entregue
SELECT SUM(total) AS receita
FROM pedidos WHERE status = 'entregue';

-- 4. Ticket médio
SELECT ROUND(AVG(total), 2) AS ticket_medio FROM pedidos;

-- 5. Mais barato / mais caro
SELECT MIN(preco) AS minimo, MAX(preco) AS maximo FROM produtos;

-- 6. Clientes distintos com pedido
SELECT COUNT(DISTINCT id_cliente) AS ativos FROM pedidos;

-- 7. Primeiro e último pedido
SELECT MIN(data_pedido) AS primeiro, MAX(data_pedido) AS ultimo FROM pedidos;
```
