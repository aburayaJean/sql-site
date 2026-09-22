---
title: "Instalar o SSMS e conhecer a interface"
description: "Como instalar o SQL Server Management Studio 22 e para que serve cada parte da tela: Object Explorer, editor, Results, Messages e barra de status."
date: 2026-02-09T08:00:00-04:00
weight: 4
roadmap: "ssms-instalar"
tags: ["fundamentos", "ambiente", "ssms"]
---

O **SSMS** (SQL Server Management Studio) é a ferramenta que você vai abrir todo dia. É onde você escreve queries, navega pelos bancos, cria objetos, faz backup, olha planos de execução e administra a instância. Vale conhecer bem.

## Instalando

O SSMS é **gratuito** e **só roda no Windows**. Se você usa Mac ou Linux, a alternativa é o VS Code com a extensão MSSQL, que tem post próprio nesta trilha.

A versão atual, o **SSMS 22**, é instalada pelo **Visual Studio Installer**:

1. Baixe o instalador (`vs_SSMS.exe`) na página oficial de instalação do SSMS.
2. Execute. Ele abre o Visual Studio Installer.
3. Clique em **Install** e espere.
4. As atualizações futuras também são feitas pelo Visual Studio Installer.

O SSMS 22 conecta em SQL Server 2014 para cima, no Azure SQL e no SQL do Microsoft Fabric. Ele pode ser instalado lado a lado com versões antigas, se você precisar.

## Um tour pela tela

Ao abrir, a primeira coisa que aparece é a janela **Connect to Server**. Conecte no seu SQL Server (no próximo post a gente destrincha cada opção dessa tela). Depois disso, repare nas partes:

**Object Explorer** (à esquerda, atalho **F8**). A árvore com tudo o que existe na instância: bancos, tabelas, logins, jobs... Clicar com o botão direito em qualquer coisa mostra o que dá para fazer com ela. Tem uma trilha inteira no blog só sobre os nós do Object Explorer.

**Query Editor** (o centro). Onde você escreve SQL. Abra uma janela nova com **Ctrl+N** ou no botão **New Query**.

**Seletor de banco** (na barra de ferramentas). A caixinha que mostra em qual banco a janela está. Trocar ali é o mesmo que rodar `USE`.

**Results e Messages** (embaixo). A aba **Results** mostra as linhas; a aba **Messages** mostra avisos, erros, `PRINT` e o famoso "(8 rows affected)".

**Barra de status** (rodapé da janela de query). Mostra o servidor, o login, o banco, o número da sessão, o tempo de execução e quantas linhas voltaram. Olhe para ela antes de rodar qualquer coisa perigosa: é ali que você confere se está no servidor certo.

**Properties** (**F4**). Mostra os detalhes do que estiver selecionado: da conexão, de um objeto, de um operador do plano de execução.

**Template Explorer** (**Ctrl+Alt+T**). Modelos prontos de script para criar banco, tabela, índice, login e muito mais.

As versões novas do SSMS também têm tema escuro e integração com o GitHub Copilot. O Copilot ajuda, mas revise sempre o SQL que ele sugere; tem post sobre isso na trilha de IA.

## Bora pra prática

Conecte no seu SQL Server e use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### 1. Onde eu estou?

Abra uma janela nova (**Ctrl+N**), escolha o banco **Loja** no seletor e rode:

```sql
SELECT DB_NAME()      AS BancoAtual,
       SUSER_SNAME()  AS MeuLogin,
       @@SPID         AS MinhaSessao;
```

Agora compare o resultado com a **barra de status**: o banco, o login e o número da sessão (entre parênteses, ao lado do login) são os mesmos.

### 2. Várias grades de resultado

Rode as duas consultas juntas:

```sql
SELECT TOP (3) Nome, Preco FROM dbo.Produtos ORDER BY Preco DESC;
SELECT TOP (3) Nome, Cidade FROM dbo.Clientes ORDER BY Nome;
```

Cada `SELECT` gera uma grade separada na aba Results.

### 3. A aba Messages

```sql
PRINT N'Olá, Messages!';

UPDATE dbo.Produtos
SET    Preco = Preco
WHERE  Categoria = N'Móveis';
```

Veja a aba **Messages**: aparece o texto do `PRINT` e o "(2 rows affected)" do `UPDATE`. Agora rode de novo com `SET NOCOUNT ON;` na primeira linha: o aviso de linhas afetadas desaparece. Em procedures, isso economiza tráfego de rede e é boa prática (tem post sobre isso).

### 4. Deixe o SSMS escrever o script por você

No Object Explorer, expanda **Databases** > **Loja** > **Tables**, clique com o botão direito em **dbo.Clientes** e vá em **Script Table as** > **CREATE To** > **New Query Editor Window**.

O SSMS gera o `CREATE TABLE` completo da tabela, com constraints e tudo. Esse recurso existe para praticamente qualquer objeto e é um jeito ótimo de aprender a sintaxe.

Clique com o botão direito de novo na tabela e escolha **Select Top 1000 Rows**. Ele monta e roda o `SELECT` para você.

### 5. Use um template

Abra o **Template Explorer** (**Ctrl+Alt+T**), expanda **Database** e dê dois cliques em **Create Database**. O script abre cheio de parâmetros entre `< >`. Aperte **Ctrl+Shift+M**, preencha o nome do banco (por exemplo, `TesteTemplate`) e clique em OK. Pronto, o script foi completado sozinho. Rode, veja o banco aparecer e depois apague:

```sql
DROP DATABASE TesteTemplate;
```

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Instalar o SQL Server Management Studio](https://learn.microsoft.com/pt-br/ssms/install/install)
- [Conectar com o SQL Server Management Studio](https://learn.microsoft.com/pt-br/ssms/quickstarts/ssms-connect)
- [Editor de consultas do SSMS](https://learn.microsoft.com/pt-br/ssms/f1-help/database-engine-query-editor-sql-server-management-studio)
- [Dicas e truques do SSMS](https://learn.microsoft.com/pt-br/ssms/tutorials/ssms-tricks)
- [Template Explorer](https://learn.microsoft.com/pt-br/ssms/template/template-explorer)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem uma categoria inteira de dicas de SSMS, com muito truque que pouca gente conhece.
- [SQLAuthority (Pinal Dave)](https://blog.sqlauthority.com/): um dos blogs de SQL Server mais antigos, com milhares de dicas curtas e diretas, inclusive de SSMS.
