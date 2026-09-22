---
title: "Bancos de exemplo para praticar: AdventureWorks e cia."
description: "Quais bancos de exemplo existem, para que serve cada um, onde baixar e como restaurar o .bak no Windows e no Docker, entendendo o que o RESTORE faz."
date: 2026-02-23T08:00:00-04:00
weight: 10
roadmap: "bancos-exemplo"
tags: ["fundamentos", "ambiente", "restore", "adventureworks"]
---

O banco Loja do blog é pequeno de propósito: dá para ver todas as linhas e entender cada resultado. Mas uma hora você vai querer um banco **de verdade**, com dezenas de tabelas, milhares de linhas e os relacionamentos de uma empresa. É para isso que existem os bancos de exemplo.

E tem um bônus: quase todos vêm como um arquivo de **backup** (`.bak`). Instalar um banco de exemplo é o seu primeiro **restore**, uma das tarefas mais importantes de quem trabalha com SQL Server.

## Os principais

| Banco | O que tem | Bom para |
|---|---|---|
| **AdventureWorksLT** | Versão enxuta da AdventureWorks: uma dúzia de tabelas no schema `SalesLT` | Começar. Pequeno e fácil de entender |
| **AdventureWorks** | Uma fábrica de bicicletas: vendas, produção, RH, compras, em vários schemas | Praticar consultas. É o banco dos exemplos da documentação da Microsoft |
| **AdventureWorksDW** | A mesma empresa, modelada como data warehouse (fatos e dimensões) | BI e consultas analíticas |
| **WideWorldImporters** | Uma importadora, com recursos mais modernos: tabelas temporais, JSON, columnstore, In-Memory | Ver recursos novos do SQL Server em ação |
| **StackOverflow** | Os dados públicos reais do site Stack Overflow, distribuídos pelo Brent Ozar | Performance: tem volume de verdade, de alguns GB a centenas de GB |
| **Northwind** e **pubs** | Os clássicos antigos, criados por script | Seguir tutoriais e livros mais antigos |

Minha sugestão: comece pelo **AdventureWorksLT**, passe para o **AdventureWorks** quando quiser mais tabelas e guarde o **StackOverflow** para a trilha de Performance.

## Onde baixar

Os oficiais da Microsoft ficam no GitHub, no repositório `sql-server-samples`:

- AdventureWorks 2025: [OLTP](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2025.bak), [LT](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2025.bak) e [DW](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2025.bak). As versões para SQL Server mais antigos (2022, 2019...) estão na página oficial, listada no fim do post.
- WideWorldImporters: [WideWorldImporters-Full.bak](https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak).
- Northwind e pubs: [scripts no GitHub](https://github.com/microsoft/sql-server-samples/tree/master/samples/databases/northwind-pubs).

{{< callout type="warning" >}}
**Backup não volta de versão.** Um `.bak` feito no SQL Server 2025 **não** restaura num SQL Server 2022: dá o erro 3169. O contrário funciona. Por isso, baixe o arquivo com o número da sua versão ou de uma **mais antiga**.
{{< /callout >}}

## O que o RESTORE faz

Um backup guarda as páginas do banco e também **onde os arquivos estavam** no servidor de origem: o arquivo de dados (`.mdf`) e o de log (`.ldf`), cada um com um **nome lógico** (o apelido interno) e um **nome físico** (o caminho no disco).

Quando você restaura, o SQL Server tenta recriar os arquivos **no mesmo caminho** de origem. Se esse caminho não existe na sua máquina, você usa o `WITH MOVE` para dizer onde cada arquivo deve ficar. Antes de restaurar, dá para espiar o conteúdo do backup com dois comandos:

- `RESTORE HEADERONLY`: o que tem no backup (nome do banco, data, versão do SQL Server).
- `RESTORE FILELISTONLY`: quais arquivos ele vai criar, com o nome lógico e o caminho original.

## Bora pra prática

Vamos restaurar o **AdventureWorksLT2025** numa instalação no Windows. O jeito pelo Docker vem logo depois.

### 1. Descubra as pastas padrão da sua instância

```sql
SELECT SERVERPROPERTY('InstanceDefaultDataPath')   AS PastaDados,
       SERVERPROPERTY('InstanceDefaultLogPath')    AS PastaLog,
       SERVERPROPERTY('InstanceDefaultBackupPath') AS PastaBackup;
```

Anote as três. Numa instância padrão do SQL Server 2025, elas ficam dentro de `C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\`.

### 2. Coloque o .bak na pasta de backup

Baixe o [AdventureWorksLT2025.bak](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2025.bak) e copie para a **PastaBackup** (o Windows vai pedir permissão de administrador).

Por que ali? Quem lê o arquivo é o **serviço do SQL Server**, não você. Se o arquivo estiver na sua pasta Downloads, o serviço pode não ter permissão e o restore falha com "Access is denied". A pasta de backup da instância já tem a permissão certa.

### 3. Espie o backup

Troque o caminho se a sua pasta for diferente:

```sql
RESTORE HEADERONLY
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\AdventureWorksLT2025.bak';

RESTORE FILELISTONLY
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\AdventureWorksLT2025.bak';
```

No primeiro resultado, olhe as colunas `DatabaseName` e `SoftwareVersionMajor` (a versão do SQL Server que fez o backup). No segundo, olhe `LogicalName`, `PhysicalName` e `Type` (`D` é dados, `L` é log). **Anote os dois nomes lógicos**: você pode precisar deles no passo 5.

### 4. Restaure

```sql
USE master;

RESTORE DATABASE AdventureWorksLT2025
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\AdventureWorksLT2025.bak'
WITH STATS = 10;
```

O `STATS = 10` mostra o progresso a cada 10% na aba Messages. Terminou com "RESTORE DATABASE successfully processed"? Pule para o passo 6.

### 5. Se reclamar do caminho: WITH MOVE

Se aparecer algo como *Directory lookup for the file ... failed* (erro 5133), é porque o caminho gravado no backup não existe na sua máquina. Diga para onde vai cada arquivo, usando os **nomes lógicos** do passo 3 e as **pastas** do passo 1:

```sql
USE master;

RESTORE DATABASE AdventureWorksLT2025
FROM DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\AdventureWorksLT2025.bak'
WITH MOVE N'NomeLogicoDosDados' TO N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorksLT2025.mdf',
     MOVE N'NomeLogicoDoLog'    TO N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventureWorksLT2025_log.ldf',
     STATS = 10;
```

Troque `NomeLogicoDosDados` e `NomeLogicoDoLog` pelo que apareceu na coluna `LogicalName`. Se errar o nome, o erro é o 3234: *Logical file ... is not part of database*.

### 6. Explore o banco novo

```sql
USE AdventureWorksLT2025;

-- Quais tabelas existem e quantas linhas cada uma tem
SELECT s.name      AS Esquema,
       t.name      AS Tabela,
       SUM(p.rows) AS Linhas
FROM   sys.tables     AS t
JOIN   sys.schemas    AS s ON s.schema_id = t.schema_id
JOIN   sys.partitions AS p ON p.object_id = t.object_id
                          AND p.index_id IN (0, 1)
GROUP  BY s.name, t.name
ORDER  BY Linhas DESC;

-- Os 10 produtos mais caros, com a categoria
SELECT TOP (10)
       p.Name      AS Produto,
       p.ListPrice AS Preco,
       c.Name      AS Categoria
FROM   SalesLT.Product         AS p
JOIN   SalesLT.ProductCategory AS c ON c.ProductCategoryID = p.ProductCategoryID
ORDER  BY p.ListPrice DESC;
```

Repare que as tabelas estão no schema `SalesLT`, não no `dbo`. Por isso o nome completo (`SalesLT.Product`) é obrigatório.

### 7. E no Docker?

Se o seu SQL Server está no container do [post de Docker]({{< relref "/fundamentos/ambiente/sql-server-no-docker" >}}) (chamado `sqlserver`), copie o arquivo para dentro dele pelo PowerShell, na pasta onde está o `.bak`:

```powershell
docker exec sqlserver mkdir -p /var/opt/mssql/backup
docker cp .\AdventureWorksLT2025.bak sqlserver:/var/opt/mssql/backup/
```

No Linux, os caminhos do Windows gravados no backup nunca existem, então o `WITH MOVE` é obrigatório. Rode o `RESTORE FILELISTONLY` apontando para `/var/opt/mssql/backup/AdventureWorksLT2025.bak`, pegue os nomes lógicos e:

```sql
USE master;

RESTORE DATABASE AdventureWorksLT2025
FROM DISK = N'/var/opt/mssql/backup/AdventureWorksLT2025.bak'
WITH MOVE N'NomeLogicoDosDados' TO N'/var/opt/mssql/data/AdventureWorksLT2025.mdf',
     MOVE N'NomeLogicoDoLog'    TO N'/var/opt/mssql/data/AdventureWorksLT2025_log.ldf',
     STATS = 10;
```

### 8. O atalho do sqlcmd

Se você tem o Docker e o [sqlcmd]({{< relref "/fundamentos/ambiente/sqlcmd" >}}) novo, um comando cria um container **novo** já com o banco restaurado:

```powershell
sqlcmd create mssql --accept-eula --using https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2025.bak
```

É ótimo para subir um laboratório descartável. Mas faça o restore manual pelo menos uma vez: é exatamente o que você vai fazer num servidor de verdade, e aí não vai ter atalho.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Bancos de exemplo AdventureWorks (downloads de todas as versões)](https://learn.microsoft.com/pt-br/sql/samples/adventureworks-install-configure)
- [WideWorldImporters: instalação e configuração](https://learn.microsoft.com/pt-br/sql/samples/wide-world-importers-oltp-install-configure)
- [Instruções RESTORE](https://learn.microsoft.com/pt-br/sql/t-sql/statements/restore-statements-transact-sql) e [RESTORE FILELISTONLY](https://learn.microsoft.com/pt-br/sql/t-sql/statements/restore-statements-filelistonly-transact-sql)
- [Restaurar um banco de dados em um novo local (WITH MOVE)](https://learn.microsoft.com/pt-br/sql/relational-databases/backup-restore/restore-a-database-to-a-new-location-sql-server)
- [Restaurar um backup de banco de dados usando o SSMS](https://learn.microsoft.com/pt-br/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms)
- [SERVERPROPERTY](https://learn.microsoft.com/pt-br/sql/t-sql/functions/serverproperty-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [Brent Ozar](https://www.brentozar.com/): distribui o banco StackOverflow em vários tamanhos e usa ele em todos os treinamentos de performance. Procure por "Stack Overflow database" no site.
- [MSSQLTips](https://www.mssqltips.com/): tem passo a passo de restore em várias situações, inclusive em Linux e containers.
