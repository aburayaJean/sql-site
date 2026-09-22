---
title: "Prática 02 — SELECT e WHERE"
date: 2026-01-02
weight: 20
tags: ["iniciante", "select", "where"]
categories: ["Prática"]
description: "10 exercícios práticos de SELECT e WHERE com gabarito."
---

{{< download-script src="/scripts/02-select-where.sql" name="02-select-where.sql" >}}

## Exercícios

Tente resolver antes de olhar o gabarito no script!

**1.** Liste o nome e e-mail de todos os clientes.

**2.** Quais produtos custam mais de R$ 200?

**3.** Liste clientes de São Paulo ou Cuiabá.

**4.** Quais produtos têm "Pro" no nome?

**5.** Liste clientes sem e-mail cadastrado.

**6.** Quais pedidos foram feitos em março de 2024?

**7.** Produtos que custam entre R$ 100 e R$ 500?

**8.** Clientes cujo e-mail termina com `@email.com`?

**9.** Produtos eletrônicos com estoque acima de 20 unidades?

**10.** Pedidos com status diferente de `cancelado`?

## Gabarito comentado

```sql
-- 1. Nome e e-mail de todos os clientes
SELECT nome, email FROM clientes;

-- 2. Produtos acima de R$ 200
SELECT nome, preco FROM produtos WHERE preco > 200;

-- 3. Clientes de SP ou Cuiabá
SELECT nome, cidade FROM clientes
WHERE cidade IN ('São Paulo', 'Cuiabá');

-- 4. "Pro" no nome
SELECT nome FROM produtos WHERE nome LIKE '%Pro%';

-- 5. Sem e-mail
SELECT nome FROM clientes WHERE email IS NULL;

-- 6. Março 2024
SELECT id, total FROM pedidos
WHERE data_pedido BETWEEN '2024-03-01' AND '2024-03-31';

-- 7. Entre R$ 100 e R$ 500
SELECT nome, preco FROM produtos
WHERE preco BETWEEN 100 AND 500;

-- 8. E-mail @email.com
SELECT nome, email FROM clientes WHERE email LIKE '%@email.com';

-- 9. Eletrônicos com estoque > 20
SELECT nome, estoque FROM produtos
WHERE categoria = 'Eletrônicos' AND estoque > 20;

-- 10. Não cancelado
SELECT id, status FROM pedidos WHERE status <> 'cancelado';
```
