-- ============================================================
-- SQL with Jean | Módulo 05 — GROUP BY e HAVING
-- ============================================================

-- 1. GROUP BY básico — total de pedidos por status
SELECT status, COUNT(*) AS qtd_pedidos
FROM pedidos
GROUP BY status;

-- 2. GROUP BY com SUM
SELECT id_cliente, SUM(total) AS total_gasto
FROM pedidos
GROUP BY id_cliente
ORDER BY total_gasto DESC;

-- 3. GROUP BY com múltiplas colunas
SELECT categoria, COUNT(*) AS qtd_produtos, ROUND(AVG(preco),2) AS preco_medio
FROM produtos
GROUP BY categoria
ORDER BY categoria;

-- 4. HAVING — filtrar grupos (equivale ao WHERE, mas para grupos)
-- Clientes que gastaram mais de R$ 500 no total
SELECT id_cliente, SUM(total) AS total_gasto
FROM pedidos
GROUP BY id_cliente
HAVING SUM(total) > 500.00
ORDER BY total_gasto DESC;

-- 5. HAVING com COUNT — categorias com mais de 2 produtos
SELECT categoria, COUNT(*) AS qtd
FROM produtos
GROUP BY categoria
HAVING COUNT(*) > 2;

-- 6. WHERE + GROUP BY + HAVING juntos
-- Pedidos entregues, agrupados por cliente, onde total > 1000
SELECT id_cliente,
       COUNT(*)   AS pedidos_entregues,
       SUM(total) AS total
FROM pedidos
WHERE status = 'entregue'
GROUP BY id_cliente
HAVING SUM(total) > 1000.00
ORDER BY total DESC;

-- 7. GROUP BY por mês (ANSI SQL com EXTRACT)
SELECT
    EXTRACT(YEAR  FROM data_pedido) AS ano,
    EXTRACT(MONTH FROM data_pedido) AS mes,
    COUNT(*)   AS pedidos,
    SUM(total) AS receita
FROM pedidos
GROUP BY EXTRACT(YEAR FROM data_pedido), EXTRACT(MONTH FROM data_pedido)
ORDER BY ano, mes;
