---
title: "Subqueries (Subconsultas)"
date: 2026-01-07
weight: 70
tags: ["intermediário", "subquery", "exists"]
categories: ["Teoria"]
description: "Use consultas dentro de consultas para resolver problemas complexos."
---

Uma **subquery** é uma consulta dentro de outra consulta. Ela pode aparecer no `WHERE`, no `FROM` ou no `SELECT`.

## Subquery no WHERE

```sql
-- Produtos acima da média de preço
SELECT nome, preco FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos);
```

### Com IN

```sql
-- Clientes que já fizeram pelo menos um pedido
SELECT nome FROM clientes
WHERE id IN (SELECT DISTINCT id_cliente FROM pedidos);
```

### Com NOT IN

```sql
-- Clientes que nunca compraram
SELECT nome FROM clientes
WHERE id NOT IN (SELECT DISTINCT id_cliente FROM pedidos);
```

## Subquery no FROM (tabela derivada)

```sql
SELECT categoria, preco_medio
FROM (
    SELECT categoria, ROUND(AVG(preco), 2) AS preco_medio
    FROM produtos
    GROUP BY categoria
) AS medias
WHERE preco_medio > 300;
```

## EXISTS e NOT EXISTS

Mais eficiente que `IN` para grandes volumes — para assim que encontra o primeiro match.

```sql
-- Clientes com pedido pendente
SELECT nome FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.id_cliente = c.id AND p.status = 'pendente'
);
```

## Subquery correlacionada

A subquery referencia a consulta externa — executada uma vez por linha.

```sql
SELECT c.nome,
    (SELECT SUM(p.total) FROM pedidos p
     WHERE p.id_cliente = c.id AND p.status = 'entregue') AS total
FROM clientes c;
```

## Subquery vs CTE vs JOIN

| Situação | Preferir |
|---|---|
| Filtro simples | Subquery no WHERE |
| Reutilizar resultado | CTE (módulo 14) |
| Unir tabelas | JOIN |
| Verificar existência | EXISTS |

## Próximo passo

[Módulo 08 — INSERT, UPDATE e DELETE](/teoria/08-insert-update-delete/)
