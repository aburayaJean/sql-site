---
title: "INSERT, UPDATE e DELETE"
date: 2026-01-08
weight: 80
tags: ["intermediário", "dml", "insert", "update", "delete"]
categories: ["Teoria"]
description: "Manipule dados com os comandos DML: INSERT, UPDATE e DELETE."
---

DML (*Data Manipulation Language*) são os comandos que **alteram os dados** — não a estrutura — das tabelas.

## INSERT — inserir dados

```sql
-- Um registro
INSERT INTO clientes (id, nome, email, cidade)
VALUES (10, 'Carlos Andrade', 'carlos@email.com', 'Cuiabá');

-- Múltiplos registros (ANSI SQL)
INSERT INTO produtos (id, nome, categoria, preco, estoque) VALUES
(8, 'Headset Gamer', 'Eletrônicos', 299.00, 20),
(9, 'Hub USB',       'Eletrônicos',  49.90, 50);
```

### INSERT com SELECT

```sql
-- Copiar pedidos cancelados para uma tabela de histórico
INSERT INTO historico_pedidos
SELECT * FROM pedidos WHERE status = 'cancelado';
```

## UPDATE — atualizar dados

```sql
-- Atualizar um campo específico
UPDATE clientes SET email = 'novo@email.com' WHERE id = 10;

-- Atualizar múltiplos campos
UPDATE pedidos
SET status = 'entregue', total = total * 0.95
WHERE id = 5;

-- Reajuste em massa
UPDATE produtos SET preco = preco * 1.10
WHERE categoria = 'Eletrônicos';
```

> ⚠️ **Sempre use WHERE no UPDATE** — sem WHERE, todos os registros são alterados.

## DELETE — remover dados

```sql
-- Remove um registro específico
DELETE FROM clientes WHERE id = 10;

-- Remove com subquery
DELETE FROM pedidos
WHERE id_cliente IN (SELECT id FROM clientes WHERE email IS NULL);
```

> ⚠️ **Sempre use WHERE no DELETE** — `DELETE FROM tabela` apaga **tudo**.

## TRUNCATE — alternativa rápida ao DELETE total

```sql
TRUNCATE TABLE historico_pedidos;  -- muito mais rápido, sem WHERE
```

Diferença: `DELETE` registra cada linha no log; `TRUNCATE` não registra linha por linha (não é possível fazer ROLLBACK em alguns SGBDs).

## Próximo passo

[Módulo 09 — DDL](/teoria/09-ddl/)
