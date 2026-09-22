---
title: "SQL Server no Docker: uma instância rodando em 1 minuto"
description: "Subir o SQL Server em container no Windows, Mac ou Linux, guardar os dados num volume e não perder nada quando o container for apagado."
date: 2026-02-06T08:00:00-04:00
weight: 3
roadmap: "docker"
tags: ["fundamentos", "ambiente", "docker"]
---

Instalar o SQL Server no Windows funciona muito bem, mas às vezes você quer algo mais leve: subir uma instância em segundos, testar e jogar fora. Ou você usa Mac ou Linux e o instalador do Windows nem é opção. Para isso existe o SQL Server em **container**.

## O que é um container, em uma frase

Um container é um pacote com o programa e tudo que ele precisa para rodar, isolado do resto do seu computador. A Microsoft publica uma imagem oficial do SQL Server (que roda em Linux por dentro), e o **Docker** é o programa que baixa essa imagem e roda o container.

Vantagens: sobe em segundos, não "suja" o seu sistema, dá para ter várias versões lado a lado e apagar tudo com um comando.

## O que você precisa

- **Docker Desktop** instalado (no Windows ele usa o WSL 2 por baixo).
- Pelo menos uns 2 GB de memória livre para o container.

{{< callout type="warning" >}}
**Mac com chip Apple (M1, M2, M3...):** a imagem do SQL Server é feita para processadores x64. No Mac ela roda pela emulação Rosetta do Docker Desktop. Funciona bem para estudar, mas a Microsoft deixa claro que esse cenário não é testado nem tem suporte oficial.
{{< /callout >}}

## Os parâmetros do comando

Este é o comando que eu uso (em uma linha só, funciona igual no PowerShell, no terminal do Mac e no Linux):

```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Senha@Forte2026" -p 1433:1433 --name sqlserver --hostname sqlserver -v sqldata:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2025-latest
```

| Parâmetro | O que faz |
|---|---|
| `ACCEPT_EULA=Y` | Aceita a licença. Sem isso o container não sobe. |
| `MSSQL_SA_PASSWORD` | Senha do `sa`. Precisa ter 8+ caracteres e 3 de 4 tipos (maiúscula, minúscula, número, símbolo). Senha fraca = container sobe e morre. |
| `-p 1433:1433` | Liga a porta 1433 do seu computador à porta 1433 do container. |
| `--name` e `--hostname` | Dão nome ao container, para você não ter que decorar um ID aleatório. |
| `-v sqldata:/var/opt/mssql` | Guarda os bancos num **volume** fora do container. Mais sobre isso abaixo. |
| `-d` | Roda em segundo plano. |
| `...server:2025-latest` | A imagem: SQL Server 2025, última atualização. Por padrão, edição Developer. |

Duas variações úteis:

- **Já tem SQL Server instalado no Windows?** Ele provavelmente está usando a porta 1433. Troque para `-p 14330:1433` e conecte em `localhost,14330`.
- **Quer a Standard Developer?** Adicione `-e "MSSQL_PID=StandardDeveloper"`.

## Por que o volume é tão importante

Sem o `-v`, os bancos ficam **dentro** do container. Apagou o container, apagou os bancos. Com o volume, os arquivos ficam guardados à parte, e você pode apagar, recriar e até trocar de versão do SQL Server sem perder nada. Vamos provar isso na prática.

## Bora pra prática

### 1. Subir e acompanhar

Rode o comando acima e depois:

```bash
docker ps
docker logs sqlserver
```

O `docker ps` mostra o container rodando. No `docker logs`, espere aparecer a linha *"SQL Server is now ready for client connections"*. Se o container sumir do `docker ps`, quase sempre é senha fraca: o `docker logs` mostra o motivo.

### 2. Conectar

No SSMS ou no VS Code, use:

- **Servidor:** `localhost,1433` (com **vírgula**, não dois-pontos)
- **Autenticação:** SQL Server Authentication, usuário `sa` e a senha que você definiu
- Marque **Trust server certificate**

E confira onde você está:

```sql
SELECT @@SERVERNAME             AS Servidor,   -- sqlserver
       SERVERPROPERTY('Edition') AS Edicao,
       @@VERSION                 AS Versao;     -- repare no "on Linux"
```

Dá para usar o sqlcmd que já vem dentro do container, sem instalar nada:

```bash
docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "Senha@Forte2026" -C -Q "SELECT @@VERSION"
```

O `-C` diz para confiar no certificado do servidor, que no container é autoassinado.

### 3. Provar que o volume funciona

Crie um banco:

```sql
CREATE DATABASE TesteVolume;
```

Agora **apague o container** e crie de novo, com o mesmo volume:

```bash
docker rm -f sqlserver
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=Senha@Forte2026" -p 1433:1433 --name sqlserver --hostname sqlserver -v sqldata:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2025-latest
```

Conecte de novo e confira:

```sql
SELECT name, create_date
FROM   sys.databases
WHERE  name = N'TesteVolume';
```

O banco continua lá, com a data de criação original. Se você tivesse subido sem o `-v`, ele teria sumido junto com o container.

### 4. Crie o banco Loja

Rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql) nessa instância. Ele funciona igual em Windows e em container.

### 5. O dia a dia

```bash
docker stop sqlserver     # desliga (os dados ficam)
docker start sqlserver    # liga de novo
docker rm -f sqlserver    # apaga o container (os dados continuam no volume)
docker volume rm sqldata  # agora sim, apaga os dados de vez
```

## Um atalho: o sqlcmd novo

O **sqlcmd** moderno (a versão em Go) cria o container para você, gera a senha, escolhe a porta e já guarda a conexão:

```bash
sqlcmd create mssql --accept-eula
sqlcmd query "SELECT @@VERSION"
```

Ele até restaura um banco de exemplo junto, com o parâmetro `--using`. O sqlcmd tem post próprio mais para frente nesta trilha.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Início rápido: executar o SQL Server em contêiner com Docker](https://learn.microsoft.com/pt-br/sql/linux/install-upgrade/quickstart-install-docker)
- [Implantar e conectar a contêineres do SQL Server](https://learn.microsoft.com/pt-br/sql/linux/containers/deploy)
- [Configurar contêineres do SQL Server (inclui como persistir dados)](https://learn.microsoft.com/pt-br/sql/linux/containers/configure)
- [Edições do SQL Server 2025 no Linux (valores do MSSQL_PID)](https://learn.microsoft.com/pt-br/sql/linux/sql-server-linux-editions-and-components-2025)
- [Criar e consultar um contêiner com o sqlcmd](https://learn.microsoft.com/pt-br/sql/tools/sqlcmd/sqlcmd-use-utility)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [MSSQLTips](https://www.mssqltips.com/): tem vários tutoriais de SQL Server em Docker, do básico ao Docker Compose.
- [Dirceu Resende](https://dirceuresende.com/): em português, com conteúdo sobre SQL Server no Linux e em containers.
