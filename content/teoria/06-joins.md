---
title: "JOINs"
date: 2026-01-06
weight: 60
tags: ["intermediário", "join", "inner-join", "left-join"]
categories: ["Teoria"]
description: "Una tabelas com INNER JOIN, LEFT JOIN, RIGHT JOIN e FULL OUTER JOIN."
---

JOINs combinam linhas de **duas ou mais tabelas** com base em uma condição de relacionamento.

## Tipos de JOIN

### INNER JOIN — interseção

Retorna apenas linhas que têm correspondência nos dois lados.

```sql
SELECT p.id, c.nome, p.total
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente;
```

### LEFT JOIN — todos da esquerda

Retorna **todos** os registros da tabela à esquerda, mesmo sem correspondência à direita (NULL onde não há match).

```sql
-- Todos os clientes, mesmo os que nunca compraram
SELECT c.nome, p.id AS pedido
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id;
```

**Quem nunca comprou?**
```sql
SELECT c.nome FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
WHERE p.id IS NULL;
```

### RIGHT JOIN — todos da direita

Espelho do LEFT JOIN — todos os registros da tabela à direita.

### FULL OUTER JOIN — tudo dos dois lados

```sql
SELECT c.nome, p.id AS pedido
FROM clientes c
FULL OUTER JOIN pedidos p ON p.id_cliente = c.id;
```

## Diagrama mental

```
INNER:  A ∩ B
LEFT:   A + (A ∩ B)
RIGHT:  B + (A ∩ B)
FULL:   A ∪ B
```

## JOIN com múltiplas tabelas

```sql
SELECT c.nome, COUNT(p.id) AS pedidos, SUM(p.total) AS gasto
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
GROUP BY c.id, c.nome
ORDER BY gasto DESC NULLS LAST;
```

## Boas práticas

- Sempre use **alias** (`c`, `p`, `pr`) para legibilidade
- Prefira `INNER JOIN` explícito a vírgula entre tabelas no `FROM`
- Nunca faça JOIN sem `ON` (Cartesian product)

## Próximo passo

[Módulo 07 — Subqueries](/teoria/07-subqueries/)
