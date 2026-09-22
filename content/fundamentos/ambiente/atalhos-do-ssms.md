---
title: "Atalhos do SSMS que vão mudar o seu dia"
description: "Os atalhos de teclado que mais economizam tempo no SSMS, a edição em bloco, snippets e como criar os seus próprios atalhos de consulta."
date: 2026-02-13T08:00:00-04:00
weight: 6
roadmap: "ssms-atalhos"
tags: ["fundamentos", "ambiente", "ssms", "produtividade"]
---

Você vai passar muitas horas no SSMS. Meia dúzia de atalhos bem aprendidos economizam um tempo enorme, e alguns ainda evitam acidentes. Separei os que eu mais uso.

## Os essenciais

| Atalho | O que faz |
|---|---|
| **F5** | Executa. Se tiver texto selecionado, executa **só a seleção**. |
| **Ctrl+F5** | Só verifica a sintaxe, sem executar. |
| **Alt+Break** | Cancela a query que está rodando. |
| **Ctrl+N** | Nova janela de query com a conexão atual. |
| **Ctrl+R** | Mostra ou esconde o painel de resultados. |
| **F6** | Alterna o cursor entre o editor e os resultados. |
| **Ctrl+L** | Mostra o plano de execução **estimado** (sem executar). |
| **Ctrl+M** | Liga o plano de execução **real** para as próximas execuções. |
| **Ctrl+D / Ctrl+T / Ctrl+Shift+F** | Resultado em grade / em texto / em arquivo. |

## Editando mais rápido

| Atalho | O que faz |
|---|---|
| **Ctrl+K, Ctrl+C** | Comenta as linhas selecionadas. |
| **Ctrl+K, Ctrl+U** | Descomenta. |
| **Ctrl+Shift+U / Ctrl+Shift+L** | Deixa o texto em MAIÚSCULAS / minúsculas. |
| **Ctrl+G** | Vai para uma linha específica. Útil quando o erro diz "Line 187". |
| **Shift+Alt+setas** (ou **Alt** + arrastar o mouse) | Seleção em bloco: edita várias linhas ao mesmo tempo. |
| **Ctrl+Shift+R** | Atualiza o IntelliSense. Resolve o sublinhado vermelho em tabela que você acabou de criar. |
| **Ctrl+K, Ctrl+X** | Insere um *snippet* (modelo de código). |
| **Ctrl+K, Ctrl+S** | Envolve a seleção com `BEGIN...END`, `IF` ou `WHILE`. |
| **Ctrl+Shift+M** | Preenche os parâmetros de um template. |

## Os que rodam procedures

| Atalho | O que faz |
|---|---|
| **Alt+F1** | Roda `sp_help`. Com o nome de uma tabela selecionado, mostra tudo sobre ela. |
| **Ctrl+1** | Roda `sp_who`: quem está conectado. |
| **Ctrl+2** | Roda `sp_lock`: os locks atuais. |

Esses três são **atalhos de consulta**, e você pode criar os seus em **Tools** > **Options** > **Keyboard** > **Query Shortcuts** (em algumas versões, dentro de **Environment**). O truque: se houver texto selecionado quando você aperta o atalho, o SSMS coloca esse texto no final do comando.

{{< callout type="warning" >}}
**O F5 executa só o que está selecionado.** Isso é ótimo para rodar um pedaço do script, e perigoso quando você seleciona sem querer só a primeira linha de um `DELETE`, sem o `WHERE`. Antes de apertar F5 num script com `UPDATE` ou `DELETE`, olhe o que está selecionado.
{{< /callout >}}

## Bora pra prática

Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### 1. Alt+F1 no nome da tabela

Escreva `Clientes` numa janela de query, selecione a palavra com o mouse e aperte **Alt+F1**. Aparecem várias grades: colunas, tipos, identity, índices, constraints. É o jeito mais rápido de conhecer uma tabela que você nunca viu.

Um detalhe: o SSMS monta o comando `sp_help Clientes`. Se você selecionar `dbo.Clientes`, com o ponto, dá erro de sintaxe. Para tabelas fora do `dbo`, selecione o nome **com as aspas**: `'vendas.Pedidos'`.

### 2. Crie o seu atalho de "mostrar 100 linhas"

Em **Tools** > **Options** > **Keyboard** > **Query Shortcuts** (em algumas versões, dentro de **Environment**), na linha do **Ctrl+3**, escreva:

```sql
SELECT TOP (100) * FROM
```

Clique em OK e **abra uma janela nova** (os atalhos valem para janelas abertas depois da mudança). Escreva `dbo.Pedidos`, selecione e aperte **Ctrl+3**. O SSMS monta `SELECT TOP (100) * FROM dbo.Pedidos` e executa.

### 3. Execute só um pedaço

Cole o bloco abaixo, selecione **apenas a segunda linha** e aperte **F5**:

```sql
SELECT COUNT(*) AS TotalClientes FROM dbo.Clientes;
SELECT COUNT(*) AS TotalProdutos FROM dbo.Produtos;
SELECT COUNT(*) AS TotalPedidos  FROM dbo.Pedidos;
```

Só uma grade aparece: a de produtos.

### 4. Seleção em bloco

Cole esta lista de nomes de coluna:

```text
ClienteId
Nome
Email
Cidade
```

Coloque o cursor antes do `C` de `ClienteId`, segure **Shift+Alt** e aperte **seta para baixo** três vezes. Você vai ver um cursor fino ocupando as quatro linhas. Digite `c.` e o prefixo aparece nas quatro de uma vez. Depois faça o mesmo no final das linhas para adicionar as vírgulas.

### 5. IntelliSense desatualizado

```sql
CREATE TABLE dbo.TesteAtalho (Id INT);
GO

SELECT Id FROM dbo.TesteAtalho;
```

É bem possível que `dbo.TesteAtalho` apareça sublinhado de vermelho, mesmo funcionando. O IntelliSense guarda um cache da estrutura do banco. Aperte **Ctrl+Shift+R** e o sublinhado some. Para limpar:

```sql
DROP TABLE dbo.TesteAtalho;
```

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Atalhos de teclado do SQL Server Management Studio (lista completa)](https://learn.microsoft.com/pt-br/ssms/sql-server-management-studio-keyboard-shortcuts)
- [Inserir snippets de Transact-SQL](https://learn.microsoft.com/pt-br/ssms/scripting/insert-transact-sql-snippets)
- [Editor de consultas do SSMS](https://learn.microsoft.com/pt-br/ssms/f1-help/database-engine-query-editor-sql-server-management-studio)
- [sp_help](https://learn.microsoft.com/pt-br/sql/relational-databases/system-stored-procedures/sp-help-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): procure por "SSMS tips"; tem dezenas de artigos de produtividade.
- [SQLAuthority (Pinal Dave)](https://blog.sqlauthority.com/): cheio de dicas curtas de SSMS, inclusive atalhos de consulta personalizados.
