---
title: "DDL — Criação e Alteração de Estruturas"
date: 2026-01-09
weight: 90
tags: ["intermediário", "ddl", "create", "alter", "drop"]
categories: ["Teoria"]
description: "CREATE, ALTER e DROP — os comandos que definem a estrutura do banco."
---

DDL (*Data Definition Language*) define e modifica a **estrutura** do banco: tabelas, colunas, tipos de dados.

## CREATE TABLE

```sql
CREATE TABLE categorias (
    id        INTEGER      NOT NULL,
    nome      VARCHAR(80)  NOT NULL,
    ativo     CHAR(1)      NOT NULL DEFAULT 'S',
    CONSTRAINT pk_categorias PRIMARY KEY (id),
    CONSTRAINT ck_ativo      CHECK (ativo IN ('S', 'N'))
);
```

### Tipos de dados ANSI comuns

| Tipo | Uso |
|---|---|
| `INTEGER` / `BIGINT` | números inteiros |
| `DECIMAL(p,s)` | valores monetários |
| `VARCHAR(n)` | texto de tamanho variável |
| `CHAR(n)` | texto de tamanho fixo |
| `DATE` | data (sem hora) |
| `TIMESTAMP` | data e hora |
| `BOOLEAN` | verdadeiro/falso |

## ALTER TABLE

```sql
-- Adicionar coluna
ALTER TABLE clientes ADD COLUMN telefone VARCHAR(20);

-- Remover coluna
ALTER TABLE clientes DROP COLUMN telefone;

-- Adicionar constraint
ALTER TABLE pedidos
    ADD CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes (id);

-- Remover constraint
ALTER TABLE pedidos DROP CONSTRAINT fk_pedidos_clientes;
```

## DROP TABLE

```sql
DROP TABLE IF EXISTS historico_pedidos;  -- IF EXISTS evita erro se não existir
```

> ⚠️ `DROP TABLE` é irreversível — apaga a estrutura **e todos os dados**.

## CREATE TABLE AS SELECT

```sql
-- Cria uma cópia da tabela com dados (boa para ambientes de testes)
CREATE TABLE pedidos_backup AS
SELECT * FROM pedidos WHERE status = 'entregue';
```

## Próximo passo

[Módulo 10 — Constraints](/teoria/10-constraints/)
