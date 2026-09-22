-- ============================================================
-- SQL with Jean | Módulo 11 — Índices (Indexes)
-- ============================================================

-- 1. Índice simples (B-Tree — padrão ANSI)
CREATE INDEX idx_clientes_cidade ON clientes (cidade);

-- 2. Índice em coluna de FK — melhora performance de JOINs
CREATE INDEX idx_pedidos_id_cliente ON pedidos (id_cliente);

-- 3. Índice ÚNICO — garante unicidade E melhora performance de busca
CREATE UNIQUE INDEX idx_clientes_email ON clientes (email)
    WHERE email IS NOT NULL;   -- índice parcial (PostgreSQL)
    -- Remova a cláusula WHERE para SQL Server / Oracle / MySQL

-- 4. Índice composto — útil para filtros frequentes com AND
CREATE INDEX idx_pedidos_status_data ON pedidos (status, data_pedido);

-- Consulta que se beneficia do índice composto acima:
SELECT id, total FROM pedidos
WHERE status = 'entregue'
  AND data_pedido >= '2024-01-01'
ORDER BY data_pedido DESC;

-- 5. Índice em expressão (PostgreSQL / Oracle)
-- CREATE INDEX idx_clientes_nome_lower ON clientes (LOWER(nome));
-- SELECT * FROM clientes WHERE LOWER(nome) = 'ana lima';

-- 6. Ver índices existentes (PostgreSQL)
-- SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'pedidos';

-- 7. EXPLAIN — analisar uso de índice (PostgreSQL)
-- EXPLAIN ANALYZE SELECT * FROM pedidos WHERE id_cliente = 1;

-- 8. DROP INDEX
DROP INDEX IF EXISTS idx_clientes_cidade;
DROP INDEX IF EXISTS idx_pedidos_id_cliente;
DROP INDEX IF EXISTS idx_clientes_email;
DROP INDEX IF EXISTS idx_pedidos_status_data;

-- ============================================================
-- Boas práticas:
-- + Crie índices em colunas usadas frequentemente no WHERE, JOIN e ORDER BY
-- + Índices compostos: coloque primeiro a coluna mais seletiva
-- + Evite excesso de índices em tabelas com muitos INSERT/UPDATE
-- + Analise com EXPLAIN antes de criar; meça depois
-- ============================================================
