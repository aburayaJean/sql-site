-- ============================================================
-- SQL with Jean | Módulo 08 — INSERT, UPDATE e DELETE (DML)
-- ============================================================

-- 1. INSERT simples
INSERT INTO clientes (id, nome, email, cidade, pais)
VALUES (8, 'Roberto Nunes', 'roberto@email.com', 'Manaus', 'Brasil');

-- 2. INSERT múltiplos registros (ANSI SQL)
INSERT INTO produtos (id, nome, categoria, preco, estoque) VALUES
(8,  'Headset Gamer',    'Eletrônicos', 299.00, 20),
(9,  'Suporte para PC',  'Móveis',       79.90, 12),
(10, 'Hub USB',          'Eletrônicos',  49.90, 50);

-- 3. INSERT sem especificar colunas com DEFAULT (evite em produção)
-- Apenas para colunas que têm DEFAULT definido:
INSERT INTO pedidos (id, id_cliente, data_pedido, total)
VALUES (10, 8, CURRENT_DATE, 299.00);
-- O campo "status" vai receber o DEFAULT 'pendente'

-- 4. UPDATE simples — atualizar um registro
UPDATE clientes
SET email = 'roberto.nunes@email.com'
WHERE id = 8;

-- 5. UPDATE com expressão
UPDATE produtos
SET preco = preco * 1.10   -- reajuste de 10%
WHERE categoria = 'Móveis';

-- 6. UPDATE múltiplos campos
UPDATE pedidos
SET status = 'entregue',
    total  = total * 0.95   -- desconto de 5% ao confirmar
WHERE id = 10;

-- 7. DELETE de registro específico
DELETE FROM pedidos
WHERE id = 10;

-- 8. DELETE com subquery — remove pedidos de clientes sem email
DELETE FROM pedidos
WHERE id_cliente IN (
    SELECT id FROM clientes WHERE email IS NULL
);

-- ⚠️ DELETE sem WHERE remove TUDO — use com extremo cuidado
-- DELETE FROM tabela;   -- apaga todos os registros!

-- 9. Verificação final
SELECT * FROM clientes ORDER BY id;
SELECT * FROM produtos ORDER BY id;
