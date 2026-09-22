---
title: "O que é SQL?"
date: 2024-01-15
weight: 1
tags: ["fundamentos", "sql", "banco-de-dados"]
categories: ["Fundamentos"]
description: "O que é SQL, para que serve e como ele se encaixa no mundo dos bancos de dados relacionais."
---

SQL (**Structured Query Language**) é a linguagem padrão para comunicação com bancos de dados relacionais. Com ela você cria estruturas, insere dados, consulta, atualiza e remove informações — tudo de forma declarativa: você diz *o quê* quer, não *como* buscar.

## Banco de dados relacional: a ideia central

Imagine uma planilha do Excel. Ela tem colunas (nome, idade, cidade) e linhas (cada registro é uma pessoa). Um banco de dados relacional funciona exatamente assim, mas com superpoderes:

- Vários "abas" (chamadas **tabelas**) que se relacionam entre si
- Garantias de consistência dos dados
- Capacidade de processar milhões de registros rapidamente
- Acesso simultâneo de múltiplos usuários sem conflito

## Os principais SGBDs

SGBD significa **Sistema Gerenciador de Banco de Dados** — é o software que roda o banco. Os mais usados são:

| SGBD | Uso principal | Licença |
|---|---|---|
| SQL Server | Empresas Windows, .NET | Comercial / Express grátis |
| PostgreSQL | Web, dados complexos | Open source |
| MySQL / MariaDB | Web, WordPress, PHP | Open source |
| Oracle | Grandes empresas | Comercial |
| SQLite | Apps mobile, embarcado | Open source |

## Por que SQL ANSI?

O SQL tem um padrão internacional — o **SQL ANSI/ISO** — que define uma sintaxe base que funciona em qualquer SGBD. Os posts aqui seguem esse padrão sempre que possível, com notas quando algo é específico de um banco.

Isso significa que o código que você aprende aqui funciona no SQL Server, no PostgreSQL, no MySQL e nos demais com ajustes mínimos.

## O que você vai aprender

O SQL se divide em quatro grupos de comandos:

**DDL** — *Data Definition Language*: cria e altera estruturas
```sql
CREATE TABLE, ALTER TABLE, DROP TABLE
```

**DML** — *Data Manipulation Language*: manipula os dados
```sql
SELECT, INSERT, UPDATE, DELETE
```

**DCL** — *Data Control Language*: controla permissões
```sql
GRANT, REVOKE
```

**TCL** — *Transaction Control Language*: controla transações
```sql
COMMIT, ROLLBACK, SAVEPOINT
```

O foco aqui é DDL e DML — o que você usa 90% do tempo.

## Próximo passo

Vá para a [prática](/pratica/01-ambiente-e-primeiros-passos/) e crie suas primeiras tabelas e consultas.