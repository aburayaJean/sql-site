-- ============================================================
-- SQL with Jean | Módulo 03 — ORDER BY, DISTINCT e LIMIT
-- ============================================================

-- 1. ORDER BY crescente (ASC é padrão)
SELECT nome, preco FROM produtos
ORDER BY preco ASC;

-- 2. ORDER BY decrescente
SELECT nome, preco FROM produtos
ORDER BY preco DESC;

-- 3. ORDER BY múltiplas colunas
SELECT nome, categoria, preco FROM produtos
ORDER BY categoria ASC, preco DESC;

-- 4. ORDER BY com NULLS LAST (ANSI SQL)
SELECT nome, email FROM clientes
ORDER BY email NULLS LAST;

-- 5. DISTINCT — valores únicos
SELECT DISTINCT cidade FROM clientes;

SELECT DISTINCT categoria FROM produtos;

-- 6. DISTINCT em múltiplas colunas
SELECT DISTINCT pais, cidade FROM clientes
ORDER BY pais, cidade;

-- 7. LIMIT / FETCH FIRST (ANSI SQL)
-- ANSI SQL:
SELECT nome, preco FROM produtos
ORDER BY preco DESC
FETCH FIRST 3 ROWS ONLY;

-- PostgreSQL / MySQL alternativa:
-- SELECT nome, preco FROM produtos ORDER BY preco DESC LIMIT 3;

-- SQL Server alternativa:
-- SELECT TOP 3 nome, preco FROM produtos ORDER BY preco DESC;

-- 8. Paginação com OFFSET (ANSI SQL)
SELECT nome, preco FROM produtos
ORDER BY preco DESC
OFFSET 2 ROWS FETCH NEXT 3 ROWS ONLY;

-- 9. Combinando tudo — top 3 clientes cujo email existe
SELECT DISTINCT nome, cidade FROM clientes
WHERE email IS NOT NULL
ORDER BY nome ASC
FETCH FIRST 3 ROWS ONLY;
