/* =====================================================================
   SQL with Jean — Script de setup do banco Loja
   ---------------------------------------------------------------------
   Cria (ou recria do zero) o banco Loja, usado nos posts do blog.
   Pode rodar quantas vezes quiser: ele apaga e cria tudo de novo.

   Requisitos: SQL Server 2016 ou superior (qualquer edição).
   ===================================================================== */

USE master;
GO

-- Se o banco já existe, derruba as conexões e apaga
IF DB_ID(N'Loja') IS NOT NULL
BEGIN
    ALTER DATABASE Loja SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Loja;
END
GO

CREATE DATABASE Loja;
GO

USE Loja;
GO

/* ---------------------------------------------------------------------
   Tabelas
   --------------------------------------------------------------------- */

CREATE TABLE dbo.Clientes (
    ClienteId    INT            IDENTITY(1,1) CONSTRAINT PK_Clientes PRIMARY KEY,
    Nome         NVARCHAR(100)  NOT NULL,
    Email        NVARCHAR(150)  NULL,
    Cidade       NVARCHAR(60)   NULL,
    UF           CHAR(2)        NULL,
    DataCadastro DATE           NOT NULL
);

CREATE TABLE dbo.Produtos (
    ProdutoId  INT            IDENTITY(1,1) CONSTRAINT PK_Produtos PRIMARY KEY,
    Nome       NVARCHAR(100)  NOT NULL,
    Categoria  NVARCHAR(50)   NOT NULL,
    Preco      DECIMAL(10,2)  NOT NULL
);

CREATE TABLE dbo.Pedidos (
    PedidoId    INT            IDENTITY(1,1) CONSTRAINT PK_Pedidos PRIMARY KEY,
    ClienteId   INT            NOT NULL CONSTRAINT FK_Pedidos_Clientes REFERENCES dbo.Clientes (ClienteId),
    DataPedido  DATE           NOT NULL,
    Status      NVARCHAR(20)   NOT NULL,
    Desconto    DECIMAL(10,2)  NULL
);

CREATE TABLE dbo.ItensPedido (
    PedidoId       INT            NOT NULL CONSTRAINT FK_ItensPedido_Pedidos  REFERENCES dbo.Pedidos (PedidoId),
    ProdutoId      INT            NOT NULL CONSTRAINT FK_ItensPedido_Produtos REFERENCES dbo.Produtos (ProdutoId),
    Quantidade     INT            NOT NULL,
    PrecoUnitario  DECIMAL(10,2)  NOT NULL,
    CONSTRAINT PK_ItensPedido PRIMARY KEY (PedidoId, ProdutoId)
);
GO

/* ---------------------------------------------------------------------
   Dados
   IDENTITY_INSERT ligado só para garantir que os IDs fiquem sempre
   iguais aos dos posts. No dia a dia você deixa o banco gerar sozinho.
   --------------------------------------------------------------------- */

SET IDENTITY_INSERT dbo.Clientes ON;
INSERT INTO dbo.Clientes (ClienteId, Nome, Email, Cidade, UF, DataCadastro) VALUES
    (1, N'Maria Silva',     N'maria.silva@email.com',  N'Cuiabá',         'MT', '2025-01-10'),
    (2, N'João Pereira',    N'joao.p@email.com',       N'São Paulo',      'SP', '2025-02-03'),
    (3, N'Ana Costa',       NULL,                      N'Belo Horizonte', 'MG', '2025-02-20'),
    (4, N'Carlos Souza',    N'carlos.souza@email.com', N'Várzea Grande',  'MT', '2025-03-15'),
    (5, N'Fernanda Lima',   N'fe.lima@email.com',      NULL,              NULL, '2025-04-01'),
    (6, N'Rafael Oliveira', NULL,                      N'Curitiba',       'PR', '2025-05-12'),
    (7, N'Juliana Alves',   N'ju.alves@email.com',     N'Rio de Janeiro', 'RJ', '2025-06-08'),
    (8, N'Pedro Santos',    N'pedro.santos@email.com', N'Cuiabá',         'MT', '2025-07-22');
SET IDENTITY_INSERT dbo.Clientes OFF;

SET IDENTITY_INSERT dbo.Produtos ON;
INSERT INTO dbo.Produtos (ProdutoId, Nome, Categoria, Preco) VALUES
    (1, N'Notebook 15"',         N'Informática',  4299.90),
    (2, N'Mouse sem fio',        N'Informática',    89.90),
    (3, N'Teclado mecânico',     N'Informática',   349.00),
    (4, N'Monitor 27"',          N'Informática',  1599.00),
    (5, N'Cadeira de escritório',N'Móveis',        899.00),
    (6, N'Mesa em L',            N'Móveis',       1250.00),
    (7, N'Headset',              N'Áudio',         279.90),
    (8, N'Webcam Full HD',       N'Informática',   229.00);
SET IDENTITY_INSERT dbo.Produtos OFF;

SET IDENTITY_INSERT dbo.Pedidos ON;
INSERT INTO dbo.Pedidos (PedidoId, ClienteId, DataPedido, Status, Desconto) VALUES
    ( 1, 1, '2026-01-05', N'Entregue',  NULL),
    ( 2, 2, '2026-01-12', N'Entregue',  50.00),
    ( 3, 1, '2026-02-02', N'Entregue',  NULL),
    ( 4, 3, '2026-02-18', N'Cancelado', NULL),
    ( 5, 4, '2026-03-01', N'Entregue',  100.00),
    ( 6, 5, '2026-03-09', N'Enviado',   NULL),
    ( 7, 2, '2026-04-14', N'Entregue',  0.00),
    ( 8, 6, '2026-05-20', N'Pendente',  NULL),
    ( 9, 7, '2026-06-02', N'Entregue',  30.00),
    (10, 1, '2026-06-25', N'Enviado',   NULL),
    (11, 4, '2026-07-30', N'Pendente',  NULL),
    (12, 7, '2026-08-11', N'Entregue',  NULL);
    -- O cliente 8 (Pedro) ainda não comprou nada — de propósito.
SET IDENTITY_INSERT dbo.Pedidos OFF;

INSERT INTO dbo.ItensPedido (PedidoId, ProdutoId, Quantidade, PrecoUnitario) VALUES
    ( 1, 1, 1, 4299.90),
    ( 1, 2, 1,   89.90),
    ( 2, 3, 1,  349.00),
    ( 2, 7, 2,  279.90),
    ( 3, 4, 2, 1599.00),
    ( 4, 5, 1,  899.00),
    ( 5, 6, 1, 1250.00),
    ( 5, 5, 1,  899.00),
    ( 6, 8, 1,  229.00),
    ( 6, 2, 2,   89.90),
    ( 7, 1, 1, 4199.90),
    ( 8, 7, 1,  279.90),
    ( 9, 3, 1,  349.00),
    ( 9, 2, 1,   89.90),
    (10, 4, 1, 1599.00),
    (11, 2, 3,   89.90),
    (12, 6, 1, 1250.00),
    (12, 5, 2,  899.00);
GO

/* ---------------------------------------------------------------------
   Conferência
   --------------------------------------------------------------------- */
SELECT N'Clientes'    AS Tabela, COUNT(*) AS Linhas FROM dbo.Clientes
UNION ALL
SELECT N'Produtos',               COUNT(*)          FROM dbo.Produtos
UNION ALL
SELECT N'Pedidos',                COUNT(*)          FROM dbo.Pedidos
UNION ALL
SELECT N'ItensPedido',            COUNT(*)          FROM dbo.ItensPedido;
-- Esperado: 8, 8, 12 e 18 linhas.
