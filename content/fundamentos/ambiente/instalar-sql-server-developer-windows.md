---
title: "Instalar o SQL Server Developer no Windows, passo a passo"
description: "Da tela de download até a primeira conexão: cada página do instalador do SQL Server 2025 e o que marcar em cada uma."
date: 2026-02-04T08:00:00-04:00
weight: 2
roadmap: "ambiente"
tags: ["fundamentos", "ambiente", "instalacao"]
---

Vamos instalar o SQL Server 2025 Developer no Windows. O instalador tem bastante tela, mas a maioria você só aperta Next. Vou parar só nas que importam e dizer o que eu marco em cada uma para um ambiente de estudo.

## Antes de começar

- **Windows 10 ou 11, ou Windows Server**, em processador x64 (Intel ou AMD).
- **Memória:** o mínimo é 1 GB, mas para estudar com conforto, deixe pelo menos uns 4 GB livres só para ele.
- **Disco:** pelo menos 6 GB livres, mais o espaço dos bancos que você for criar.
- **Usuário administrador** do Windows.

## O download

Baixe o instalador na página de downloads do SQL Server, no site da Microsoft, escolhendo a edição **Developer**. O instalador pequeno pergunta como você quer seguir:

- **Basic:** instala tudo no padrão, sem perguntar nada.
- **Custom:** abre o instalador completo e deixa você escolher cada detalhe.
- **Download Media:** só baixa os arquivos para instalar depois ou em outra máquina.

Escolha **Custom**. O Basic funciona, mas você perde a chance de entender (e acertar) as configurações.

## As telas que importam

Quando o **SQL Server Installation Center** abrir, vá em **Installation** e clique em **New SQL Server standalone installation**.

**1. Edition.** Marque **Specify a free edition** e escolha **Developer**. No 2025 ela aparece como Enterprise Developer e Standard Developer; para estudar, fique com a **Enterprise Developer**.

**2. Install Rules.** Pode aparecer um aviso amarelo do Firewall do Windows. É só um aviso, pode seguir.

**3. Azure Extension for SQL Server.** Novidade do 2025: ela vem **marcada por padrão** e serve para conectar a instância ao Azure. Para um ambiente de estudo no seu computador, **desmarque**.

**4. Feature Selection.** Marque **Database Engine Services**. Se quiser, marque também **Full-Text and Semantic Extractions for Search**, que alguns bancos de exemplo usam. O resto não precisa agora.

**5. Instance Configuration.** Deixe **Default instance** (`MSSQLSERVER`). Assim você conecta só com o nome do computador, sem `\NOME` no final.

**6. Server Configuration.** Mantenha as contas de serviço sugeridas e marque **Grant Perform Volume Maintenance Task privilege**. Isso liga o *Instant File Initialization*, que deixa a criação e o crescimento de arquivos de dados muito mais rápidos. A aba **Collation** mostra a collation da instância; o padrão depende do idioma do seu Windows e, por enquanto, pode deixar como está.

**7. Database Engine Configuration.** A tela mais importante:

- **Authentication Mode:** escolha **Mixed Mode** e defina uma senha forte para o `sa`. Em produção a recomendação é usar só autenticação do Windows, mas no laboratório o modo misto ajuda a testar conexões com usuário e senha, que é como aplicações e containers costumam conectar.
- **Specify SQL Server administrators:** clique em **Add Current User**. Sem isso, nem você consegue administrar a instância.
- **Memory:** escolha **Recommended** e marque a caixa para aceitar. Sem limite, o SQL Server vai ocupando a memória livre do seu notebook, e é para isso mesmo que ele foi feito. Num computador pessoal, é melhor ter um teto.
- **TempDB** e **MaxDOP:** os valores sugeridos pelo instalador são bons. Pode seguir.

**8. Ready to Install.** Confira o resumo e clique em **Install**. Leva alguns minutos.

## Um detalhe da edição Developer

Na Developer (e no Express), **o protocolo TCP/IP vem desligado**. Para conectar da própria máquina com o SSMS, não faz diferença: ele usa *Shared Memory*. Mas se você for conectar de outro computador, de um container ou de algumas aplicações, precisa ligar:

1. Abra o **SQL Server Configuration Manager**.
2. Vá em **SQL Server Network Configuration** > **Protocols for MSSQLSERVER**.
3. Clique com o botão direito em **TCP/IP** > **Enable**.
4. Reinicie o serviço em **SQL Server Services** > **SQL Server (MSSQLSERVER)** > **Restart**.

## Bora pra prática

### 1. Os serviços estão rodando?

No PowerShell:

```powershell
Get-Service *SQL* | Select-Object Name, Status, StartType
```

Você deve ver o `MSSQLSERVER` (o motor) com status **Running**. O `SQLSERVERAGENT` também aparece, mas normalmente vem parado, com início manual. Ele é o agendador de jobs e vai ganhar uma trilha própria.

### 2. Primeira conexão

Com o SSMS instalado (o próximo post mostra como), conecte usando `.` ou `localhost` como nome do servidor e **Windows Authentication**. Na janela de query:

```sql
SELECT @@SERVERNAME                      AS Servidor,
       SERVERPROPERTY('Edition')         AS Edicao,
       SERVERPROPERTY('Collation')       AS CollationDaInstancia,
       SERVERPROPERTY('IsIntegratedSecurityOnly') AS SoWindows;  -- 0 = Mixed Mode
```

### 3. A instalação ficou do jeito que você escolheu?

```sql
-- Conta de serviço, tipo de início e Instant File Initialization
SELECT servicename,
       service_account,
       startup_type_desc,
       status_desc,
       instant_file_initialization_enabled   -- Y = ligado
FROM   sys.dm_server_services;

-- Limite de memória configurado
SELECT name, value_in_use
FROM   sys.configurations
WHERE  name IN ('max server memory (MB)', 'min server memory (MB)');
```

### 4. Ajustar a memória (se precisar)

Se você pulou a opção **Recommended**, o `max server memory` vai aparecer como `2147483647`, que na prática significa "sem limite". Num notebook com 16 GB, um teto de 4 a 6 GB é razoável:

```sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'max server memory (MB)', 4096;
RECONFIGURE;
```

A mudança vale na hora, sem reiniciar. Configuração de memória em servidor de verdade é assunto da trilha de Administração.

### 5. Crie o banco Loja

Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql). Pronto: ambiente de estudo montado.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Instalar o SQL Server pelo Assistente de Instalação](https://learn.microsoft.com/pt-br/sql/database-engine/install-windows/install-sql-server-from-the-installation-wizard-setup)
- [Ajuda do Assistente de Instalação (cada página explicada)](https://learn.microsoft.com/pt-br/sql/sql-server/install/instance-configuration)
- [Requisitos de hardware e software do SQL Server 2025](https://learn.microsoft.com/pt-br/sql/sql-server/install/hardware-and-software-requirements-for-installing-sql-server-2025)
- [Configuração padrão dos protocolos de rede](https://learn.microsoft.com/pt-br/sql/database-engine/configure-windows/default-sql-server-network-protocol-configuration) e [como ligar ou desligar um protocolo](https://learn.microsoft.com/pt-br/sql/database-engine/configure-windows/enable-or-disable-a-server-network-protocol)
- [Inicialização instantânea de arquivos](https://learn.microsoft.com/pt-br/sql/relational-databases/databases/database-instant-file-initialization)
- [Opções de configuração de memória do servidor](https://learn.microsoft.com/pt-br/sql/database-engine/configure-windows/server-memory-server-configuration-options)
- [sys.dm_server_services](https://learn.microsoft.com/pt-br/sql/relational-databases/system-dynamic-management-objects/sys-dm-server-services-transact-sql)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [Dirceu Resende](https://dirceuresende.com/): em português, com vários guias de instalação e configuração pós-instalação.
- [Brent Ozar](https://www.brentozar.com/): referência mundial em SQL Server; procure pelo checklist de configuração de um servidor novo.
