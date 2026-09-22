---
title: "ORDER BY, DISTINCT e LIMIT"
date: 2026-01-03
weight: 30
tags: ["iniciante", "order-by", "distinct", "limit"]
categories: ["Teoria"]
description: "Ordene resultados, elimine duplicatas e controle quantas linhas retornar."
---

Três cláusulas essenciais para moldar o resultado das suas consultas.

## ORDER BY — ordenar resultados

```sql
SELECT nome, preco FROM produtos ORDER BY preco ASC;   -- crescente (padrão)
SELECT nome, preco FROM produtos ORDER BY preco DESC;  -- decrescente
```

### Múltiplas colunas

```sql
SELECT nome, categoria, preco FROM produtos
ORDER BY categoria ASC, preco DESC;
```

### NULLS LAST / NULLS FIRST (ANSI SQL)

```sql
SELECT nome, email FROM clientes
ORDER BY email NULLS LAST;  -- coloca os NULL no final
```

## DISTINCT — eliminar duplicatas

```sql
SELECT DISTINCT cidade FROM clientes;
SELECT DISTINCT categoria FROM produtos;
```

`DISTINCT` age sobre **todas** as colunas selecionadas — a linha inteira precisa ser diferente para ser eliminada.

## LIMIT / FETCH FIRST — limitar linhas

### ANSI SQL (recomendado)

```sql
SELECT nome, preco FROM produtos
ORDER BY preco DESC
FETCH FIRST 3 ROWS ONLY;
```

### Paginação com OFFSET

```sql
SELECT nome, preco FROM produtos
ORDER BY preco DESC
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;  -- página 2, 3 por página
```

### Equivalentes por SGBD

| SGBD | Sintaxe |
|---|---|
| PostgreSQL / MySQL | `LIMIT 3 OFFSET 3` |
| SQL Server | `TOP 3` (sem offset fácil) ou `FETCH FIRST` (2012+) |
| Oracle | `FETCH FIRST` (12c+) ou `ROWNUM` |

> **Boa prática:** sempre use `ORDER BY` junto com `FETCH FIRST` para garantir resultados determinísticos.

## Próximo passo

[Módulo 04 — Funções de Agregação](/teoria/04-funcoes-agregacao/)
