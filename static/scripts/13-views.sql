-- ============================================================
-- SQL with Jean | Módulo 13 — Views (Visões)
-- ============================================================

-- 1. View simples — pedidos com nome do cliente
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

-- Usar a view como uma tabela normal:
SELECT * FROM vw_pedidos_clientes WHERE status = 'entregue';

SELECT cliente, SUM(total) AS total_gasto
FROM vw_pedidos_clientes
GROUP BY cliente
ORDER BY total_gasto DESC;

-- 2. View com filtro — apenas pedidos pendentes
CREATE VIEW vw_pedidos_pendentes AS
SELECT pedido_id, cliente, data_pedido, total
FROM vw_pedidos_clientes
WHERE status = 'pendente';

SELECT * FROM vw_pedidos_pendentes;

-- 3. View com agregação — resumo por cliente
CREATE VIEW vw_resumo_clientes AS
SELECT
    c.id,
    c.nome,
    c.cidade,
    COUNT(p.id)          AS total_pedidos,
    COALESCE(SUM(p.total), 0) AS valor_total,
    MAX(p.data_pedido)   AS ultimo_pedido
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
GROUP BY c.id, c.nome, c.cidade;

SELECT * FROM vw_resumo_clientes ORDER BY valor_total DESC;

-- 4. ALTER VIEW (substituir definição — PostgreSQL / SQL Server)
-- CREATE OR REPLACE VIEW vw_pedidos_pendentes AS ...  (PostgreSQL)

-- 5. DROP VIEW
DROP VIEW IF EXISTS vw_pedidos_pendentes;
DROP VIEW IF EXISTS vw_resumo_clientes;
DROP VIEW IF EXISTS vw_pedidos_clientes;

-- ============================================================
-- Quando usar Views:
-- + Simplificar queries complexas com JOINs recorrentes
-- + Controlar o que cada usuário/role pode ver (segurança)
-- + Padronizar relatórios e nomes de colunas
-- - Views não armazenam dados (exceto Materialized Views)
-- ============================================================
