---
title: "O que é um banco de dados (e por que sua planilha não dá conta)"
description: "Do Excel ao banco: o problema que um banco de dados resolve, o que é um SGBD e como sair daqui com um SQL Server rodando."
date: 2026-09-22
weight: 1
tags: ["fundamentos", "iniciante"]
---

Vamos começar pelo começo de verdade: **o que é um banco de dados?**

A resposta de livro é "uma coleção organizada de dados". Tá certo, mas não ajuda muito. Então vou contar uma história que eu já vi acontecer umas cem vezes.

## Tudo começa numa planilha

Uma loja pequena começa a vender e alguém cria uma planilha para controlar as vendas. Faz todo o sentido: é rápido, todo mundo sabe usar, resolve.

| Data       | Cliente          | Telefone        | Produto          | Preço    | Qtd |
|------------|------------------|-----------------|------------------|----------|-----|
| 05/01/2026 | Maria Silva      | (65) 99999-1111 | Notebook 15"     | 4.299,90 | 1   |
| 05/01/2026 | Maria Silva      | (65) 99999-1111 | Mouse sem fio    | 89,90    | 1   |
| 12/01/2026 | João Pereira     | (11) 98888-2222 | Teclado mecânico | 349,00   | 1   |
| 02/02/2026 | Maria da Silva   | (65) 99999-3333 | Monitor 27"      | 1.599,00 | 2   |
| 14/04/2026 | João Pereira     | (11) 98888-2222 | Notebook 15"     | 4.199,90 | 1   |

Olha com calma e repara nos problemas:

- **A Maria aparece três vezes**, e na terceira ela virou "Maria da Silva" com outro telefone. É a mesma pessoa? Ela trocou de número? Alguém digitou errado? A planilha não sabe, e em pouco tempo ninguém mais sabe.
- **O Notebook custa 4.299,90 numa linha e 4.199,90 na outra.** Foi desconto? Mudou o preço? Erro de digitação?
- **Nada impede besteira.** Dá para digitar "abc" na coluna Qtd, deixar o cliente em branco ou vender um produto que não existe.
- **Duas pessoas não trabalham ao mesmo tempo.** Aí nasce o famoso `Vendas_FINAL_v3_agora_vai.xlsx`.
- **Tem limite.** Uma aba do Excel aguenta pouco mais de 1 milhão de linhas. Parece muito, até a loja crescer.
- **Se o arquivo corromper no meio de uma gravação,** boa sorte.

Nada disso é culpa da planilha. Ela foi feita para **analisar** dados, não para ser o lugar onde a verdade do negócio mora. Para isso existe o banco de dados.

## Então, o que é um banco de dados?

Um banco de dados é um conjunto de dados organizados de um jeito que o computador consegue **guardar, proteger e consultar** com eficiência. Quem faz esse trabalho é um software chamado **SGBD**, Sistema Gerenciador de Banco de Dados. O SQL Server, que é o foco deste blog, é um SGBD. PostgreSQL, MySQL e Oracle também são.

Na prática, o SGBD resolve exatamente os problemas da planilha:

- **Integridade:** você define regras e o banco obriga todo mundo a seguir. Quantidade tem que ser número. Todo pedido tem que ter um cliente que existe. Um e-mail não pode se repetir.
- **Concorrência:** centenas de pessoas lendo e gravando ao mesmo tempo, sem uma pisar no dado da outra.
- **Segurança:** o vendedor vê os pedidos, mas não vê o salário de ninguém.
- **Recuperação:** se o servidor desligar no meio de uma venda, o banco volta num estado consistente. E dá para fazer backup e voltar no tempo.
- **Consulta:** você faz perguntas ("quanto a Maria comprou este ano?") numa linguagem feita para isso, o **SQL**.
- **Escala:** de mil a bilhões de linhas.

## Tabelas: cada assunto no seu lugar

Num banco relacional, os dados ficam em **tabelas**, parecidas com uma aba de planilha: linhas e colunas. A grande diferença está no jeito de organizar: **cada tabela cuida de um assunto só.**

Aquela planilha, num banco, vira pelo menos três tabelas:

- **Clientes:** cada cliente aparece uma vez, com um número que identifica ele (o `ClienteId`).
- **Produtos:** cada produto aparece uma vez, com seu preço.
- **Pedidos:** cada venda aponta para o cliente e para o produto pelo número, sem repetir o nome e o telefone.

Se a Maria trocar de telefone, você altera **uma linha** na tabela de clientes e pronto: todos os pedidos dela "enxergam" o número novo. Esse jeito de separar os dados tem nome (normalização) e vai ganhar uma série inteira aqui no blog.

{{< callout type="info" >}}
**Então planilha é ruim?** Não. Planilha é ótima para análise, simulação e relatório. O problema é usar planilha como **sistema**. O caminho natural é: o banco guarda a verdade, e a planilha (ou o Power BI) lê do banco para analisar.
{{< /callout >}}

## Bora pra prática

Quatro passos: um exercício de cabeça, instalar o SQL Server, rodar a primeira query e criar o banco que vai acompanhar o blog.

### 1. Exercício: quebre a planilha em tabelas

Pegue a planilha lá de cima e tente separar em tabelas. Quais colunas ficam em cada uma? Como o pedido "sabe" quem é o cliente? Pense um pouco antes de abrir a resposta.

<details>
<summary>Ver uma resposta possível</summary>

- **Clientes** (ClienteId, Nome, Telefone)
- **Produtos** (ProdutoId, Nome, Preço)
- **Pedidos** (PedidoId, ClienteId, Data)
- **ItensPedido** (PedidoId, ProdutoId, Quantidade, PrecoUnitario)

Por que existe uma tabela de itens? Porque um pedido pode ter vários produtos, como o primeiro pedido da Maria (notebook + mouse). E por que o item guarda o preço, se o produto já tem preço? Porque o preço do produto muda com o tempo, e o pedido precisa lembrar quanto foi cobrado **naquele dia**. Isso explica os 4.299,90 e os 4.199,90 da planilha.

</details>

### 2. Instale um SQL Server

Tem dois caminhos fáceis. Os dois são gratuitos e cada um vai ganhar um post detalhado na parte de Ambiente.

**Windows:** baixe o **SQL Server Developer Edition** no site da Microsoft. É a versão completa, liberada para desenvolvimento e estudo (só não pode usar em produção). No SQL Server 2025 ela vem em dois sabores, Enterprise Developer e Standard Developer. Para estudar, qualquer um serve.

**Mac, Linux ou Windows com Docker:** uma linha e você tem um SQL Server rodando:

```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Senha@Forte2026" -p 1433:1433 --name sqlserver -d mcr.microsoft.com/mssql/server:2025-latest
```

A senha precisa ter pelo menos 8 caracteres, com maiúscula, minúscula, número e símbolo. Se não tiver, o container sobe e morre em seguida. No Mac com chip Apple, deixe ligada a emulação Rosetta nas configurações do Docker Desktop.

Para conectar, instale o **SSMS** (SQL Server Management Studio), no Windows, ou o **VS Code com a extensão MSSQL**, em qualquer sistema. No Docker, conecte em `localhost,1433` com o usuário `sa` e a senha que você definiu, marcando a opção **Trust server certificate**.

### 3. A primeira query

Conectou? Abra uma janela de query e rode:

```sql
SELECT @@VERSION;
```

Se apareceu um texto começando com "Microsoft SQL Server", parabéns: você tem um banco de dados rodando.

### 4. Crie o banco Loja

Por último, baixe e rode o script de setup:

**[⬇ 00-loja-setup.sql](/sql-site/scripts/fundamentos/00-loja-setup.sql)**

Ele cria o banco **Loja** com as tabelas `Clientes`, `Produtos`, `Pedidos` e `ItensPedido`, exatamente a resposta do exercício, já com dados. Vamos usar esse banco em quase todos os posts daqui para frente. E se um dia você fizer bagunça nele, é só rodar o script de novo: ele apaga tudo e recria do zero.

No fim da execução aparece uma conferência com a quantidade de linhas de cada tabela: 8 clientes, 8 produtos, 12 pedidos e 18 itens.

---
