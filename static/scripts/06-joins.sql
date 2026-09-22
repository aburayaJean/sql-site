-- ============================================================
-- SQL with Jean | Módulo 06 — JOINs
-- ============================================================

-- 1. INNER JOIN — apenas registros com correspondência nos dois lados
SELECT p.id, c.nome AS cliente, p.data_pedido, p.total, p.status
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente
ORDER BY p.data_pedido;

-- 2. LEFT JOIN — todos os clientes, mesmo sem pedido
SELECT c.nome, c.cidade, p.id AS pedido, p.total
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
ORDER BY c.nome;

-- 3. LEFT JOIN — apenas quem NÃO tem pedido
SELECT c.nome, c.email
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
WHERE p.id IS NULL;

-- 4. RIGHT JOIN — todos os pedidos, mesmo sem cliente cadastrado
SELECT p.id, COALESCE(c.nome, 'Cliente removido') AS cliente, p.total
FROM clientes c
RIGHT JOIN pedidos p ON c.id = p.id_cliente;

-- 5. FULL OUTER JOIN — tudo de ambos os lados
SELECT c.nome, p.id AS pedido, p.total
FROM clientes c
FULL OUTER JOIN pedidos p ON p.id_cliente = c.id
ORDER BY c.nome NULLS LAST;

-- 6. Múltiplos JOINs — clientes + pedidos + valor total por cliente
SELECT
    c.nome,
    c.cidade,
    COUNT(p.id)   AS total_pedidos,
    SUM(p.total)  AS valor_total
FROM clientes c
LEFT JOIN pedidos p ON p.id_cliente = c.id
GROUP BY c.id, c.nome, c.cidade
ORDER BY valor_total DESC NULLS LAST;

-- 7. JOIN com filtro de status
SELECT c.nome, p.data_pedido, p.total
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente
WHERE p.status = 'entregue'
ORDER BY p.data_pedido DESC;
