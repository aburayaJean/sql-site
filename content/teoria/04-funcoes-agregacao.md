---
title: "Funções de Agregação"
date: 2026-01-04
weight: 40
tags: ["iniciante", "agregação", "count", "sum", "avg"]
categories: ["Teoria"]
description: "COUNT, SUM, AVG, MIN e MAX — as funções que transformam linhas em resumos."
---

Funções de agregação **resumem um conjunto de linhas em um único valor**. São a base de relatórios e dashboards.

## As cinco principais

| Função | O que faz | Ignora NULL? |
|---|---|---|
| `COUNT(*)` | conta todas as linhas | não |
| `COUNT(col)` | conta linhas onde col não é NULL | sim |
| `SUM(col)` | soma os valores | sim |
| `AVG(col)` | média aritmética | sim |
| `MIN(col)` | menor valor | sim |
| `MAX(col)` | maior valor | sim |

## Exemplos

```sql
-- Quantos clientes temos?
SELECT COUNT(*) AS total FROM clientes;

-- Quantos clientes têm e-mail cadastrado?
SELECT COUNT(email) AS com_email FROM clientes;

-- Receita total de pedidos entregues
SELECT SUM(total) AS receita FROM pedidos WHERE status = 'entregue';

-- Ticket médio (arredondado)
SELECT ROUND(AVG(total), 2) AS ticket_medio FROM pedidos;

-- Produto mais barato e mais caro
SELECT MIN(preco) AS minimo, MAX(preco) AS maximo FROM produtos;
```

## COUNT DISTINCT

```sql
-- Quantos clientes diferentes já fizeram pedido?
SELECT COUNT(DISTINCT id_cliente) AS clientes_ativos FROM pedidos;
```

## COALESCE para evitar NULL no SUM

`SUM` ignora NULL automaticamente, mas se quiser garantir que o resultado não seja NULL quando não há linhas:

```sql
SELECT COALESCE(SUM(total), 0) AS receita_segura FROM pedidos;
```

## Próximo passo

[Módulo 05 — GROUP BY e HAVING](/teoria/05-group-by-having/)
