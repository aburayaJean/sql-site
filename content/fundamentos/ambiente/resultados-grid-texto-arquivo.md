---
title: "Resultados em grade, texto e arquivo: copiar e exportar do jeito certo"
description: "Como mandar o resultado para grade, texto ou arquivo no SSMS, copiar com cabeçalho, exportar para CSV, JSON ou Excel e as pegadinhas de cada formato."
date: 2026-02-16T08:00:00-04:00
weight: 7
roadmap: "ssms-resultados"
tags: ["fundamentos", "ambiente", "ssms"]
---

Rodou a query, apareceu o resultado. E agora você precisa mandar isso para alguém, colar numa planilha ou salvar num arquivo. Parece bobo, mas tem jeito certo e tem pegadinha.

## Os três destinos

O SSMS pode mandar o resultado para três lugares. A escolha vale para a janela de query atual:

| Destino | Atalho | Quando usar |
|---|---|---|
| **Grade** (padrão) | **Ctrl+D** | O dia a dia. Dá para ordenar, copiar e salvar. |
| **Texto** | **Ctrl+T** | Colar em e-mail, chamado ou documentação; comparar saídas. |
| **Arquivo** | **Ctrl+Shift+F** | Resultado grande que você não precisa ver na tela. |

Depois de trocar o destino, execute a query de novo (**F5**).

## Copiando da grade

- **Ctrl+C** copia só os dados selecionados, **sem** o cabeçalho.
- **Ctrl+Shift+C** copia **com** o cabeçalho. É o que você quer quase sempre.
- Para copiar sempre com cabeçalho, ligue a opção em **Tools** > **Options** > **Query Results** > **SQL Server** > **Results to Grid** > **Include column headers when copying or saving the results**.

## Salvando da grade

Clique com o botão direito na grade e escolha **Save Results As...**. Até o SSMS 22.3, os formatos eram CSV e TXT. A partir do **SSMS 22.4.1**, dá para exportar também para **JSON, XML, Excel e Markdown**.

## As pegadinhas

- **CSV e o Excel em português.** O Excel configurado para o Brasil espera ponto e vírgula e vírgula decimal. Um CSV com vírgula como separador pode abrir tudo numa coluna só. Se tiver a exportação direta para Excel, prefira.
- **Texto longo cortado.** Em **texto**, cada coluna mostra por padrão só os primeiros 256 caracteres. Em **grade**, o limite é bem maior, mas também existe. As duas opções ficam em **Tools** > **Options** > **Query Results** > **SQL Server**.
- **Quebras de linha somem** ao copiar da grade, a menos que a opção **Retain CR/LF on copy or save** esteja ligada.
- **O que você vê não é o que está no banco.** A grade mostra `NULL` em amarelo, e ao copiar vira a palavra `NULL` como texto. Se o destino for importar esse arquivo, isso faz diferença.

## Bora pra prática

Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### 1. Uma consulta para exportar

```sql
SELECT p.PedidoId,
       c.Nome                          AS Cliente,
       p.DataPedido,
       p.Status,
       SUM(i.Quantidade * i.PrecoUnitario) AS Total
FROM   dbo.Pedidos     AS p
JOIN   dbo.Clientes    AS c ON c.ClienteId = p.ClienteId
JOIN   dbo.ItensPedido AS i ON i.PedidoId  = p.PedidoId
GROUP  BY p.PedidoId, c.Nome, p.DataPedido, p.Status
ORDER  BY p.PedidoId;
```

Doze linhas, uma por pedido. Clique em qualquer célula, aperte **Ctrl+A** e depois **Ctrl+Shift+C**. Cole num e-mail ou num bloco de notas: os dados vêm com cabeçalho, separados por tabulação. Cole no Excel: cada coluna cai no lugar certo.

### 2. Resultado em texto

Aperte **Ctrl+T** e rode a mesma consulta de novo. O resultado vira texto alinhado em colunas, bom para colar num chamado. Volte para a grade com **Ctrl+D**.

### 3. O corte de 256 caracteres

```sql
SELECT REPLICATE(N'SQL ', 100) AS TextoLongo;   -- 400 caracteres
```

Rode em **texto** (**Ctrl+T**) e veja o texto parar no meio. Rode em **grade** (**Ctrl+D**), dê dois cliques na célula e copie: agora ele vem inteiro.

### 4. Exportar para arquivo

Na grade da consulta do item 1, clique com o botão direito > **Save Results As...** e salve como CSV. Se o seu SSMS for 22.4.1 ou mais novo, repita escolhendo **JSON** e **Excel** e compare os três arquivos.

### 5. E sem o SSMS?

Às vezes você quer um JSON sem depender de exportação da ferramenta. O próprio SQL Server gera:

```sql
SELECT ClienteId, Nome, Cidade, UF
FROM   dbo.Clientes
FOR JSON PATH;
```

O resultado aparece como um link na grade. Clique e ele abre numa janela nova. O `FOR JSON` ganha post próprio na trilha de JSON e XML.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Resultados de consulta no SQL Server Management Studio](https://learn.microsoft.com/pt-br/ssms/quickstarts/work-with-query-results)
- [Editor de consultas do SSMS (destinos de resultado)](https://learn.microsoft.com/pt-br/ssms/f1-help/database-engine-query-editor-sql-server-management-studio)
- [Dicas e truques do SSMS (exportação de resultados)](https://learn.microsoft.com/pt-br/ssms/tutorials/ssms-tricks)
- [REPLICATE](https://learn.microsoft.com/pt-br/sql/t-sql/functions/replicate-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem várias comparações de jeitos de exportar dados do SQL Server (SSMS, bcp, PowerShell).
- [SQLAuthority (Pinal Dave)](https://blog.sqlauthority.com/): dicas curtas sobre as opções escondidas do painel de resultados.
