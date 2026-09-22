-- ============================================================
-- SQL with Jean | Módulo 01 — Ambiente e Primeiros Passos
-- ANSI SQL — compatível com PostgreSQL, SQL Server, MySQL, Oracle
-- ============================================================

-- 1. Criação das tabelas base (modelo usado em todos os módulos)
CREATE TABLE clientes (
    id      INTEGER      NOT NULL,
    nome    VARCHAR(100) NOT NULL,
    email   VARCHAR(150),
    cidade  VARCHAR(80),
    pais    VARCHAR(50)  NOT NULL DEFAULT 'Brasil',
    CONSTRAINT pk_clientes PRIMARY KEY (id)
);

CREATE TABLE produtos (
    id        INTEGER       NOT NULL,
    nome      VARCHAR(100)  NOT NULL,
    categoria VARCHAR(50),
    preco     DECIMAL(10,2) NOT NULL,
    estoque   INTEGER       NOT NULL DEFAULT 0,
    CONSTRAINT pk_produtos PRIMARY KEY (id)
);

CREATE TABLE pedidos (
    id          INTEGER       NOT NULL,
    id_cliente  INTEGER       NOT NULL,
    data_pedido DATE          NOT NULL,
    total       DECIMAL(10,2),
    status      VARCHAR(20)   NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_pedidos PRIMARY KEY (id)
);

-- 2. Inserção de dados de exemplo
INSERT INTO clientes (id, nome, email, cidade, pais) VALUES
(1, 'Ana Lima',      'ana@email.com',    'São Paulo',      'Brasil'),
(2, 'Carlos Souza',  'carlos@email.com', 'Rio de Janeiro', 'Brasil'),
(3, 'Maria Silva',   'maria@email.com',  'Cuiabá',         'Brasil'),
(4, 'João Santos',   'joao@email.com',   'Belo Horizonte', 'Brasil'),
(5, 'Lucia Ferreira','lucia@email.com',  'Porto Alegre',   'Brasil'),
(6, 'Pedro Alves',   NULL,               'Recife',         'Brasil'),
(7, 'Fernanda Costa',NULL,               'Salvador',       'Brasil');

INSERT INTO produtos (id, nome, categoria, preco, estoque) VALUES
(1, 'Notebook Pro',     'Eletrônicos', 3500.00, 15),
(2, 'Mouse Sem Fio',    'Eletrônicos',   89.90, 80),
(3, 'Teclado Mecânico', 'Eletrônicos',  250.00, 30),
(4, 'Monitor 27"',      'Eletrônicos', 1200.00, 10),
(5, 'Cadeira Gamer',    'Móveis',       799.00,  5),
(6, 'Mesa de Escritório','Móveis',      450.00,  8),
(7, 'Webcam HD',        'Eletrônicos',  199.00, 25);

INSERT INTO pedidos (id, id_cliente, data_pedido, total, status) VALUES
(1, 1, '2024-01-10',  3589.90, 'entregue'),
(2, 2, '2024-01-15',   339.90, 'entregue'),
(3, 1, '2024-02-01',  1200.00, 'entregue'),
(4, 3, '2024-02-10',   799.00, 'cancelado'),
(5, 4, '2024-03-05',   250.00, 'entregue'),
(6, 5, '2024-03-20',  3500.00, 'pendente'),
(7, 2, '2024-04-01',   450.00, 'entregue'),
(8, 6, '2024-04-15',    89.90, 'pendente'),
(9, 3, '2024-05-01',   199.00, 'entregue');

-- 3. Verificação
SELECT 'clientes' AS tabela, COUNT(*) AS total FROM clientes
UNION ALL
SELECT 'produtos', COUNT(*) FROM produtos
UNION ALL
SELECT 'pedidos',  COUNT(*) FROM pedidos;
