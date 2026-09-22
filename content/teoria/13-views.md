---
title: "Views (Visões)"
date: 2026-01-13
weight: 130
tags: ["avançado", "views", "segurança"]
categories: ["Teoria"]
description: "Simplifique consultas complexas e controle o acesso com Views."
---

Uma **view** é uma consulta salva que se comporta como uma tabela. Ela não armazena dados — executa a query toda vez que é consultada.

## Criar uma view

```sql
CREATE VIEW vw_pedidos_clientes AS
SELECT
    p.id           AS pedido_id,
    c.nome         AS cliente,
    c.cidade,
    p.data_pedido,
    p.total,
    p.status
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente;
```

## Consultar a view

```sql
SELECT * FROM vw_pedidos_clientes WHERE status = 'entregue';

SELECT cliente, SUM(total) AS gasto
FROM vw_pedidos_clientes
GROUP BY cliente
ORDER BY gasto DESC;
```

## Atualizar (substituir) uma view

```sql
-- PostgreSQL
CREATE OR REPLACE VIEW vw_pedidos_clientes AS
SELECT ...;
```

## Remover

```sql
DROP VIEW IF EXISTS vw_pedidos_clientes;
```

## Quando usar views

✅ Simplificar JOINs recorrentes  
✅ Padronizar nomes de colunas para relatórios  
✅ Controlar acesso — usuário vê a view, não a tabela base  
✅ Encapsular regras de negócio

## Views vs Materialized Views

| Tipo | Armazena dados? | Performance | Atualização |
|---|---|---|---|
| View | Não | Executa a query a cada uso | Sempre atual |
| Materialized View | Sim | Muito mais rápida | Precisa de REFRESH |

```sql
-- PostgreSQL — Materialized View
CREATE MATERIALIZED VIEW mv_resumo_mensal AS
SELECT EXTRACT(MONTH FROM data_pedido) AS mes, SUM(total) AS receita
FROM pedidos GROUP BY mes;

REFRESH MATERIALIZED VIEW mv_resumo_mensal;
```

## Próximo passo

[Módulo 14 — CTEs](/teoria/14-ctes/)
