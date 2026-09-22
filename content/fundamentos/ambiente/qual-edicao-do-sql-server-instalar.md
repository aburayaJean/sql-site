---
title: "Qual edição do SQL Server instalar?"
description: "Enterprise, Standard, Developer, Express, Evaluation: o que muda entre as edições do SQL Server 2025 e qual usar para estudar."
date: 2026-02-02T08:00:00-04:00
weight: 1
roadmap: "edicoes-escolha"
tags: ["fundamentos", "ambiente", "iniciante"]
---

Você entra no site da Microsoft para baixar o SQL Server e dá de cara com um monte de nomes: Enterprise, Standard, Developer, Express, Evaluation... Qual escolher? Vamos resolver isso de uma vez.

## O motor é o mesmo

Primeiro, uma coisa que pouca gente fala: **o motor do banco é o mesmo em todas as edições**. O que muda é o limite de hardware que ele usa, alguns recursos e, principalmente, a licença, ou seja, onde você pode usar.

## As edições do SQL Server 2025

| Edição | Custa? | Pode usar em produção? | Resumo |
|---|---|---|---|
| **Enterprise** | Sim | Sim | Tudo liberado, sem limite de hardware |
| **Standard** | Sim | Sim | Até 4 sockets ou 32 cores e 256 GB de memória para o buffer pool |
| **Enterprise Developer** | Não | **Não** | Igual à Enterprise, só para desenvolvimento e teste |
| **Standard Developer** | Não | **Não** | Igual à Standard, só para desenvolvimento e teste (nova no 2025) |
| **Express** | Não | Sim | 1 socket ou 4 cores, 1.410 MB de buffer pool e banco de até 50 GB |
| **Evaluation** | Não | Não | Igual à Enterprise, mas expira em 180 dias |

Algumas coisas que mudaram no 2025:

- **A edição Web acabou.** Ela não existe mais a partir do SQL Server 2025.
- **A Developer virou duas:** a Enterprise Developer (que é a Developer de sempre) e a nova Standard Developer.
- **O Express ficou maior:** o limite de banco subiu de 10 GB para 50 GB.
- **O Standard ficou mais forte:** saiu de 24 para 32 cores e ganhou o Resource Governor.

## Qual eu uso para estudar?

**Enterprise Developer.** Ela é grátis, tem tudo, e é o que eu uso nos posts do blog. Assim você nunca vai ficar preso num recurso que "não existe na sua edição".

E a **Standard Developer**, para que serve? Para quando a sua empresa roda Standard em produção e você quer ter certeza de que o que você desenvolveu funciona lá. Nem tudo que existe na Enterprise existe na Standard, e é melhor descobrir isso no seu notebook do que no dia do deploy.

E o **Express**? É ótimo para aplicações pequenas em produção, porque é grátis, mas tem limites e **não tem SQL Server Agent** (o agendador de jobs). Para estudar, a Developer é melhor.

{{< callout type="warning" >}}
**Developer não é "o Enterprise grátis para produção".** A licença proíbe usar as edições Developer em produção. Se o banco atende usuários de verdade, precisa de licença.
{{< /callout >}}

## Versão não é edição

Mais uma confusão comum: **versão** é o ano (2019, 2022, 2025). **Edição** é o "sabor" (Enterprise, Standard, Express...). Você pode ter um SQL Server 2022 Standard e um SQL Server 2025 Express na mesma empresa.

Cada versão também tem um número interno, que aparece em vários lugares:

| Versão | Número |
|---|---|
| SQL Server 2025 | 17 |
| SQL Server 2022 | 16 |
| SQL Server 2019 | 15 |
| SQL Server 2017 | 14 |
| SQL Server 2016 | 13 |

## Bora pra prática

Conecte em qualquer SQL Server que você tenha acesso (o seu, o do trabalho, um container) e descubra exatamente o que está rodando lá:

```sql
SELECT SERVERPROPERTY('ProductMajorVersion') AS VersaoNumero,   -- 17 = 2025
       SERVERPROPERTY('ProductVersion')      AS Build,
       SERVERPROPERTY('ProductLevel')        AS Nivel,          -- RTM, SP1...
       SERVERPROPERTY('ProductUpdateLevel')  AS AtualizacaoCU,  -- CU1, CU2...
       SERVERPROPERTY('Edition')             AS Edicao,
       SERVERPROPERTY('EngineEdition')       AS TipoDeMotor;    -- 2 = Standard, 3 = Enterprise/Developer, 4 = Express
```

Algumas coisas para reparar no resultado:

- **`Edicao`** mostra o nome completo, como "Enterprise Developer Edition (64-bit)".
- **`TipoDeMotor`** agrupa as edições pelo que elas conseguem fazer. Developer e Evaluation aparecem como 3, junto com a Enterprise, porque têm os mesmos recursos.
- **`AtualizacaoCU`** diz qual atualização cumulativa (CU) está instalada. Se vier `NULL`, não tem nenhuma CU aplicada, e isso num servidor de produção é um sinal de alerta.

E o jeito rápido, que mostra tudo em uma linha de texto:

```sql
SELECT @@VERSION;
```

Se você tem acesso a mais de um servidor no trabalho, rode nos dois e compare. É muito comum descobrir servidor de produção sem atualização há anos.

## Documentação oficial

Quer ir mais fundo? Estes são os artigos oficiais da Microsoft sobre o que a gente viu aqui. Estão em português; se alguma tradução parecer estranha, dá para trocar para o original em inglês no próprio site.

- [Edições e recursos com suporte do SQL Server 2025](https://learn.microsoft.com/pt-br/sql/sql-server/editions-and-components-of-sql-server-2025)
- [Novidades do SQL Server 2025 (inclui as mudanças de edição)](https://learn.microsoft.com/pt-br/sql/sql-server/what-s-new-in-sql-server-2025)
- [Requisitos de hardware e software do SQL Server 2025](https://learn.microsoft.com/pt-br/sql/sql-server/install/hardware-and-software-requirements-for-installing-sql-server-2025)
- [SERVERPROPERTY](https://learn.microsoft.com/pt-br/sql/t-sql/functions/serverproperty-transact-sql) e [@@VERSION](https://learn.microsoft.com/pt-br/sql/t-sql/functions/version-transact-sql-configuration-functions)

## Da comunidade

Blogs de MVPs e especialistas da comunidade SQL Server que valem a leitura:

- [SQL Server Builds](https://sqlserverbuilds.blogspot.com/): a lista de todos os builds e CUs de cada versão. Pegue o `Build` da query acima e descubra exatamente o que está instalado.
- [Dirceu Resende](https://dirceuresende.com/): blog em português de um MVP brasileiro, com muito conteúdo de administração.
