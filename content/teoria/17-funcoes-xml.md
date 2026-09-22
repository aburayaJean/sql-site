---
title: "Funções XML"
date: 2026-01-17
weight: 170
tags: ["avançado", "xml", "xpath", "semi-estruturado"]
categories: ["Teoria"]
description: "Armazene e consulte XML no banco de dados com XPath, XMLQUERY e funções padrão SQL/XML."
---

SQL/XML (ISO/IEC 9075-14) define funções padronizadas para trabalhar com XML dentro do banco relacional. PostgreSQL, SQL Server e Oracle têm suporte completo.

## Tipo de dado XML

```sql
-- PostgreSQL
CREATE TABLE notas_fiscais (
    id          INTEGER NOT NULL,
    numero      VARCHAR(20) NOT NULL,
    emitida_em  DATE NOT NULL,
    conteudo    XML NOT NULL,
    CONSTRAINT pk_nf PRIMARY KEY (id)
);
```

## Inserir XML

```sql
INSERT INTO notas_fiscais (id, numero, emitida_em, conteudo) VALUES
(1, 'NF-001', '2024-01-15', '
<notaFiscal numero="NF-001">
  <emitente>
    <cnpj>12345678000100</cnpj>
    <nome>Tech Store LTDA</nome>
  </emitente>
  <destinatario>
    <cpf>12345678901</cpf>
    <nome>Ana Lima</nome>
  </destinatario>
  <itens>
    <item seq="1">
      <descricao>Notebook Pro</descricao>
      <quantidade>1</quantidade>
      <valorUnitario>3500.00</valorUnitario>
    </item>
    <item seq="2">
      <descricao>Mouse Sem Fio</descricao>
      <quantidade>2</quantidade>
      <valorUnitario>89.90</valorUnitario>
    </item>
  </itens>
  <total>3679.80</total>
</notaFiscal>'),
(2, 'NF-002', '2024-02-10', '
<notaFiscal numero="NF-002">
  <emitente>
    <cnpj>12345678000100</cnpj>
    <nome>Tech Store LTDA</nome>
  </emitente>
  <destinatario>
    <cpf>98765432100</cpf>
    <nome>Carlos Souza</nome>
  </destinatario>
  <itens>
    <item seq="1">
      <descricao>Monitor 27"</descricao>
      <quantidade>1</quantidade>
      <valorUnitario>1200.00</valorUnitario>
    </item>
  </itens>
  <total>1200.00</total>
</notaFiscal>');
```

## Extrair valores com XPATH (PostgreSQL)

```sql
-- XPATH retorna array de XML — use [1] para o primeiro elemento
SELECT
    numero,
    (XPATH('//destinatario/nome/text()',  conteudo))[1]::TEXT AS destinatario,
    (XPATH('//total/text()',              conteudo))[1]::TEXT AS total
FROM notas_fiscais;

-- Atributo XML
SELECT
    numero,
    (XPATH('/notaFiscal/@numero', conteudo))[1]::TEXT AS nf_numero
FROM notas_fiscais;

-- Múltiplos nós — expandir itens
SELECT
    n.numero,
    (XPATH('//item/descricao/text()', n.conteudo))[i] ::TEXT AS produto,
    (XPATH('//item/quantidade/text()', n.conteudo))[i] ::TEXT AS qtd,
    (XPATH('//item/valorUnitario/text()', n.conteudo))[i]::TEXT AS valor
FROM notas_fiscais n,
     GENERATE_SERIES(1, ARRAY_LENGTH(XPATH('//item', n.conteudo), 1)) AS i;
```

## XMLTABLE — extrair XML em tabela relacional (ANSI SQL/XML)

```sql
-- Suportado no PostgreSQL 10+, Oracle, IBM Db2
SELECT
    n.numero,
    x.seq,
    x.descricao,
    x.quantidade,
    x.valor_unit,
    x.quantidade::NUMERIC * x.valor_unit::NUMERIC AS subtotal
FROM notas_fiscais n,
     XMLTABLE(
         '//item'
         PASSING n.conteudo
         COLUMNS
             seq        INTEGER PATH '@seq',
             descricao  TEXT    PATH 'descricao',
             quantidade TEXT    PATH 'quantidade',
             valor_unit TEXT    PATH 'valorUnitario'
     ) AS x;
```

## XMLQUERY (PostgreSQL / Oracle / DB2)

```sql
-- Verificar se elemento existe
SELECT numero
FROM notas_fiscais
WHERE XMLEXISTS('//item[descricao = "Notebook Pro"]' PASSING conteudo);

-- Extrair como TEXT
SELECT
    numero,
    XMLQUERY('//destinatario/nome/text()' PASSING conteudo RETURNING CONTENT)
FROM notas_fiscais;
```

## Construir XML a partir de tabela (ANSI SQL/XML)

```sql
-- XMLELEMENT — construir elemento
SELECT
    XMLELEMENT(NAME "cliente",
        XMLATTRIBUTES(id AS "id"),
        XMLELEMENT(NAME "nome",   nome),
        XMLELEMENT(NAME "cidade", cidade)
    ) AS xml_linha
FROM clientes
FETCH FIRST 3 ROWS ONLY;

-- XMLAGG — agregar em um documento
SELECT
    XMLELEMENT(NAME "clientes",
        XMLAGG(
            XMLELEMENT(NAME "cliente",
                XMLATTRIBUTES(id AS "id"),
                XMLELEMENT(NAME "nome", nome)
            ) ORDER BY id
        )
    ) AS documento_xml
FROM clientes;
```

## SQL Server — XML nativo

```sql
-- FOR XML PATH — montar XML a partir de SELECT
SELECT
    id         AS "@id",
    nome       AS "nome",
    cidade     AS "cidade"
FROM clientes
FOR XML PATH('cliente'), ROOT('clientes');

-- NODES — expandir XML em linhas
SELECT
    nf.numero,
    item.n.value('descricao[1]', 'NVARCHAR(100)') AS produto,
    item.n.value('quantidade[1]', 'INT')           AS qtd,
    item.n.value('valorUnitario[1]', 'DECIMAL(10,2)') AS valor
FROM notas_fiscais nf
CROSS APPLY nf.conteudo.nodes('//item') AS item(n);

-- QUERY — extrair fragmento
SELECT numero, conteudo.query('//emitente') AS emitente
FROM notas_fiscais;

-- VALUE — extrair escalar
SELECT numero, conteudo.value('(//total)[1]', 'DECIMAL(10,2)') AS total
FROM notas_fiscais;

-- EXIST — testar existência
SELECT numero FROM notas_fiscais
WHERE conteudo.exist('//item[descricao="Monitor 27&quot;"]') = 1;
```

## Índice em coluna XML (PostgreSQL)

```sql
-- Índice funcional em caminho frequente
CREATE INDEX idx_nf_destinatario
    ON notas_fiscais USING BTREE
    (((XPATH('//destinatario/nome/text()', conteudo))[1]::TEXT));
```

## Limpeza

```sql
DROP TABLE IF EXISTS notas_fiscais;
```

## JSON vs XML — quando usar cada um?

| Critério | JSON | XML |
|---|---|---|
| Legibilidade | ✅ Compacto | ⬜ Verboso |
| APIs REST modernas | ✅ Padrão | ⬜ Raro |
| NF-e, SOAP, EDI | ⬜ | ✅ Padrão obrigatório |
| Atributos nos nós | ❌ | ✅ |
| Namespaces | ❌ | ✅ |
| Suporte ANSI | Parcial (2016) | Completo (SQL/XML) |
