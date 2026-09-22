---
title: "Relacional ou NoSQL? E onde o SQL Server entra nessa história"
description: "O que é um banco relacional, o que muda num banco NoSQL e como o SQL Server se compara com PostgreSQL, MySQL e Oracle."
date: 2026-09-22T08:02:00-04:00
weight: 2
roadmap: "sgbd"
tags: ["fundamentos", "iniciante", "nosql"]
---

No post anterior a gente viu que um banco de dados guarda, protege e consulta dados. Mas "banco de dados" é um nome grande, e embaixo dele cabem ideias bem diferentes. Vamos falar das duas famílias que você mais vai ouvir: **relacional** e **NoSQL**.

## O modelo relacional

Em 1970, um pesquisador da IBM chamado Edgar F. Codd publicou um artigo propondo organizar dados em **relações**, que é o nome matemático do que a gente chama de tabela. A ideia pegou tanto que, mais de cinquenta anos depois, continua sendo o jeito mais usado de guardar dado de negócio no mundo.

O que define um banco relacional:

- **Dados em tabelas** com linhas e colunas, e cada coluna com um tipo definido (número, texto, data...).
- **Relacionamentos por chaves:** o pedido guarda o `ClienteId`, e é isso que liga o pedido ao cliente.
- **Schema definido antes:** você cria a tabela dizendo quais colunas ela tem, e só depois grava. O nome técnico disso é *schema-on-write*.
- **Transações ACID:** ou a operação acontece inteira, ou não acontece. Não existe "metade de uma transferência bancária". Esse assunto ganha post próprio mais pra frente.
- **SQL** como linguagem para consultar e alterar.

## E o NoSQL?

"NoSQL" virou nome de um monte de bancos que **não seguem o modelo de tabelas**. Eles apareceram forte nos anos 2000, quando empresas como Google e Amazon tinham volumes e padrões de acesso que o modelo relacional tradicional não atendia bem. Não é uma coisa só; são várias famílias:

| Família | Como guarda | Exemplos | Bom para |
|---|---|---|---|
| Documentos | Documentos JSON, cada um com a estrutura que quiser | MongoDB, Azure Cosmos DB | Catálogos, conteúdo, dados com formato variável |
| Chave-valor | Uma chave aponta para um valor, e só | Redis, DynamoDB | Cache, sessão de usuário, contadores |
| Colunar (wide-column) | Linhas com colunas variáveis, distribuídas em muitas máquinas | Cassandra | Escrita massiva, telemetria, séries temporais |
| Grafos | Nós e arestas | Neo4j | Redes sociais, recomendação, detecção de fraude |

O que eles costumam trocar em relação ao relacional: **schema flexível** (cada documento pode ter campos diferentes), **escala horizontal** mais simples (espalhar o dado em muitos servidores) e, em muitos casos, **consistência eventual**: o dado gravado num servidor demora um pouco para aparecer nos outros.

## Qual é melhor?

Nenhum. Essa é a resposta chata, e é a verdadeira. É ferramenta: depende do problema.

Pedido, pagamento, estoque, nota fiscal, folha de pagamento: dado que tem regra, relacionamento e não pode ficar inconsistente. Aqui o relacional brilha, e é por isso que a maioria dos sistemas de negócio roda em banco relacional.

Cache de sessão de um site com milhões de acessos, feed de rede social, telemetria de sensores: aí um NoSQL pode fazer muito mais sentido.

E a fronteira ficou borrada. Os bancos relacionais modernos aprenderam a guardar JSON, grafos e até vetores para IA. Vários NoSQL passaram a oferecer transações e linguagens parecidas com SQL.

## Onde o SQL Server fica

O SQL Server é o banco relacional da Microsoft. Ele nasceu em 1989 de uma parceria com a Sybase e desde 2017 roda também em Linux e em containers. Olhando os quatro relacionais mais conhecidos:

| | Licença | Onde costuma brilhar |
|---|---|---|
| **SQL Server** | Comercial (com edições gratuitas: Developer e Express) | Empresas no ecossistema Microsoft (.NET, Azure, Power BI), ferramentas de administração maduras |
| **PostgreSQL** | Open source | Extensibilidade, padrão SQL, muito usado em startups e na nuvem |
| **MySQL** | Open source (mantido pela Oracle) | Aplicações web, muito popular com PHP e WordPress |
| **Oracle** | Comercial | Grandes corporações, bancos e governo, cargas enormes |

O SQL Server também é **multimodelo**: além das tabelas, ele trabalha com JSON (com tipo nativo a partir do 2025), grafos, dados geográficos e vetores.

Por que este blog é focado em SQL Server? Porque é onde eu trabalho há quase 20 anos e é o que eu conheço de verdade. Mas quase tudo dos fundamentos vale para qualquer banco relacional, e quando algo for específico do SQL Server eu aviso.

## Bora pra prática

Vamos ver o **mesmo pedido** das duas formas: do jeito relacional, espalhado em tabelas, e do jeito documento, tudo junto num JSON. Tudo no próprio SQL Server.

Se ainda não criou o banco Loja, volte ao post anterior e rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

{{< callout type="info" >}}
As queries abaixo usam `JOIN` e `FOR JSON`, que a gente ainda não viu. Não se preocupe com a sintaxe agora: a ideia é só ver o formato do resultado. Cada coisa ganha seu post.
{{< /callout >}}

### O pedido no formato relacional

```sql
USE Loja;

SELECT p.PedidoId,
       p.DataPedido,
       c.Nome       AS Cliente,
       pr.Nome      AS Produto,
       i.Quantidade,
       i.PrecoUnitario
FROM dbo.Pedidos      AS p
JOIN dbo.Clientes     AS c  ON c.ClienteId  = p.ClienteId
JOIN dbo.ItensPedido  AS i  ON i.PedidoId   = p.PedidoId
JOIN dbo.Produtos     AS pr ON pr.ProdutoId = i.ProdutoId
WHERE p.PedidoId = 1;
```

Duas linhas: uma para o notebook, outra para o mouse. O cliente e a data se repetem **no resultado**, mas no banco estão guardados uma vez só, cada um na sua tabela.

### O mesmo pedido como documento

```sql
SELECT p.PedidoId,
       p.DataPedido,
       c.Nome AS Cliente,
       (
           SELECT pr.Nome AS Produto,
                  i.Quantidade,
                  i.PrecoUnitario
           FROM dbo.ItensPedido AS i
           JOIN dbo.Produtos    AS pr ON pr.ProdutoId = i.ProdutoId
           WHERE i.PedidoId = p.PedidoId
           FOR JSON PATH
       ) AS Itens
FROM dbo.Pedidos  AS p
JOIN dbo.Clientes AS c ON c.ClienteId = p.ClienteId
WHERE p.PedidoId = 1
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
```

O resultado é um documento só, mais ou menos assim:

```json
{
  "PedidoId": 1,
  "DataPedido": "2026-01-05",
  "Cliente": "Maria Silva",
  "Itens": [
    { "Produto": "Notebook 15\"", "Quantidade": 1, "PrecoUnitario": 4299.90 },
    { "Produto": "Mouse sem fio", "Quantidade": 1, "PrecoUnitario": 89.90 }
  ]
}
```

É assim que um banco de documentos como o MongoDB guardaria esse pedido: tudo junto, pronto para entregar para uma API.

Agora pense: **e se a Maria mudar de nome?** No relacional, você altera uma linha em `Clientes`. No modelo de documentos, o nome dela está copiado dentro de cada pedido, e você teria que atualizar todos. Em compensação, para **ler** o pedido inteiro, o documento não precisa juntar nada.

Esse é o resumo da troca entre os dois mundos: o relacional otimiza consistência e flexibilidade de consulta; o documento otimiza ler o objeto inteiro de uma vez.

