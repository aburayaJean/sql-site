---
title: "Índices"
date: 2026-01-11
weight: 110
tags: ["avançado", "índices", "performance"]
categories: ["Teoria"]
description: "Acelere consultas com índices — entenda quando criar, quando evitar e como analisar."
---

Um índice é uma **estrutura auxiliar** que o banco mantém para localizar linhas rapidamente sem varrer a tabela inteira.

## Analogia

Pense no índice de um livro: em vez de ler todas as páginas para achar "Transações", você vai direto ao índice e salta para a página certa.

## Criar um índice (B-Tree padrão)

```sql
-- Índice simples
CREATE INDEX idx_clientes_cidade ON clientes (cidade);

-- Índice em FK (acelera JOINs)
CREATE INDEX idx_pedidos_cliente ON pedidos (id_cliente);

-- Índice ÚNICO (unicidade + busca rápida)
CREATE UNIQUE INDEX idx_clientes_email ON clientes (email)
    WHERE email IS NOT NULL;  -- índice parcial (PostgreSQL)
```

## Índice composto

Útil quando o WHERE filtra por múltiplas colunas juntas:

```sql
CREATE INDEX idx_pedidos_status_data ON pedidos (status, data_pedido);
```

> **Regra:** a coluna mais seletiva deve vir primeiro.

## Quando criar índices

✅ Colunas usadas frequentemente no `WHERE`, `JOIN` e `ORDER BY`  
✅ Colunas de FK  
✅ Colunas com alta cardinalidade (muitos valores distintos)

## Quando evitar

❌ Tabelas muito pequenas (varredura total é mais rápida)  
❌ Colunas com poucos valores distintos (ex.: `status` com 3 valores)  
❌ Excesso de índices em tabelas com muitos `INSERT`/`UPDATE` (manutenção cara)

## Analisar uso com EXPLAIN

```sql
EXPLAIN ANALYZE
SELECT * FROM pedidos WHERE id_cliente = 1;
```

Procure por `Index Scan` no plano — indica que o índice está sendo usado.

## DROP INDEX

```sql
DROP INDEX IF EXISTS idx_clientes_cidade;
```

## Próximo passo

[Módulo 12 — Transações](/teoria/12-transacoes/)
