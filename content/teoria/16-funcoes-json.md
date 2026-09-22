---
title: "Funções JSON"
date: 2026-01-16
weight: 160
tags: ["avançado", "json", "nosql", "semi-estruturado"]
categories: ["Teoria"]
description: "Armazene, consulte e manipule dados JSON diretamente no banco de dados relacional."
---

Os principais SGBDs modernos suportam JSON nativo — você pode armazenar documentos semi-estruturados e consultá-los com SQL padrão.

## Tipo de dado JSON

```sql
-- PostgreSQL
CREATE TABLE configuracoes (
    id      INTEGER NOT NULL,
    usuario VARCHAR(100) NOT NULL,
    dados   JSON NOT NULL,         -- JSON valida o formato; sem índice por padrão
    meta    JSONB,                 -- JSONB = binário, indexável, recomendado
    CONSTRAINT pk_config PRIMARY KEY (id)
);

-- SQL Server usa NVARCHAR + funções JSON (sem tipo nativo até 2025)
-- MySQL 5.7+ tem tipo JSON nativo
```

## Inserir dados JSON

```sql
INSERT INTO configuracoes (id, usuario, dados, meta) VALUES
(1, 'ana',    '{"tema":"escuro","idioma":"pt","notificacoes":true}',
              '{"perfil":{"nivel":"admin"},"tags":["sql","dados"]}'),
(2, 'carlos', '{"tema":"claro","idioma":"en","notificacoes":false}',
              '{"perfil":{"nivel":"user"},"tags":["iniciante"]}'),
(3, 'maria',  '{"tema":"escuro","idioma":"pt","notificacoes":true,"fonte":16}',
              '{"perfil":{"nivel":"editor"},"tags":["sql","xml","json"]}');
```

## Extrair valores (PostgreSQL)

```sql
-- Operador -> retorna JSON, ->> retorna texto
SELECT usuario,
       dados -> 'tema'              AS tema_json,   -- "escuro" (com aspas)
       dados ->> 'tema'             AS tema_texto,  -- escuro (sem aspas)
       dados ->> 'idioma'           AS idioma,
       (dados ->> 'notificacoes')::BOOLEAN AS notif
FROM configuracoes;

-- Navegar em objetos aninhados
SELECT usuario,
       meta -> 'perfil' ->> 'nivel' AS nivel
FROM configuracoes;

-- Acessar elemento de array JSON
SELECT usuario,
       meta -> 'tags' ->> 0 AS primeira_tag
FROM configuracoes;
```

## Filtrar por valor JSON

```sql
-- WHERE em campo JSON (PostgreSQL JSONB)
SELECT usuario FROM configuracoes
WHERE meta @> '{"perfil":{"nivel":"admin"}}';  -- contém (JSONB)

-- Equivalente com operador ->>
SELECT usuario FROM configuracoes
WHERE dados ->> 'tema' = 'escuro';

SELECT usuario FROM configuracoes
WHERE (dados ->> 'notificacoes')::BOOLEAN = true;
```

## Funções JSON padrão (ANSI SQL 2016 / ISO)

```sql
-- JSON_VALUE — extrai escalar (SQL Server, Oracle, MySQL 8, PostgreSQL 16+)
SELECT usuario,
       JSON_VALUE(dados, '$.tema')   AS tema,
       JSON_VALUE(dados, '$.idioma') AS idioma
FROM configuracoes;

-- JSON_QUERY — extrai objeto/array
SELECT usuario,
       JSON_QUERY(meta, '$.perfil') AS perfil_json
FROM configuracoes;

-- JSON_EXISTS — verifica se o caminho existe
SELECT usuario FROM configuracoes
WHERE JSON_EXISTS(dados, '$.fonte');  -- só quem tem campo "fonte"
```

## Construir JSON a partir de tabela (PostgreSQL)

```sql
-- Linha como JSON
SELECT ROW_TO_JSON(c) FROM clientes c FETCH FIRST 2 ROWS ONLY;

-- Agregar em array JSON
SELECT JSON_AGG(JSON_BUILD_OBJECT('id', id, 'nome', nome, 'cidade', cidade))
FROM clientes;

-- JSON compacto por grupo
SELECT
    pais,
    JSON_AGG(nome ORDER BY nome) AS clientes
FROM clientes
GROUP BY pais;
```

## Atualizar campo JSON (PostgreSQL JSONB)

```sql
-- Sobrescrever um campo
UPDATE configuracoes
SET meta = meta || '{"atualizado": true}'::JSONB
WHERE usuario = 'ana';

-- Remover um campo
UPDATE configuracoes
SET dados = dados::JSONB - 'fonte'
WHERE usuario = 'maria';
```

## Índice em JSONB (PostgreSQL)

```sql
-- GIN — busca em qualquer campo do documento
CREATE INDEX idx_config_meta ON configuracoes USING GIN (meta);

-- Índice em caminho específico (mais eficiente)
CREATE INDEX idx_config_nivel
    ON configuracoes ((meta -> 'perfil' ->> 'nivel'));
```

## SQL Server — funções JSON

```sql
-- SQL Server (OPENJSON, JSON_VALUE, JSON_MODIFY)
SELECT usuario,
       JSON_VALUE(dados, '$.tema')   AS tema,
       JSON_VALUE(dados, '$.idioma') AS idioma
FROM configuracoes;

-- Expandir JSON em linhas
SELECT u.usuario, j.[key], j.[value]
FROM configuracoes u
CROSS APPLY OPENJSON(dados) j;

-- Modificar
UPDATE configuracoes
SET dados = JSON_MODIFY(dados, '$.tema', 'claro')
WHERE usuario = 'ana';
```

## Próximo passo

[Módulo 17 — Funções XML](/teoria/17-funcoes-xml/)
