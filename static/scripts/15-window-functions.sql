-- ============================================================
-- SQL with Jean | Módulo 15 — Window Functions (Funções de Janela)
-- ============================================================

-- 1. ROW_NUMBER — numerar linhas dentro de uma partição
SELECT
    c.nome,
    p.data_pedido,
    p.total,
    ROW_NUMBER() OVER (
        PARTITION BY p.id_cliente
        ORDER BY p.data_pedido
    ) AS nr_pedido_do_cliente
FROM pedidos p
INNER JOIN clientes c ON c.id = p.id_cliente
ORDER BY c.nome, p.data_pedido;

-- 2. RANK e DENSE_RANK — ranking com empates
SELECT
    nome,
    preco,
    RANK()       OVER (ORDER BY preco DESC) AS rank_preco,
    DENSE_RANK() OVER (ORDER BY preco DESC) AS dense_rank_preco
FROM produtos
ORDER BY preco DESC;

-- 3. SUM acumulado (Running Total)
SELECT
    data_pedido,
    total,
    SUM(total) OVER (
        ORDER BY data_pedido
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS acumulado
FROM pedidos
WHERE status = 'entregue'
ORDER BY data_pedido;

-- 4. AVG por janela deslizante (3 períodos)
SELECT
    data_pedido,
    total,
    ROUND(AVG(total) OVER (
        ORDER BY data_pedido
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS media_movel_3
FROM pedidos
WHERE status = 'entregue'
ORDER BY data_pedido;

-- 5. LAG e LEAD — comparar com linha anterior/próxima
SELECT
    data_pedido,
    total,
    LAG(total,  1, 0) OVER (ORDER BY data_pedido) AS pedido_anterior,
    LEAD(total, 1, 0) OVER (ORDER BY data_pedido) AS proximo_pedido,
    total - LAG(total, 1, 0) OVER (ORDER BY data_pedido) AS variacao
FROM pedidos
WHERE status = 'entregue'
ORDER BY data_pedido;

-- 6. NTILE — dividir em quartis
SELECT
    nome,
    preco,
    NTILE(4) OVER (ORDER BY preco) AS quartil
FROM produtos
ORDER BY preco;

-- 7. FIRST_VALUE e LAST_VALUE — primeiro e último da janela
SELECT
    nome,
    preco,
    categoria,
    FIRST_VALUE(nome) OVER (
        PARTITION BY categoria ORDER BY preco
    ) AS mais_barato_categoria,
    LAST_VALUE(nome)  OVER (
        PARTITION BY categoria
        ORDER BY preco
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS mais_caro_categoria
FROM produtos
ORDER BY categoria, preco;

-- 8. Combinando: top 1 pedido por cliente (sem subquery)
SELECT *
FROM (
    SELECT
        c.nome AS cliente,
        p.data_pedido,
        p.total,
        ROW_NUMBER() OVER (
            PARTITION BY p.id_cliente
            ORDER BY p.total DESC
        ) AS rn
    FROM pedidos p
    INNER JOIN clientes c ON c.id = p.id_cliente
    WHERE p.status = 'entregue'
) ranked
WHERE rn = 1
ORDER BY total DESC;
