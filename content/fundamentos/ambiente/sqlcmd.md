---
title: "sqlcmd: o SQL Server direto no terminal"
description: "Para que serve o sqlcmd, as duas versões (Go e ODBC), as opções que você vai usar sempre, como rodar scripts, exportar resultado e usar variáveis."
date: 2026-02-20T08:00:00-04:00
weight: 9
roadmap: "sqlcmd"
tags: ["fundamentos", "ambiente", "sqlcmd", "linha-de-comando"]
---

O SSMS é ótimo para trabalhar olhando para a tela. Mas tem hora que você quer rodar um script **sem abrir nada**: num agendamento do Windows, num pipeline de deploy, num servidor sem interface gráfica ou dentro de um container. Para isso existe o **sqlcmd**, o cliente de linha de comando do SQL Server.

Ele faz o básico muito bem: conecta, manda o SQL, mostra ou salva o resultado. E entende o `GO`, igual ao SSMS.

## As duas versões

Hoje existem dois `sqlcmd`, e vale saber qual você tem:

| | **sqlcmd (Go)** | **sqlcmd (ODBC)** |
|---|---|---|
| O que é | A versão moderna, open source | A versão clássica |
| Onde roda | Windows, macOS e Linux | Windows, Linux e macOS (pelo pacote mssql-tools18) |
| Como instala | `winget install sqlcmd` (Windows) ou `brew install sqlcmd` (Mac) | Vem com as ferramentas do SQL Server; também tem instalador próprio |
| Extras | Cria containers (`sqlcmd create mssql`), guarda conexões, saída vertical | Nenhum, mas é o que muitos scripts antigos esperam |

As opções do dia a dia (`-S`, `-E`, `-U`, `-i`, `-o`...) são as mesmas nas duas. Para este post, qualquer uma serve. Se for instalar agora, fique com a **Go**.

## As opções que você vai usar sempre

| Opção | O que faz |
|---|---|
| `-S servidor` | Onde conectar. Mesmo formato do SSMS: `localhost`, `.\SQLEXPRESS`, `localhost,1433` |
| `-E` | Entra com o seu usuário do Windows |
| `-U usuario -P senha` | Entra com login SQL (ex.: `sa` no Docker) |
| `-C` | Confia no certificado do servidor. É o **Trust server certificate** do SSMS |
| `-d banco` | Banco inicial, como um `USE` |
| `-Q "query"` | Roda a query e **sai** |
| `-q "query"` | Roda a query e **fica** no modo interativo |
| `-i arquivo.sql` | Roda um arquivo de script |
| `-o arquivo.txt` | Manda a saída para um arquivo |
| `-v Nome=Valor` | Define uma variável para o script |
| `-b` | Se der erro, para e devolve um código de erro para quem chamou |
| `-W` | Tira os espaços em branco do fim de cada coluna |
| `-s ","` | Troca o separador de colunas |
| `-h -1` | Não imprime o cabeçalho |

{{< callout type="warning" >}}
**Cuidado com o `-P`.** A senha escrita na linha de comando fica no histórico do terminal. No laboratório tudo bem; em produção, prefira `-E` (Windows) ou deixe o sqlcmd **perguntar** a senha: é só não passar o `-P`.
{{< /callout >}}

## Bora pra prática

Os comandos abaixo são para o **PowerShell**. Se o seu SQL Server está no Docker, troque `-E` por `-U sa -P "Senha@Forte2026"` e use `-S localhost,1433`.

### 1. Instalar e conferir

```powershell
winget install sqlcmd
```

Feche e abra o terminal (para ele enxergar o programa novo) e rode:

```powershell
sqlcmd -?
```

Aparece a lista de opções. Se aparecer, está instalado.

### 2. Primeira query

```powershell
sqlcmd -S localhost -E -C -Q "SELECT @@SERVERNAME AS Servidor, @@VERSION AS Versao"
```

Ele conecta, roda, mostra e sai. Sem o `-C`, é bem possível você ver o mesmo erro de certificado que o SSMS mostra, pelo mesmo motivo: o certificado autoassinado.

### 3. Modo interativo

Rode sem `-Q`:

```powershell
sqlcmd -S localhost -E -C
```

Aparece um `1>`. Digite, linha por linha:

```sql
SELECT name FROM sys.databases;
GO
```

Nada acontece até o `GO`. O `1>`, `2>` é o sqlcmd juntando as linhas do batch; o `GO` manda tudo para o servidor. Para sair, digite `EXIT`.

### 4. Rodar o script do banco Loja

Baixe o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql) para uma pasta, entre nela pelo terminal e rode:

```powershell
sqlcmd -S localhost -E -C -i 00-loja-setup.sql
```

Pronto: o banco Loja foi criado (ou recriado) sem abrir o SSMS. É assim que scripts de deploy costumam rodar.

Agora salve a saída num arquivo, para conferir depois:

```powershell
sqlcmd -S localhost -E -C -i 00-loja-setup.sql -o setup-log.txt
```

### 5. Exportar para CSV

```powershell
sqlcmd -S localhost -E -C -d Loja -W -s "," -Q "SET NOCOUNT ON; SELECT ClienteId, Nome, Cidade, UF FROM dbo.Clientes" -o clientes.csv
```

Abra o `clientes.csv`. O `-W` tirou os espaços, o `-s ","` separou por vírgula e o `SET NOCOUNT ON` tirou a linha "(8 rows affected)" do fim. Repare que a segunda linha é uma fileira de tracinhos: o sqlcmd sempre sublinha o cabeçalho. Se você não quiser cabeçalho nenhum, adicione `-h -1`.

Para exportações sérias (arquivos grandes, com aspas e vírgulas no meio do texto), a ferramenta certa é o **bcp**, que tem post próprio na trilha de Administração.

### 6. Variáveis de script

Crie um arquivo `contar.sql` com este conteúdo:

```sql
SET NOCOUNT ON;

SELECT '$(Tabela)' AS Tabela,
       COUNT(*)    AS Linhas
FROM   dbo.$(Tabela);
```

O `$(Tabela)` não é T-SQL: o sqlcmd troca esse pedaço pelo valor que você passar **antes** de mandar o texto para o servidor. Rode:

```powershell
sqlcmd -S localhost -E -C -d Loja -i contar.sql -v Tabela=Clientes
sqlcmd -S localhost -E -C -d Loja -i contar.sql -v Tabela=Pedidos
```

O mesmo script serve para qualquer tabela. É assim que um script de deploy roda igual em desenvolvimento, homologação e produção, mudando só as variáveis.

{{< callout type="info" >}}
**PowerShell e o `$(...)`.** No PowerShell, `$(...)` dentro de aspas **duplas** é um comando do próprio PowerShell. Se um dia você usar variável do sqlcmd dentro do `-Q`, use aspas **simples**: `-Q 'SELECT COUNT(*) FROM dbo.$(Tabela)'`. Colocar o SQL num arquivo, como no exemplo acima, evita essa dor de cabeça.
{{< /callout >}}

### 7. Parar no primeiro erro

Crie `com-erro.sql`:

```sql
PRINT 'Passo 1';
GO
SELECT 1/0;
GO
PRINT 'Passo 3';
GO
```

Rode sem e com o `-b`:

```powershell
sqlcmd -S localhost -E -C -i com-erro.sql
sqlcmd -S localhost -E -C -i com-erro.sql -b
$LASTEXITCODE
```

Sem `-b`, ele mostra o erro e segue para o Passo 3. Com `-b`, ele para no erro e o `$LASTEXITCODE` vem diferente de zero. É isso que um pipeline de deploy usa para saber que algo deu errado.

### 8. O modo SQLCMD dentro do SSMS

O SSMS também entende os comandos do sqlcmd. No menu **Query**, clique em **SQLCMD Mode**. As linhas que começam com `:` ficam destacadas em cinza. Rode:

```sql
:setvar Tabela Produtos

USE Loja;
SELECT '$(Tabela)' AS Tabela, COUNT(*) AS Linhas FROM dbo.$(Tabela);
GO
```

Troque `Produtos` por `Pedidos` na primeira linha e rode de novo. Nesse modo também existe o `:CONNECT NomeDoServidor`, que troca de servidor no meio do script: um único arquivo pode rodar comandos em vários servidores. Quando terminar, desligue o **SQLCMD Mode** (o IntelliSense fica desligado enquanto ele está ativo).

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Utilitário sqlcmd (todas as opções)](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-utility)
- [Baixar e instalar o sqlcmd](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-download-install)
- [Comandos do sqlcmd (GO, :setvar, :CONNECT, :r...)](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-commands)
- [Usar o sqlcmd com variáveis de script](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-use-scripting-variables)
- [Criar um SQL Server em container com o sqlcmd](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/quickstart-sqlcmd-create-container)
- [Editar scripts SQLCMD no editor de consultas do SSMS](https://learn.microsoft.com/pt-br/ssms/scripting/sqlcmd-scripts-query-editor)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem uma série de dicas de sqlcmd, de exportação a automação com PowerShell.
- [Dirceu Resende](https://dirceuresende.com/): em português, com vários artigos de automação e linha de comando no SQL Server.
