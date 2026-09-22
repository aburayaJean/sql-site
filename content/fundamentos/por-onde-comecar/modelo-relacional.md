---
title: "O modelo relacional — e onde o SQL Server fica entre PostgreSQL, MySQL e Oracle"
description: "Tabelas, chaves e relacionamentos: a ideia que sustenta o SQL Server, e como ele se compara com os outros bancos relacionais."
date: 2026-01-08T08:00:00-04:00
weight: 2
roadmap: "sgbd"
tags: ["fundamentos", "iniciante"]
---

No post anterior a gente viu que um banco de dados guarda, protege e consulta dados, e que o SQL Server é um **SGBD relacional**. Agora vamos entender o que esse "relacional" quer dizer, e onde o SQL Server fica no meio dos outros bancos relacionais que você vai ouvir falar.

## De onde vem o modelo relacional

Em 1970, um pesquisador da IBM chamado Edgar F. Codd publicou um artigo propondo organizar dados em **relações**, que é o nome matemático do que a gente chama de tabela. A ideia pegou tanto que, mais de cinquenta anos depois, continua sendo o jeito mais usado de guardar dado de negócio no mundo: banco, varejo, governo, saúde, ERP, praticamente tudo passa por um banco relacional.

## O que define um banco relacional

- **Dados em tabelas**, com linhas e colunas, e cada coluna com um tipo definido: número, texto, data...
- **Cada linha tem uma identidade:** a **chave primária**, como o `ClienteId`. Não existem duas linhas com a mesma chave.
- **Tabelas se relacionam por chaves:** o pedido guarda o `ClienteId` do cliente que comprou. Essa coluna é uma **chave estrangeira**, e é ela que liga o pedido ao cliente. Daí o nome "relacional".
- **Estrutura definida antes:** você cria a tabela dizendo quais colunas ela tem, e só depois grava.
- **Regras garantidas pelo banco:** não dá para criar um pedido para um cliente que não existe, nem apagar um cliente que tem pedidos, se você não quiser que isso aconteça.
- **Transações ACID:** ou a operação acontece inteira, ou não acontece. Não existe "metade de uma transferência bancária". Esse assunto ganha post próprio mais pra frente.
- **SQL** como linguagem para consultar e alterar tudo isso.

O grande ganho desse modelo é que **cada informação mora num lugar só**. O nome da Maria está uma vez na tabela `Clientes`; os pedidos só apontam para ela. Mudou o nome, mudou em um lugar, e todo o resto enxerga a mudança.

## SQL Server, PostgreSQL, MySQL e Oracle

Todos seguem o modelo relacional e falam SQL. O que muda é licença, ecossistema e onde cada um costuma brilhar:

| | Licença | Onde costuma brilhar |
|---|---|---|
| **SQL Server** | Comercial (com edições gratuitas: Developer e Express) | Empresas no ecossistema Microsoft (.NET, Azure, Power BI), ferramentas de administração maduras |
| **PostgreSQL** | Open source | Extensibilidade, aderência ao padrão SQL, muito usado em startups e na nuvem |
| **MySQL** | Open source (mantido pela Oracle) | Aplicações web, muito popular com PHP e WordPress |
| **Oracle** | Comercial | Grandes corporações, bancos e governo, cargas enormes |

O SQL Server é o banco relacional da Microsoft. Nasceu em 1989 de uma parceria com a Sybase e, desde 2017, roda também em Linux e em containers. Além de tabelas, ele trabalha com JSON (com tipo nativo a partir do 2025), grafos, dados geográficos e vetores para IA, e cada um desses recursos tem trilha própria aqui no blog.

Por que este blog é focado em SQL Server? Porque é onde eu trabalho há quase 20 anos e é o que eu conheço de verdade. Mas quase tudo dos Fundamentos vale para qualquer banco relacional, e quando algo for específico do SQL Server eu aviso.

## Bora pra prática

Vamos ver o modelo relacional funcionando no banco Loja: descobrir como as tabelas se relacionam, montar um pedido juntando as tabelas e ver o banco defendendo as regras. Se ainda não criou o banco, volte ao post anterior e rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### Quem se relaciona com quem

```sql
USE Loja;

SELECT fk.name                              AS Relacionamento,
       OBJECT_NAME(fk.parent_object_id)     AS TabelaQueAponta,
       COL_NAME(fkc.parent_object_id, fkc.parent_column_id)         AS Coluna,
       OBJECT_NAME(fk.referenced_object_id) AS TabelaApontada,
       COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ColunaApontada
FROM   sys.foreign_keys        AS fk
JOIN   sys.foreign_key_columns AS fkc ON fkc.constraint_object_id = fk.object_id
ORDER  BY TabelaQueAponta;
```

Três relacionamentos: `ItensPedido` aponta para `Pedidos` e para `Produtos`, e `Pedidos` aponta para `Clientes`. Esse é o "desenho" do banco, guardado dentro do próprio banco.

### Juntando as tabelas

{{< callout type="info" >}}
A query abaixo usa `JOIN`, que ganha uma trilha inteira mais pra frente. Por enquanto, leia assim: "junte o pedido com o cliente dele, com os itens e com os produtos, usando as chaves".
{{< /callout >}}

```sql
SELECT p.PedidoId,
       p.DataPedido,
       c.Nome       AS Cliente,
       pr.Nome      AS Produto,
       i.Quantidade,
       i.PrecoUnitario
FROM   dbo.Pedidos     AS p
JOIN   dbo.Clientes    AS c  ON c.ClienteId  = p.ClienteId
JOIN   dbo.ItensPedido AS i  ON i.PedidoId   = p.PedidoId
JOIN   dbo.Produtos    AS pr ON pr.ProdutoId = i.ProdutoId
WHERE  p.PedidoId = 1;
```

Duas linhas: o notebook e o mouse do primeiro pedido da Maria. O nome dela aparece repetido **no resultado**, mas no banco está guardado uma vez só.

### O banco defendendo as regras

Tente criar um pedido para o cliente 99, que não existe:

```sql
INSERT INTO dbo.Pedidos (ClienteId, DataPedido, Status)
VALUES (99, '2026-01-10', N'Pendente');
```

Erro 547: *The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Pedidos_Clientes"*. O banco se recusou a gravar um pedido "órfão".

Agora tente apagar a Maria, que tem pedidos:

```sql
DELETE FROM dbo.Clientes
WHERE  ClienteId = 1;
```

Erro 547 de novo, agora com o `DELETE`. Se o banco deixasse, os pedidos dela ficariam apontando para ninguém.

Na planilha do post anterior, nada disso seria impedido. Essa é a diferença entre guardar dados e **proteger** dados, e é o coração do modelo relacional.
