---
title: "O que é SQL?"
date: 2026-01-01
weight: 10
tags: ["iniciante", "conceito"]
categories: ["Teoria"]
description: "Entenda o que é SQL, sua história e por que ele é a linguagem universal dos bancos de dados relacionais."
---

SQL (*Structured Query Language*) é a linguagem padrão para **comunicar com bancos de dados relacionais**. Com ela você cria tabelas, insere dados, faz consultas e controla quem pode acessar o quê.

## Um pouco de história

SQL nasceu na IBM em 1974, baseado no modelo relacional proposto por Edgar F. Codd. Em 1986 virou padrão ISO/ANSI — e desde então praticamente todo SGBD do mercado o suporta: PostgreSQL, SQL Server, MySQL, Oracle, SQLite, MariaDB…

## O que dá para fazer com SQL?

SQL se divide em quatro grandes grupos de comandos:

| Grupo | Sigla | Exemplos |
|---|---|---|
| Consulta de dados | DQL | `SELECT` |
| Manipulação de dados | DML | `INSERT`, `UPDATE`, `DELETE` |
| Definição de estrutura | DDL | `CREATE`, `ALTER`, `DROP` |
| Controle de acesso | DCL | `GRANT`, `REVOKE` |

## Por que ANSI SQL?

Neste blog usamos **ANSI SQL** (o padrão internacional) sempre que possível. Isso significa que os exemplos funcionam em qualquer SGBD com mínimas adaptações. Quando existe diferença relevante entre bancos, apontamos no próprio código.

## Modelo de dados que usamos

Todos os módulos práticos usam três tabelas simples:

```sql
-- Clientes do e-commerce
CREATE TABLE clientes (
    id    INTEGER      NOT NULL,
    nome  VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    cidade VARCHAR(80),
    pais  VARCHAR(50)  NOT NULL DEFAULT 'Brasil',
    CONSTRAINT pk_clientes PRIMARY KEY (id)
);

-- Produtos disponíveis
CREATE TABLE produtos (
    id        INTEGER       NOT NULL,
    nome      VARCHAR(100)  NOT NULL,
    categoria VARCHAR(50),
    preco     DECIMAL(10,2) NOT NULL,
    estoque   INTEGER       NOT NULL DEFAULT 0,
    CONSTRAINT pk_produtos PRIMARY KEY (id)
);

-- Pedidos realizados
CREATE TABLE pedidos (
    id          INTEGER       NOT NULL,
    id_cliente  INTEGER       NOT NULL,
    data_pedido DATE          NOT NULL,
    total       DECIMAL(10,2),
    status      VARCHAR(20)   NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_pedidos PRIMARY KEY (id)
);
```

Execute o script do **Módulo 01** para criar e popular essas tabelas antes de qualquer exercício.

## Próximo passo

Agora que você sabe o que é SQL e conhece nosso modelo de dados, vá para o [Módulo 02 — SELECT e WHERE](/teoria/02-select-e-where/) e faça sua primeira consulta.
