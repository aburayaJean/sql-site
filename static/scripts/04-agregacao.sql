-- ============================================================
-- SQL with Jean | Módulo 04 — Funções de Agregação
-- ============================================================

-- 1. COUNT — contar registros
SELECT COUNT(*) AS total_clientes FROM clientes;

SELECT COUNT(email) AS clientes_com_email FROM clientes;  -- ignora NULL

-- 2. SUM — somar
SELECT SUM(total) AS receita_total FROM pedidos;

SELECT SUM(total) AS receita_entregue FROM pedidos
WHERE status = 'entregue';

-- 3. AVG — média
SELECT AVG(preco) AS preco_medio FROM produtos;

SELECT ROUND(AVG(total), 2) AS ticket_medio FROM pedidos
WHERE status = 'entregue';

-- 4. MIN e MAX
SELECT MIN(preco) AS mais_barato, MAX(preco) AS mais_caro FROM produtos;

SELECT MIN(data_pedido) AS primeiro_pedido,
       MAX(data_pedido) AS ultimo_pedido
FROM pedidos;

-- 5. Combinando múltiplas funções
SELECT
    COUNT(*)             AS total_pedidos,
    SUM(total)           AS receita_bruta,
    ROUND(AVG(total), 2) AS ticket_medio,
    MIN(total)           AS menor_pedido,
    MAX(total)           AS maior_pedido
FROM pedidos
WHERE status = 'entregue';

-- 6. COUNT DISTINCT
SELECT COUNT(DISTINCT id_cliente) AS clientes_que_compraram
FROM pedidos;

-- 7. Agregação com COALESCE (tratar NULL)
SELECT SUM(COALESCE(total, 0)) AS receita_segura FROM pedidos;
