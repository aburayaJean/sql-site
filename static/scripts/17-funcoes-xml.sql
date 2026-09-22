-- ============================================================
-- SQL with Jean | Módulo 17 — Funções XML
-- PostgreSQL (XML + XPATH + XMLTABLE) + SQL Server (XML nativo)
-- ============================================================

-- 1. Criar tabela com coluna XML
CREATE TABLE notas_fiscais (
    id         INTEGER     NOT NULL,
    numero     VARCHAR(20) NOT NULL,
    emitida_em DATE        NOT NULL,
    conteudo   XML         NOT NULL,
    CONSTRAINT pk_nf PRIMARY KEY (id)
);

-- 2. Inserir notas fiscais em XML
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
      <descricao>Monitor 27pol</descricao>
      <quantidade>1</quantidade>
      <valorUnitario>1200.00</valorUnitario>
    </item>
  </itens>
  <total>1200.00</total>
</notaFiscal>');

-- ============================================================
-- POSTGRESQL — XPATH
-- ============================================================

-- 3. Extrair campos escalares com XPATH
-- XPATH retorna array; [1] pega o primeiro elemento
SELECT
    numero,
    (XPATH('//destinatario/nome/text()',  conteudo))[1]::TEXT AS destinatario,
    (XPATH('//emitente/nome/text()',      conteudo))[1]::TEXT AS emitente,
    (XPATH('//total/text()',              conteudo))[1]::TEXT AS total
FROM notas_fiscais;

-- 4. Extrair atributo XML (@  para atributos)
SELECT
    numero,
    (XPATH('/notaFiscal/@numero', conteudo))[1]::TEXT AS attr_numero
FROM notas_fiscais;

-- 5. XMLEXISTS — verificar se elemento/valor existe
SELECT numero
FROM notas_fiscais
WHERE XMLEXISTS('//item[descricao = "Notebook Pro"]' PASSING conteudo);

-- 6. Expandir itens manualmente com GENERATE_SERIES
SELECT
    n.numero,
    (XPATH('//item/descricao/text()',    n.conteudo))[i]::TEXT   AS produto,
    (XPATH('//item/quantidade/text()',   n.conteudo))[i]::TEXT   AS qtd,
    (XPATH('//item/valorUnitario/text()',n.conteudo))[i]::TEXT   AS valor_unit
FROM notas_fiscais n,
     GENERATE_SERIES(1, ARRAY_LENGTH(XPATH('//item', n.conteudo), 1)) AS i;

-- ============================================================
-- ANSI SQL/XML — XMLTABLE (PostgreSQL 10+, Oracle, IBM Db2)
-- ============================================================

-- 7. XMLTABLE — decompor XML em linhas/colunas relacionais
SELECT
    n.numero,
    x.seq,
    x.descricao,
    x.quantidade,
    x.valor_unit,
    x.quantidade * x.valor_unit AS subtotal
FROM notas_fiscais n,
     XMLTABLE(
         '//item'
         PASSING n.conteudo
         COLUMNS
             seq        INTEGER        PATH '@seq',
             descricao  VARCHAR(100)   PATH 'descricao',
             quantidade NUMERIC(10,0)  PATH 'quantidade',
             valor_unit NUMERIC(10,2)  PATH 'valorUnitario'
     ) AS x;

-- ============================================================
-- Construir XML a partir de tabela (ANSI SQL/XML)
-- ============================================================

-- 8. XMLELEMENT — construir um elemento por linha
SELECT
    XMLELEMENT(NAME "cliente",
        XMLATTRIBUTES(id AS "id"),
        XMLELEMENT(NAME "nome",   nome),
        XMLELEMENT(NAME "cidade", COALESCE(cidade, 'N/D'))
    ) AS xml_cliente
FROM clientes
ORDER BY id
FETCH FIRST 3 ROWS ONLY;

-- 9. XMLAGG — agregar várias linhas em um único documento
SELECT
    XMLELEMENT(NAME "clientes",
        XMLAGG(
            XMLELEMENT(NAME "cliente",
                XMLATTRIBUTES(id AS "id"),
                XMLELEMENT(NAME "nome",   nome),
                XMLELEMENT(NAME "cidade", COALESCE(cidade,'N/D'))
            ) ORDER BY id
        )
    ) AS documento
FROM clientes;

-- ============================================================
-- SQL SERVER — XML nativo
-- ============================================================
-- -- Extrair escalar com .value()
-- SELECT numero,
--        conteudo.value('(//destinatario/nome)[1]', 'NVARCHAR(100)') AS destinatario,
--        conteudo.value('(//total)[1]',              'DECIMAL(10,2)') AS total
-- FROM notas_fiscais;
--
-- -- Extrair fragmento com .query()
-- SELECT numero, conteudo.query('//emitente') AS emitente_xml
-- FROM notas_fiscais;
--
-- -- Verificar existência com .exist()
-- SELECT numero FROM notas_fiscais
-- WHERE conteudo.exist('//item[descricao="Notebook Pro"]') = 1;
--
-- -- Expandir itens com .nodes()
-- SELECT nf.numero,
--        x.n.value('descricao[1]',    'NVARCHAR(100)')  AS produto,
--        x.n.value('quantidade[1]',   'INT')             AS qtd,
--        x.n.value('valorUnitario[1]','DECIMAL(10,2)')   AS valor
-- FROM notas_fiscais nf
-- CROSS APPLY nf.conteudo.nodes('//item') AS x(n);
--
-- -- Gerar XML com FOR XML PATH
-- SELECT id AS "@id", nome AS "nome", cidade AS "cidade"
-- FROM clientes
-- FOR XML PATH('cliente'), ROOT('clientes');
-- ============================================================

-- Limpeza
DROP TABLE IF EXISTS notas_fiscais;
