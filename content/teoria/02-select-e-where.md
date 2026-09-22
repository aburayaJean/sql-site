---
title: "SELECT e WHERE"
date: 2026-01-02
weight: 20
tags: ["iniciante", "select", "where"]
categories: ["Teoria"]
description: "Aprenda a consultar dados com SELECT e filtrar resultados com WHERE."
---

`SELECT` é o comando mais usado em SQL — ele **busca dados** de uma ou mais tabelas. `WHERE` **filtra** quais linhas você quer ver.

## Sintaxe básica

```sql
SELECT coluna1, coluna2
FROM tabela
WHERE condição;
```

Use `*` para selecionar todas as colunas (útil para exploração, evite em produção):

```sql
SELECT * FROM clientes;
```

## Filtros com WHERE

### Igualdade e comparações

```sql
SELECT nome, preco FROM produtos WHERE preco > 200.00;
SELECT nome, cidade FROM clientes WHERE cidade = 'Cuiabá';
SELECT * FROM pedidos WHERE status <> 'cancelado';
```

### BETWEEN — intervalo

```sql
SELECT nome, preco FROM produtos
WHERE preco BETWEEN 100.00 AND 500.00;
```

### IN — lista de valores

```sql
SELECT nome FROM clientes
WHERE cidade IN ('São Paulo', 'Rio de Janeiro', 'Cuiabá');
```

### LIKE — padrão de texto

| Padrão | Significado |
|---|---|
| `'%sql%'` | contém "sql" |
| `'sql%'` | começa com "sql" |
| `'%sql'` | termina com "sql" |

```sql
SELECT nome FROM clientes WHERE email LIKE '%@gmail.com';
```

### IS NULL / IS NOT NULL

```sql
SELECT nome FROM clientes WHERE email IS NULL;
SELECT nome FROM clientes WHERE email IS NOT NULL;
```

### AND / OR / NOT

```sql
SELECT nome, preco FROM produtos
WHERE categoria = 'Eletrônicos' AND estoque > 0;

SELECT nome FROM clientes
WHERE cidade = 'São Paulo' OR cidade = 'Cuiabá';
```

> **Dica:** Use parênteses quando combinar AND e OR para deixar a precedência explícita.

## Próximo passo

[Módulo 03 — ORDER BY, DISTINCT e LIMIT](/teoria/03-order-distinct-limit/)
