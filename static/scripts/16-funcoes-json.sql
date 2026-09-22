-- ============================================================
-- SQL with Jean | Módulo 16 — Funções JSON
-- PostgreSQL (JSONB) + SQL Server (JSON_VALUE / OPENJSON)
-- ============================================================

-- 1. Criar tabela com coluna JSONB (PostgreSQL)
CREATE TABLE configuracoes (
    id      INTEGER      NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    dados   JSONB        NOT NULL,   -- JSONB: binário, indexável, recomendado
    meta    JSONB,
    CONSTRAINT pk_config PRIMARY KEY (id)
);

-- 2. Inserir documentos JSON
INSERT INTO configuracoes (id, usuario, dados, meta) VALUES
(1, 'ana',
 '{"tema":"escuro","idioma":"pt","notificacoes":true}',
 '{"perfil":{"nivel":"admin"},"tags":["sql","dados"]}'),
(2, 'carlos',
 '{"tema":"claro","idioma":"en","notificacoes":false}',
 '{"perfil":{"nivel":"user"},"tags":["iniciante"]}'),
(3, 'maria',
 '{"tema":"escuro","idioma":"pt","notificacoes":true,"fonte":16}',
 '{"perfil":{"nivel":"editor"},"tags":["sql","xml","json"]}');

-- 3. Extrair campos — operadores -> e ->>
SELECT usuario,
       dados -> 'tema'             AS tema_json,    -- retorna JSON (com aspas)
       dados ->> 'tema'            AS tema_texto,   -- retorna texto puro
       dados ->> 'idioma'          AS idioma,
       (dados ->> 'notificacoes')::BOOLEAN AS notif
FROM configuracoes;

-- 4. Navegar em objetos aninhados
SELECT usuario,
       meta -> 'perfil' ->> 'nivel' AS nivel
FROM configuracoes;

-- 5. Acessar elemento de array (índice começa em 0)
SELECT usuario,
       meta -> 'tags' ->> 0 AS primeira_tag,
       meta -> 'tags' ->> 1 AS segunda_tag
FROM configuracoes;

-- 6. Filtrar por campo JSON
SELECT usuario, dados ->> 'tema' AS tema
FROM configuracoes
WHERE dados ->> 'tema' = 'escuro';

-- 7. Containment (@>) — JSONB verifica se contém o documento
SELECT usuario
FROM configuracoes
WHERE meta @> '{"perfil":{"nivel":"admin"}}';

-- 8. Verificar se campo existe (?  operador)
SELECT usuario
FROM configuracoes
WHERE dados ? 'fonte';   -- apenas quem tem campo "fonte"

-- 9. JSON_VALUE — ANSI SQL 2016 (PostgreSQL 16+, SQL Server, Oracle, MySQL 8)
SELECT usuario,
       JSON_VALUE(dados, '$.tema')   AS tema,
       JSON_VALUE(dados, '$.idioma') AS idioma
FROM configuracoes;

-- 10. JSON_EXISTS — verifica caminho
SELECT usuario
FROM configuracoes
WHERE JSON_EXISTS(dados, '$.fonte');

-- 11. Construir JSON a partir de colunas
SELECT
    id,
    JSON_BUILD_OBJECT(
        'usuario', usuario,
        'tema',    dados ->> 'tema',
        'nivel',   meta -> 'perfil' ->> 'nivel'
    ) AS resumo
FROM configuracoes;

-- 12. Agregar em array JSON
SELECT JSON_AGG(
    JSON_BUILD_OBJECT('id', id, 'usuario', usuario)
    ORDER BY id
) AS lista
FROM configuracoes;

-- 13. Atualizar campo JSONB (||  sobrescreve / merge)
UPDATE configuracoes
SET dados = dados || '{"tema":"sistema"}'
WHERE usuario = 'carlos';

-- 14. Remover campo JSONB
UPDATE configuracoes
SET dados = dados - 'fonte'
WHERE usuario = 'maria';

-- 15. Índice GIN — busca em qualquer chave do documento
CREATE INDEX idx_config_dados ON configuracoes USING GIN (dados);
CREATE INDEX idx_config_meta  ON configuracoes USING GIN (meta);

-- 16. Índice em caminho específico (mais eficiente para queries exatas)
CREATE INDEX idx_config_nivel
    ON configuracoes ((meta -> 'perfil' ->> 'nivel'));

-- 17. Verificação final
SELECT usuario, dados, meta FROM configuracoes ORDER BY id;

-- ============================================================
-- SQL SERVER (substituir as queries acima por estas)
-- ============================================================
-- SELECT usuario,
--        JSON_VALUE(dados, '$.tema')   AS tema,
--        JSON_VALUE(dados, '$.idioma') AS idioma
-- FROM configuracoes;
--
-- -- Expandir JSON em linhas com OPENJSON
-- SELECT c.usuario, j.[key], j.[value]
-- FROM configuracoes c
-- CROSS APPLY OPENJSON(dados) j;
--
-- -- Modificar campo
-- UPDATE configuracoes
-- SET dados = JSON_MODIFY(dados, '$.tema', 'claro')
-- WHERE usuario = 'ana';
-- ============================================================

-- Limpeza
DROP INDEX IF EXISTS idx_config_nivel;
DROP INDEX IF EXISTS idx_config_dados;
DROP INDEX IF EXISTS idx_config_meta;
DROP TABLE IF EXISTS configuracoes;
