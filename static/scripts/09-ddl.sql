-- ============================================================
-- SQL with Jean | Módulo 09 — DDL (Data Definition Language)
-- ============================================================

-- 1. CREATE TABLE — estrutura completa
CREATE TABLE categorias (
    id        INTEGER      NOT NULL,
    nome      VARCHAR(80)  NOT NULL,
    descricao VARCHAR(255),
    ativo     CHAR(1)      NOT NULL DEFAULT 'S',
    CONSTRAINT pk_categorias PRIMARY KEY (id),
    CONSTRAINT ck_categorias_ativo CHECK (ativo IN ('S', 'N'))
);

-- 2. ALTER TABLE — adicionar coluna
ALTER TABLE clientes
    ADD COLUMN telefone VARCHAR(20);

-- 3. ALTER TABLE — modificar tipo/tamanho de coluna (ANSI SQL)
-- Sintaxe varia por SGBD; no PostgreSQL:
-- ALTER TABLE clientes ALTER COLUMN telefone TYPE VARCHAR(30);

-- 4. ALTER TABLE — adicionar constraint
ALTER TABLE pedidos
    ADD CONSTRAINT fk_pedidos_clientes
    FOREIGN KEY (id_cliente) REFERENCES clientes (id);

-- 5. ALTER TABLE — renomear coluna (sintaxe ANSI SQL 2003)
-- PostgreSQL / SQL Server 2022+:
-- ALTER TABLE clientes RENAME COLUMN telefone TO fone;

-- 6. DROP COLUMN
ALTER TABLE clientes
    DROP COLUMN telefone;

-- 7. CREATE TABLE com FOREIGN KEY inline
CREATE TABLE itens_pedido (
    id         INTEGER       NOT NULL,
    id_pedido  INTEGER       NOT NULL,
    id_produto INTEGER       NOT NULL,
    quantidade INTEGER       NOT NULL DEFAULT 1,
    preco_unit DECIMAL(10,2) NOT NULL,
    CONSTRAINT pk_itens PRIMARY KEY (id),
    CONSTRAINT fk_itens_pedido  FOREIGN KEY (id_pedido)  REFERENCES pedidos  (id),
    CONSTRAINT fk_itens_produto FOREIGN KEY (id_produto) REFERENCES produtos (id),
    CONSTRAINT ck_itens_qtd     CHECK (quantidade > 0)
);

-- 8. TRUNCATE — remove todos os dados mantendo a estrutura
-- TRUNCATE TABLE itens_pedido;   -- muito mais rápido que DELETE sem WHERE

-- 9. DROP TABLE — remove a tabela e todos os dados
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS categorias;

-- 10. CREATE TABLE com SELECT (cópia de estrutura + dados)
CREATE TABLE pedidos_entregues AS
SELECT * FROM pedidos WHERE status = 'entregue';

-- Limpeza do exemplo
DROP TABLE IF EXISTS pedidos_entregues;
