-- ============================================================
-- SQL with Jean | Módulo 07 — Subqueries (Subconsultas)
-- ============================================================

-- 1. Subquery no WHERE — produtos acima da média de preço
SELECT nome, preco
FROM produtos
WHERE preco > (SELECT AVG(preco) FROM produtos)
ORDER BY preco DESC;

-- 2. Subquery com IN — clientes que já fizeram pedido
SELECT nome, cidade
FROM clientes
WHERE id IN (SELECT DISTINCT id_cliente FROM pedidos);

-- 3. Subquery com NOT IN — clientes que nunca compraram
SELECT nome, email
FROM clientes
WHERE id NOT IN (SELECT DISTINCT id_cliente FROM pedidos);

-- 4. Subquery correlacionada — total gasto por cliente (correlacionada)
SELECT
    c.nome,
    (SELECT SUM(p.total)
     FROM pedidos p
     WHERE p.id_cliente = c.id
       AND p.status = 'entregue') AS total_entregue
FROM clientes c
ORDER BY total_entregue DESC NULLS LAST;

-- 5. Subquery no FROM (tabela derivada)
SELECT categoria, preco_medio
FROM (
    SELECT categoria, ROUND(AVG(preco), 2) AS preco_medio
    FROM produtos
    GROUP BY categoria
) AS medias
WHERE preco_medio > 300;

-- 6. EXISTS — clientes que têm pelo menos um pedido pendente
SELECT nome, email
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.id_cliente = c.id
      AND p.status = 'pendente'
);

-- 7. NOT EXISTS
SELECT nome
FROM clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM pedidos p WHERE p.id_cliente = c.id
);

-- 8. Subquery escalada no SELECT — receita total no mesmo resultado
SELECT
    status,
    COUNT(*) AS qtd,
    SUM(total) AS receita,
    ROUND(SUM(total) / (SELECT SUM(total) FROM pedidos WHERE total IS NOT NULL) * 100, 1) AS pct_receita
FROM pedidos
WHERE total IS NOT NULL
GROUP BY status;
