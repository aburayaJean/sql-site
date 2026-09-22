-- ============================================================
-- SQL with Jean | Módulo 14 — CTEs (Common Table Expressions)
-- ============================================================

-- 1. CTE simples com WITH
WITH pedidos_entregues AS (
    SELECT id_cliente, SUM(total) AS total_entregue
    FROM pedidos
    WHERE status = 'entregue'
    GROUP BY id_cliente
)
SELECT c.nome, pe.total_entregue
FROM clientes c
INNER JOIN pedidos_entregues pe ON pe.id_cliente = c.id
ORDER BY pe.total_entregue DESC;

-- 2. Múltiplas CTEs encadeadas
WITH
resumo_pedidos AS (
    SELECT id_cliente,
           COUNT(*)   AS qtd_pedidos,
           SUM(total) AS total_gasto
    FROM pedidos
    GROUP BY id_cliente
),
clientes_vip AS (
    SELECT id_cliente
    FROM resumo_pedidos
    WHERE total_gasto > 1000
)
SELECT c.nome, rp.qtd_pedidos, rp.total_gasto
FROM clientes c
INNER JOIN resumo_pedidos rp ON rp.id_cliente = c.id
INNER JOIN clientes_vip   cv ON cv.id_cliente = c.id
ORDER BY rp.total_gasto DESC;

-- 3. CTE RECURSIVE — sequência numérica
WITH RECURSIVE numeros (n) AS (
    SELECT 1                  -- âncora (base)
    UNION ALL
    SELECT n + 1 FROM numeros -- recursão
    WHERE n < 10
)
SELECT n FROM numeros;

-- 4. CTE RECURSIVE — hierarquia de categorias
CREATE TABLE categorias_hier (
    id       INTEGER      NOT NULL,
    nome     VARCHAR(80)  NOT NULL,
    id_pai   INTEGER,
    CONSTRAINT pk_cat_hier PRIMARY KEY (id)
);

INSERT INTO categorias_hier VALUES
(1, 'Tecnologia',    NULL),
(2, 'Eletrônicos',   1),
(3, 'Informática',   1),
(4, 'Notebooks',     3),
(5, 'Periféricos',   3);

WITH RECURSIVE hierarquia AS (
    -- âncora: raiz (sem pai)
    SELECT id, nome, id_pai, 0 AS nivel, CAST(nome AS VARCHAR(500)) AS caminho
    FROM categorias_hier
    WHERE id_pai IS NULL

    UNION ALL

    -- recursão: filhos
    SELECT c.id, c.nome, c.id_pai, h.nivel + 1,
           CAST(h.caminho || ' > ' || c.nome AS VARCHAR(500))
    FROM categorias_hier c
    INNER JOIN hierarquia h ON h.id = c.id_pai
)
SELECT nivel, nome, caminho
FROM hierarquia
ORDER BY caminho;

DROP TABLE IF EXISTS categorias_hier;

-- 5. CTE para UPDATE (PostgreSQL)
-- WITH cte AS (
--     SELECT id FROM pedidos WHERE status = 'pendente' AND data_pedido < CURRENT_DATE - 30
-- )
-- UPDATE pedidos SET status = 'cancelado'
-- WHERE id IN (SELECT id FROM cte);
