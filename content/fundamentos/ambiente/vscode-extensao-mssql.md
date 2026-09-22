---
title: "VS Code com a extensão MSSQL: SQL Server em qualquer sistema"
description: "A alternativa leve ao SSMS, que roda no Windows, Mac e Linux. Instalação, conexão, execução, exportação e o fim do Azure Data Studio."
date: 2026-02-18T08:00:00-04:00
weight: 8
roadmap: "vscode-mssql"
tags: ["fundamentos", "ambiente", "vscode"]
---

O SSMS é completo, mas só roda no Windows e é pesado. Se você usa Mac ou Linux, ou já vive dentro do VS Code programando, a **extensão MSSQL para o VS Code** resolve muito bem o dia a dia.

## E o Azure Data Studio?

Por alguns anos a Microsoft teve uma terceira ferramenta, o **Azure Data Studio**. Ele foi **aposentado em 28 de fevereiro de 2026** e não recebe mais atualizações nem correções de segurança. A recomendação oficial é migrar para o VS Code com a extensão MSSQL. Se você usava o Azure Data Studio, a extensão tem um assistente que importa suas conexões e configurações.

## SSMS ou VS Code?

| Use o SSMS para... | Use o VS Code para... |
|---|---|
| Administração completa da instância | Escrever e rodar queries no dia a dia |
| SQL Server Agent (jobs, alertas) | Trabalhar no Mac ou no Linux |
| Tudo que tem assistente gráfico (backup, restore, segurança) | Versionar scripts no Git junto com o código da aplicação |
| Trilhas de DBA deste blog | Notebooks SQL, projetos de banco e integração com o Copilot |

Muita gente usa os dois, e tudo bem.

## O que a extensão tem

- **Conexão** por parâmetros ou por *connection string*, com conexões salvas e grupos coloridos (útil para diferenciar produção de desenvolvimento).
- **Object Explorer** com filtros.
- **Grade de resultados** com ordenação e exportação para CSV, JSON, Excel e até `INSERT`.
- **Plano de execução** estimado e real.
- **Containers locais:** cria um SQL Server em Docker direto pela extensão.
- **Notebooks SQL**, **Schema Designer**, **Schema Compare** e **Query Profiler**.
- **Integração com o GitHub Copilot**.

## Bora pra prática

### 1. Instalar

1. Instale o **Visual Studio Code**.
2. Abra a aba de extensões (**Ctrl+Shift+X**; no Mac, **Cmd+Shift+X**).
3. Procure por `mssql` e instale a **SQL Server (mssql)**.
4. Quando aparecer o ícone do **SQL Server** na barra lateral, está pronto.

### 2. Conectar

Clique no ícone do SQL Server e em **Add Connection**. Preencha:

- **Server:** `localhost` (ou `localhost,1433` se for container)
- **Authentication:** Windows ou SQL Login, igual ao SSMS
- **Trust server certificate:** marque, se for o seu ambiente de estudo

Se você não tem SQL Server nenhum instalado, a extensão oferece criar um **container local**: ela cuida da imagem, da porta e da senha.

### 3. Rodar a primeira query

Crie um arquivo `teste.sql`, escolha a conexão (a extensão pergunta, ou use **Ctrl+Shift+C**) e escreva:

```sql
USE Loja;

SELECT Nome, Categoria, Preco
FROM   dbo.Produtos
ORDER  BY Preco DESC;
```

Execute com **Ctrl+Shift+E** (no Mac, **Cmd+Shift+E**). Se ainda não tem o banco Loja, rode antes o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql): abra o arquivo no VS Code e execute igual.

{{< callout type="info" >}}
**Prefere os atalhos do SSMS?** Instale a extensão **MSSQL Database Management Keymap**. Com ela, o **F5** executa, o **Ctrl+L** mostra o plano estimado e o **Ctrl+M** liga o plano real, igual no SSMS.
{{< /callout >}}

### 4. Exportar o resultado

Na grade de resultados, clique com o botão direito e salve como **JSON** e como **CSV**. Abra os dois arquivos e compare. Experimente também salvar como **INSERT**: a extensão gera os comandos para inserir aquelas linhas em outro banco.

### 5. Ver o plano de execução

Com a query ainda aberta, clique em **Estimated Plan** na barra da extensão. O plano aparece como desenho, com os operadores e o custo de cada um. Ler plano de execução tem uma trilha inteira no blog; por enquanto, só saiba onde ele fica.

### 6. Scripts no Git

Uma vantagem que o SSMS não tem: salve os seus `.sql` numa pasta com Git e faça commit junto com o código da aplicação. O controle de versão de banco tem uma trilha própria (DevOps de Banco de Dados).

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Extensão MSSQL para Visual Studio Code](https://learn.microsoft.com/pt-br/sql/tools/visual-studio-code-extensions/mssql/mssql-extension-visual-studio-code)
- [Contêineres locais do SQL Server pela extensão](https://learn.microsoft.com/pt-br/sql/tools/visual-studio-code-extensions/mssql/mssql-local-container)
- [Personalizar os atalhos de teclado da extensão](https://learn.microsoft.com/pt-br/sql/tools/visual-studio-code-extensions/mssql/mssql-keyboard-shortcuts)
- [O que está acontecendo com o Azure Data Studio](https://learn.microsoft.com/pt-br/sql/tools/whats-happening-azure-data-studio)
- [Migrar do Azure Data Studio para a extensão](https://learn.microsoft.com/pt-br/sql/tools/visual-studio-code-extensions/mssql/mssql-azure-data-studio-transition)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem artigos comparando SSMS e VS Code e mostrando os recursos novos da extensão.
- [Dirceu Resende](https://dirceuresende.com/): em português, acompanha as novidades das ferramentas de SQL Server.
