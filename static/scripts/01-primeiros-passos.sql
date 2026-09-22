-- =============================================================
-- SQL with Jean | Módulo 1: Primeiros Passos
-- Compatível com: SQL Server, PostgreSQL, MySQL, SQLite
-- sqlwithjean.dev
-- =============================================================

-- ── CLEANUP (remove se já existir) ──────────────────────────
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;

-- ── CRIAR TABELAS ───────────────────────────────────────────
CREATE TABLE clientes (
    id        INTEGER      NOT NULL,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(150),
    cidade    VARCHAR(80),
    pais      VARCHAR(50)  NOT NULL DEFAULT 'Brasil',
    CONSTRAINT pk_clientes PRIMARY KEY (id)
);

CREATE TABLE produtos (
    id          INTEGER        NOT NULL,
    nome        VARCHAR(100)   NOT NULL,
    categoria   VARCHAR(50),
    preco       DECIMAL(10, 2) NOT NULL,
    estoque     INTEGER        NOT NULL DEFAULT 0,
    CONSTRAINT pk_produtos PRIMARY KEY (id)
);

CREATE TABLE pedidos (
    id          INTEGER        NOT NULL,
    id_cliente  INTEGER        NOT NULL,
    data_pedido DATE           NOT NULL,
    total       DECIMAL(10, 2),
    status      VARCHAR(20)    NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_pedidos PRIMARY KEY (id)
);

-- ── INSERIR DADOS ───────────────────────────────────────────
INSERT INTO clientes (id, nome, email, cidade, pais) VALUES
    (1, 'Ana Lima',       'ana@email.com',    'São Paulo',     'Brasil'),
    (2, 'Carlos Mendes',  'carlos@email.com', 'Rio de Janeiro','Brasil'),
    (3, 'Julia Ferreira', 'julia@email.com',  'Curitiba',      'Brasil'),
    (4, 'Robert Smith',   'robert@email.com', 'New York',      'EUA'),
    (5, 'Maria Santos',   'maria@email.com',  'Lisboa',        'Portugal');

INSERT INTO produtos (id, nome, categoria, preco, estoque) VALUES
    (1, 'Notebook Pro',     'Eletrônicos', 4500.00, 15),
    (2, 'Mouse Ergonômico', 'Periféricos',   89.90, 80),
    (3, 'Teclado Mecânico', 'Periféricos',  320.00, 45),
    (4, 'Monitor 27"',      'Eletrônicos', 1890.00, 20),
    (5, 'Headset USB',      'Periféricos',  250.00, 35);

INSERT INTO pedidos (id, id_cliente, data_pedido, total, status) VALUES
    (1, 1, '2024-01-10', 4589.90, 'entregue'),
    (2, 2, '2024-01-12',  320.00, 'entregue'),
    (3, 1, '2024-01-15', 2140.00, 'enviado'),
    (4, 3, '2024-01-18',   89.90, 'pendente'),
    (5, 4, '2024-01-20', 4500.00, 'entregue');

-- ── CONSULTAS DE EXEMPLO ────────────────────────────────────

-- 1. Todos os clientes
SELECT * FROM clientes;

-- 2. Colunas específicas
SELECT nome, cidade FROM clientes;

-- 3. Filtro por país
SELECT nome, cidade
FROM   clientes
WHERE  pais = 'Brasil';

-- 4. Ordenado por nome
SELECT nome, cidade
FROM   clientes
WHERE  pais = 'Brasil'
ORDER BY nome;

-- 5. Todos os produtos ordenados por preço
SELECT nome, categoria, preco
FROM   produtos
ORDER BY preco DESC;