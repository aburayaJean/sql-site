-- ============================================================
-- SQL with Jean | Módulo 02 — SELECT e WHERE
-- ============================================================

-- 1. SELECT básico — todas as colunas
SELECT * FROM clientes;

-- 2. SELECT com colunas específicas
SELECT nome, email, cidade FROM clientes;

-- 3. WHERE — filtro simples (igualdade)
SELECT nome, cidade FROM clientes
WHERE pais = 'Brasil';

-- 4. WHERE com comparadores numéricos
SELECT nome, preco FROM produtos
WHERE preco > 200.00;

SELECT nome, preco FROM produtos
WHERE preco BETWEEN 100.00 AND 500.00;

-- 5. WHERE com AND / OR
SELECT nome, cidade FROM clientes
WHERE cidade = 'São Paulo' OR cidade = 'Cuiabá';

SELECT nome, preco, estoque FROM produtos
WHERE categoria = 'Eletrônicos' AND estoque > 20;

-- 6. WHERE com IN
SELECT nome, cidade FROM clientes
WHERE cidade IN ('São Paulo', 'Rio de Janeiro', 'Cuiabá');

-- 7. WHERE com LIKE (padrão de texto)
SELECT nome, email FROM clientes
WHERE email LIKE '%@email.com';

SELECT nome FROM produtos
WHERE nome LIKE '%Pro%';

-- 8. WHERE com IS NULL / IS NOT NULL
SELECT nome, email FROM clientes
WHERE email IS NULL;

SELECT nome, email FROM clientes
WHERE email IS NOT NULL;

-- 9. WHERE com NOT
SELECT nome, cidade FROM clientes
WHERE cidade NOT IN ('São Paulo', 'Rio de Janeiro');

-- 10. WHERE com datas
SELECT id, id_cliente, data_pedido, total FROM pedidos
WHERE data_pedido >= '2024-03-01';

SELECT id, total, status FROM pedidos
WHERE data_pedido BETWEEN '2024-01-01' AND '2024-03-31';
