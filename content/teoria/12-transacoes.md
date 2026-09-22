---
title: "Transações e ACID"
date: 2026-01-12
weight: 120
tags: ["avançado", "transações", "acid", "commit", "rollback"]
categories: ["Teoria"]
description: "Entenda ACID e garanta consistência com BEGIN, COMMIT, ROLLBACK e SAVEPOINT."
---

Uma **transação** agrupa um conjunto de operações que devem ser executadas **todas ou nenhuma**. É a base da confiabilidade em bancos relacionais.

## ACID

| Propriedade | Significado |
|---|---|
| **A**tomicidade | tudo ou nada — sem estados intermediários visíveis |
| **C**onsistência | o banco vai de um estado válido a outro estado válido |
| **I**solamento | transações concorrentes não se interferem |
| **D**urabilidade | dados confirmados persistem mesmo após falha |

## Comandos de controle

```sql
BEGIN;           -- inicia a transação (ou START TRANSACTION)

    UPDATE produtos SET estoque = estoque - 1 WHERE id = 1;
    INSERT INTO pedidos (id, id_cliente, data_pedido, total)
    VALUES (20, 1, CURRENT_DATE, 3500.00);

COMMIT;          -- confirma todas as operações
-- ou
ROLLBACK;        -- desfaz todas as operações desde o BEGIN
```

## SAVEPOINT — ponto de recuperação parcial

```sql
BEGIN;
    INSERT INTO clientes (id, nome, pais) VALUES (99, 'Teste', 'Brasil');
    SAVEPOINT sp1;

    UPDATE clientes SET nome = 'Errado' WHERE id = 99;
    ROLLBACK TO SAVEPOINT sp1;  -- desfaz só a partir do savepoint

    -- O INSERT ainda está ativo
COMMIT;
```

## Níveis de isolamento (do menos ao mais restritivo)

| Nível | Leitura suja | Leitura não-repetível | Phantom |
|---|---|---|---|
| READ UNCOMMITTED | ✅ possível | ✅ | ✅ |
| READ COMMITTED | ❌ | ✅ | ✅ |
| REPEATABLE READ | ❌ | ❌ | ✅ |
| SERIALIZABLE | ❌ | ❌ | ❌ |

A maioria dos SGBDs usa **READ COMMITTED** como padrão.

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
-- operações críticas
COMMIT;
```

## Próximo passo

[Módulo 13 — Views](/teoria/13-views/)
