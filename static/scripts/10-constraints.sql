-- ============================================================
-- SQL with Jean | Módulo 10 — Constraints (Restrições)
-- ============================================================

-- 1. PRIMARY KEY — chave primária
CREATE TABLE departamentos (
    id   INTEGER     NOT NULL,
    nome VARCHAR(80) NOT NULL,
    CONSTRAINT pk_departamentos PRIMARY KEY (id)
);

-- 2. PRIMARY KEY composta (chave natural)
CREATE TABLE matriculas (
    id_aluno   INTEGER NOT NULL,
    id_curso   INTEGER NOT NULL,
    data_inicio DATE   NOT NULL,
    CONSTRAINT pk_matriculas PRIMARY KEY (id_aluno, id_curso)
);

-- 3. UNIQUE — valor único na coluna
CREATE TABLE funcionarios (
    id      INTEGER      NOT NULL,
    cpf     CHAR(11)     NOT NULL,
    email   VARCHAR(150) NOT NULL,
    nome    VARCHAR(100) NOT NULL,
    CONSTRAINT pk_funcionarios PRIMARY KEY (id),
    CONSTRAINT uq_funcionarios_cpf   UNIQUE (cpf),
    CONSTRAINT uq_funcionarios_email UNIQUE (email)
);

-- 4. NOT NULL — coluna obrigatória (declarado inline)
-- (já demonstrado acima com NOT NULL)

-- 5. CHECK — validação de domínio
CREATE TABLE avaliações (
    id         INTEGER NOT NULL,
    id_produto INTEGER NOT NULL,
    nota       INTEGER NOT NULL,
    comentario TEXT,
    CONSTRAINT pk_avaliacoes   PRIMARY KEY (id),
    CONSTRAINT fk_av_produto   FOREIGN KEY (id_produto) REFERENCES produtos (id),
    CONSTRAINT ck_nota_valida  CHECK (nota BETWEEN 1 AND 5)
);

-- 6. FOREIGN KEY com ON DELETE / ON UPDATE
CREATE TABLE itens_pedido2 (
    id         INTEGER       NOT NULL,
    id_pedido  INTEGER       NOT NULL,
    id_produto INTEGER       NOT NULL,
    quantidade INTEGER       NOT NULL,
    CONSTRAINT pk_itens2          PRIMARY KEY (id),
    CONSTRAINT fk_itens2_pedido   FOREIGN KEY (id_pedido)
        REFERENCES pedidos (id) ON DELETE CASCADE,
    CONSTRAINT fk_itens2_produto  FOREIGN KEY (id_produto)
        REFERENCES produtos (id) ON DELETE RESTRICT,
    CONSTRAINT ck_itens2_qtd      CHECK (quantidade > 0)
);

-- 7. DEFAULT — valor padrão
CREATE TABLE logs (
    id         INTEGER     NOT NULL,
    acao       VARCHAR(50) NOT NULL,
    criado_em  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_logs PRIMARY KEY (id)
);

-- 8. Adicionar constraint em tabela existente
ALTER TABLE clientes
    ADD CONSTRAINT uq_clientes_email UNIQUE (email);

-- 9. Remover constraint
ALTER TABLE clientes
    DROP CONSTRAINT uq_clientes_email;

-- Limpeza
DROP TABLE IF EXISTS itens_pedido2;
DROP TABLE IF EXISTS avaliações;
DROP TABLE IF EXISTS logs;
DROP TABLE IF EXISTS funcionarios;
DROP TABLE IF EXISTS matriculas;
DROP TABLE IF EXISTS departamentos;
