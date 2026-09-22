---
title: "Estilo de código SQL: escreva para quem vai ler depois"
description: "Formatação, nomes, schema, ponto e vírgula e por que o SELECT * dá problema no código que fica. Com as convenções que eu uso e ferramentas para formatar sozinho."
date: 2026-02-27T08:00:00-04:00
weight: 12
roadmap: "estilo-codigo"
tags: ["fundamentos", "ambiente", "boas-praticas"]
---

O SQL Server não liga se você escreve tudo em minúsculas numa linha só. Quem liga é a pessoa que vai abrir esse código daqui a seis meses para achar um bug. E muitas vezes essa pessoa é você.

Não existe um estilo "oficial". O que importa é **escolher um e ser consistente**. Abaixo estão as convenções que eu sigo e que você vai ver em todos os posts do blog.

## Formatação

- **Uma cláusula por linha.** `SELECT`, `FROM`, `JOIN`, `WHERE`, `GROUP BY`, `ORDER BY`, cada um começando uma linha.
- **Palavras-chave em MAIÚSCULAS**, nomes de objetos do jeito que foram criados. Assim o olho separa a linguagem dos dados. (A própria documentação da Microsoft usa essa convenção.)
- **Uma coluna por linha** quando a lista é grande. Facilita comentar uma coluna e ler a diferença no Git.
- **Alias curtos e com sentido**: `p` para Pedidos, `c` para Clientes. Nada de `a`, `b`, `c` sem relação com a tabela.
- **Sempre `AS` no alias.** `SUM(x) AS Total` é mais claro que `SUM(x) Total`.
- **Comente o porquê, não o quê.** `-- exclui cancelados porque o financeiro não conta` ajuda; `-- filtra status` não.

## Hábitos que evitam problemas

**Sempre o schema no nome.** Escreva `dbo.Clientes`, não só `Clientes`. Sem o schema, o SQL Server procura primeiro no schema padrão do usuário e depois no `dbo`. Isso pode achar o objeto errado e atrapalha o reaproveitamento de planos de execução.

**Termine os comandos com ponto e vírgula.** Hoje ele é opcional na maioria dos comandos, mas a documentação avisa que vai ser **obrigatório em uma versão futura**, e não terminar com `;` já está na lista de recursos obsoletos. Alguns comandos já exigem: o `MERGE` precisa terminar com `;`, e o comando **antes** de uma CTE (`WITH`) também.

**Liste as colunas.** `SELECT *` é ótimo para explorar uma tabela no dia a dia. Em código que fica (view, procedure, aplicação), ele traz colunas que você não precisa, quebra quando a tabela muda e esconde de quem lê quais dados são usados. O mesmo vale para `INSERT` sem a lista de colunas. Na prática abaixo você vai ver os dois quebrando.

**Não ordene por número.** `ORDER BY 3` funciona, mas se alguém adicionar uma coluna no começo do `SELECT`, a ordenação muda sem ninguém perceber. Use o nome ou o alias.

**Use `N'...'` para texto Unicode.** Se a coluna é `NVARCHAR`, o literal deve ser `N'São Paulo'`. Sem o `N`, caracteres fora da página de código do banco podem virar `?`.

## Nomes

- **Sem prefixo de tipo**: `dbo.Clientes`, não `dbo.tbl_Clientes`. O Object Explorer já diz o que é tabela.
- **Nunca `sp_` em procedure sua.** O prefixo `sp_` é das procedures de sistema: o SQL Server procura primeiro no banco `master`, e se um dia a Microsoft criar uma com o mesmo nome, a dela ganha. Use `usp_` ou só um verbo: `dbo.CadastrarCliente`.
- **Sem espaço, acento ou palavra reservada.** `[Data Pedido]`, `[Ação]` e `[Order]` funcionam com colchetes, mas você vai ter que usar colchetes para sempre. Prefira `DataPedido`, `Acao`, `Pedido`.
- **Singular ou plural, escolha um.** Neste blog as tabelas estão no plural (`Clientes`, `Pedidos`). O importante é o banco inteiro seguir o mesmo padrão.
- **Constraints com nome.** `CONSTRAINT PK_Clientes PRIMARY KEY` em vez de deixar o SQL Server gerar `PK__Clientes__71ABD0A7...`. Nome gerado muda de um ambiente para outro e complica os scripts de deploy.

## Bora pra prática

Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### 1. Antes e depois

Esta query funciona:

```sql
select c.nome,count(*) qtd,sum(i.quantidade*i.precounitario) total from pedidos p join clientes c on c.clienteid=p.clienteid join itenspedido i on i.pedidoid=p.pedidoid where p.status<>'Cancelado' group by c.nome order by 3 desc
```

Agora a mesma coisa, arrumada:

```sql
SELECT   c.Nome                               AS Cliente,
         COUNT(DISTINCT p.PedidoId)           AS QtdPedidos,
         SUM(i.Quantidade * i.PrecoUnitario)  AS Total
FROM     dbo.Pedidos     AS p
JOIN     dbo.Clientes    AS c ON c.ClienteId = p.ClienteId
JOIN     dbo.ItensPedido AS i ON i.PedidoId  = p.PedidoId
WHERE    p.Status <> N'Cancelado'
GROUP BY c.Nome
ORDER BY Total DESC;
```

Rode as duas e compare a segunda coluna. Na versão bagunçada, o `count(*)` contava **itens**, não pedidos: a Maria aparece com mais "pedidos" do que fez. Na versão arrumada, dá para ver o `JOIN` com `ItensPedido` e perceber que o certo é `COUNT(DISTINCT p.PedidoId)`. Código legível não é frescura: é onde o bug aparece.

Um detalhe: a versão em minúsculas só funcionou porque a collation padrão do SQL Server não diferencia maiúsculas de minúsculas. Num banco com collation *case sensitive*, `pedidos` e `Pedidos` são coisas diferentes e a query quebraria.

### 2. O SELECT * que para no tempo

Crie uma tabela de teste e uma view com `SELECT *`:

```sql
CREATE TABLE dbo.TesteEstilo (
    Id   INT          NOT NULL,
    Nome NVARCHAR(50) NOT NULL
);
GO

CREATE VIEW dbo.vw_TesteEstilo
AS
SELECT * FROM dbo.TesteEstilo;
GO

INSERT INTO dbo.TesteEstilo (Id, Nome) VALUES (1, N'Ana');

SELECT * FROM dbo.vw_TesteEstilo;
```

Agora a tabela ganha uma coluna:

```sql
ALTER TABLE dbo.TesteEstilo ADD Telefone VARCHAR(20) NULL;
GO

SELECT * FROM dbo.TesteEstilo;      -- 3 colunas
SELECT * FROM dbo.vw_TesteEstilo;   -- ainda 2 colunas!
```

A view não viu o `Telefone`. O `*` foi trocado pela lista de colunas **no momento em que a view foi criada**, e essa lista ficou guardada. Para atualizar:

```sql
EXEC sp_refreshview N'dbo.vw_TesteEstilo';

SELECT * FROM dbo.vw_TesteEstilo;   -- agora 3 colunas
```

Parece inofensivo, mas se uma coluna for **removida** ou a ordem mudar, uma view assim pode devolver dados com o nome da coluna errada. Com a lista de colunas escrita, você sabe exatamente o que ela devolve.

### 3. O INSERT sem lista de colunas

Antes da coluna nova, este `INSERT` funcionava. Tente agora:

```sql
INSERT INTO dbo.TesteEstilo VALUES (2, N'Bruno');
```

Erro 213: *Column name or number of supplied values does not match table definition*. A tabela tem três colunas, e você mandou dois valores. Com a lista de colunas, o mesmo comando continua funcionando depois da mudança:

```sql
INSERT INTO dbo.TesteEstilo (Id, Nome) VALUES (2, N'Bruno');
```

Limpando:

```sql
DROP VIEW  dbo.vw_TesteEstilo;
DROP TABLE dbo.TesteEstilo;
```

### 4. Deixe a ferramenta formatar

Ninguém precisa alinhar espaço na mão:

- **VS Code com a extensão MSSQL:** tem um formatador de T-SQL (em preview). Selecione o código e use **Format Document** (**Shift+Alt+F**). Dá para configurar maiúsculas, quebras de linha e até formatar sozinho ao salvar.
- **Poor SQL** ([poorsql.com](https://poorsql.com/)): formatador gratuito que roda no navegador. Cole a query bagunçada do item 1 e veja o resultado.

Cole a versão bagunçada em um deles e compare com a que eu arrumei à mão. Não precisa ficar idêntico: o importante é o time inteiro usar o mesmo padrão.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Convenções de sintaxe do Transact-SQL (inclui o aviso sobre o ponto e vírgula)](https://learn.microsoft.com/pt-br/sql/t-sql/language-elements/transact-sql-syntax-conventions-transact-sql)
- [Identificadores de banco de dados (regras para nomes)](https://learn.microsoft.com/pt-br/sql/relational-databases/databases/database-identifiers)
- [Palavras-chave reservadas](https://learn.microsoft.com/pt-br/sql/t-sql/language-elements/reserved-keywords-transact-sql)
- [sp_refreshview](https://learn.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-refreshview-transact-sql) e [CREATE VIEW](https://learn.microsoft.com/pt-br/sql/t-sql/statements/create-view-transact-sql)
- [CREATE PROCEDURE (sobre o prefixo sp_)](https://learn.microsoft.com/pt-br/sql/t-sql/statements/create-procedure-transact-sql)
- [Formatar T-SQL na extensão MSSQL para VS Code](https://learn.microsoft.com/pt-br/sql/tools/visual-studio-code-extensions/mssql/mssql-sql-formatter)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [Aaron Bertrand](https://sqlblog.org/): MVP de longa data, autor da série "Bad habits to kick", com dezenas de maus hábitos de T-SQL e por que evitar cada um.
- [Brent Ozar](https://www.brentozar.com/): tem ótimos textos sobre como o jeito de escrever a query muda o desempenho.
