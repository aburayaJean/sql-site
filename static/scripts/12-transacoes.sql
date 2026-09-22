-- ============================================================
-- SQL with Jean | Módulo 12 — Transações (ACID)
-- ============================================================

-- ACID: Atomicidade, Consistência, Isolamento, Durabilidade

-- 1. Transação simples com COMMIT
BEGIN;

    UPDATE produtos SET estoque = estoque - 1 WHERE id = 1;
    INSERT INTO pedidos (id, id_cliente, data_pedido, total, status)
    VALUES (20, 1, CURRENT_DATE, 3500.00, 'pendente');

COMMIT;  -- confirma tudo ou nada

-- 2. Transação com ROLLBACK — desfaz em caso de erro
BEGIN;

    UPDATE produtos SET estoque = estoque - 5 WHERE id = 2;
    -- Simulação de erro: estoque ficaria negativo...

ROLLBACK;  -- desfaz todas as operações do BEGIN até aqui

-- 3. SAVEPOINT — ponto intermediário de recuperação
BEGIN;

    INSERT INTO clientes (id, nome, pais) VALUES (99, 'Teste Save', 'Brasil');

    SAVEPOINT sp1;

    UPDATE clientes SET nome = 'Teste Alterado' WHERE id = 99;

    ROLLBACK TO SAVEPOINT sp1;  -- desfaz só a partir do savepoint
    -- O INSERT ainda está pendente

    RELEASE SAVEPOINT sp1;

ROLLBACK;  -- desfaz tudo (inclusive o INSERT)

-- 4. Nível de isolamento — evitar leitura suja
-- SET TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- padrão na maioria dos SGBDs
-- SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;    -- mais restritivo

-- 5. Exemplo prático — transferência segura entre contas
-- (representado com pedidos como analogia)
BEGIN;

    -- Débito
    UPDATE pedidos SET total = total - 100 WHERE id = 1;

    -- Crédito
    UPDATE pedidos SET total = total + 100 WHERE id = 2;

    -- Apenas confirma se ambos tiveram sucesso
COMMIT;

-- ============================================================
-- Resumo:
-- BEGIN / START TRANSACTION  → inicia
-- COMMIT                     → confirma permanentemente
-- ROLLBACK                   → desfaz tudo
-- SAVEPOINT nome             → ponto de restauração parcial
-- ROLLBACK TO SAVEPOINT nome → volta ao ponto
-- ============================================================
