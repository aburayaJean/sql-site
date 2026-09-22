---
title: "Prática 03 — ORDER BY, DISTINCT e LIMIT"
date: 2026-01-03
weight: 30
tags: ["iniciante", "order-by", "distinct"]
categories: ["Prática"]
description: "Ordene, elimine duplicatas e pagine resultados na prática."
---

{{< download-script src="/scripts/03-order-distinct-limit.sql" name="03-order-distinct-limit.sql" >}}

## Exercícios

**1.** Liste produtos do mais caro ao mais barato.

**2.** Quais cidades únicas existem na tabela de clientes?

**3.** Os 3 produtos mais caros.

**4.** Lista de categorias únicas, em ordem alfabética.

**5.** Clientes com e-mail cadastrado, ordenados por nome, mostrando só os 3 primeiros.

**6.** Produtos ordenados por categoria (A→Z) e dentro de cada categoria, do mais barato ao mais caro.

## Gabarito

```sql
-- 1. Mais caro ao mais barato
SELECT nome, preco FROM produtos ORDER BY preco DESC;

-- 2. Cidades únicas
SELECT DISTINCT cidade FROM clientes ORDER BY cidade;

-- 3. Top 3 mais caros (ANSI SQL)
SELECT nome, preco FROM produtos
ORDER BY preco DESC
FETCH FIRST 3 ROWS ONLY;

-- 4. Categorias únicas
SELECT DISTINCT categoria FROM produtos ORDER BY categoria;

-- 5. 3 clientes com e-mail, ordenados por nome
SELECT nome, email FROM clientes
WHERE email IS NOT NULL
ORDER BY nome
FETCH FIRST 3 ROWS ONLY;

-- 6. Por categoria e preço
SELECT nome, categoria, preco FROM produtos
ORDER BY categoria ASC, preco ASC;
```
