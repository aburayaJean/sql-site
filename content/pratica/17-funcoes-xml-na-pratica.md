---
title: "Prática 17 — Funções XML"
date: 2026-01-17
weight: 170
tags: ["avançado", "xml"]
categories: ["Prática"]
description: "Inserir notas fiscais em XML, extrair campos com XPATH e decompor com XMLTABLE."
---

{{< download-script src="/scripts/17-funcoes-xml.sql" name="17-funcoes-xml.sql" >}}

## Exercícios

**1.** Crie a tabela `notas_fiscais` e insira as duas NFs do script.

**2.** Extraia o número, nome do destinatário e total de cada nota.

**3.** Qual nota contém o item "Notebook Pro"? Use `XMLEXISTS`.

**4.** Use `XMLTABLE` para listar todos os itens das notas com: número da NF, descrição, quantidade, valor unitário e subtotal calculado.

**5.** Construa um documento XML dos clientes da tabela `clientes` usando `XMLELEMENT` + `XMLAGG`.

**6.** (SQL Server) Extraia o destinatário e total usando `.value()`.

**7.** (SQL Server) Expanda os itens da nota com `.nodes()`.

## Gabarito

```sql
-- 2. Número, destinatário e total
SELECT
    numero,
    (XPATH('//destinatario/nome/text()', conteudo))[1]::TEXT AS destinatario,
    (XPATH('//total/text()', conteudo))[1]::TEXT             AS total
FROM notas_fiscais;

-- 3. Nota com Notebook Pro
SELECT numero FROM notas_fiscais
WHERE XMLEXISTS('//item[descricao = "Notebook Pro"]' PASSING conteudo);

-- 4. Itens com XMLTABLE
SELECT n.numero, x.descricao, x.quantidade, x.valor_unit,
       x.quantidade * x.valor_unit AS subtotal
FROM notas_fiscais n,
     XMLTABLE('//item' PASSING n.conteudo
         COLUMNS
             descricao  TEXT           PATH 'descricao',
             quantidade NUMERIC(10,0)  PATH 'quantidade',
             valor_unit NUMERIC(10,2)  PATH 'valorUnitario'
     ) AS x;

-- 5. Documento XML dos clientes
SELECT XMLELEMENT(NAME "clientes",
    XMLAGG(
        XMLELEMENT(NAME "cliente",
            XMLATTRIBUTES(id AS "id"),
            XMLELEMENT(NAME "nome", nome),
            XMLELEMENT(NAME "cidade", COALESCE(cidade,'N/D'))
        ) ORDER BY id
    )
) FROM clientes;

-- 6. SQL Server — destinatário e total
-- SELECT numero,
--   conteudo.value('(//destinatario/nome)[1]','NVARCHAR(100)') AS dest,
--   conteudo.value('(//total)[1]','DECIMAL(10,2)') AS total
-- FROM notas_fiscais;

-- 7. SQL Server — expandir itens
-- SELECT nf.numero,
--   x.n.value('descricao[1]','NVARCHAR(100)') AS produto,
--   x.n.value('quantidade[1]','INT') AS qtd,
--   x.n.value('valorUnitario[1]','DECIMAL(10,2)') AS valor
-- FROM notas_fiscais nf
-- CROSS APPLY nf.conteudo.nodes('//item') AS x(n);
```
