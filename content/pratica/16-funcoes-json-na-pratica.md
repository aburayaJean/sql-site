---
title: "Prática 16 — Funções JSON"
date: 2026-01-16
weight: 160
tags: ["avançado", "json"]
categories: ["Prática"]
description: "Inserir, consultar, filtrar e atualizar dados JSON com PostgreSQL JSONB e SQL Server."
---

{{< download-script src="/scripts/16-funcoes-json.sql" name="16-funcoes-json.sql" >}}

## Exercícios

**1.** Crie a tabela `configuracoes` com coluna JSONB e insira os 3 usuários do script.

**2.** Liste todos os usuários com seu tema e idioma extraídos do JSON.

**3.** Quais usuários têm o tema `"escuro"`?

**4.** Quem tem o campo `"fonte"` definido nas configurações?

**5.** Qual o nível de cada usuário (dentro de `meta.perfil.nivel`)?

**6.** Qual a primeira tag de cada usuário (array `meta.tags[0]`)?

**7.** Use `@>` para encontrar o usuário com nível `"admin"`.

**8.** Construa um JSON resumido com `JSON_BUILD_OBJECT` mostrando usuario, tema e nivel.

**9.** Atualize o tema do Carlos para `"sistema"` usando o operador `||`.

**10.** Remova o campo `"fonte"` da Maria.

## Gabarito

```sql
-- 2. Tema e idioma de todos
SELECT usuario,
       dados ->> 'tema'   AS tema,
       dados ->> 'idioma' AS idioma
FROM configuracoes;

-- 3. Tema escuro
SELECT usuario FROM configuracoes
WHERE dados ->> 'tema' = 'escuro';

-- 4. Quem tem campo "fonte"
SELECT usuario FROM configuracoes
WHERE dados ? 'fonte';

-- 5. Nível de cada um
SELECT usuario, meta -> 'perfil' ->> 'nivel' AS nivel
FROM configuracoes;

-- 6. Primeira tag
SELECT usuario, meta -> 'tags' ->> 0 AS primeira_tag
FROM configuracoes;

-- 7. Admin por containment
SELECT usuario FROM configuracoes
WHERE meta @> '{"perfil":{"nivel":"admin"}}';

-- 8. JSON resumido
SELECT JSON_BUILD_OBJECT(
    'usuario', usuario,
    'tema', dados ->> 'tema',
    'nivel', meta -> 'perfil' ->> 'nivel'
) AS resumo
FROM configuracoes;

-- 9. Atualizar tema do Carlos
UPDATE configuracoes
SET dados = dados || '{"tema":"sistema"}'
WHERE usuario = 'carlos';

-- 10. Remover campo "fonte" da Maria
UPDATE configuracoes
SET dados = dados - 'fonte'
WHERE usuario = 'maria';
```
