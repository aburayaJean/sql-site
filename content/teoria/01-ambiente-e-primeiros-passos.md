---
title: "Ambiente e Primeiros Passos"
date: 2024-01-15
weight: 1
tags: ["fundamentos", "select", "setup"]
categories: ["Fundamentos"]
description: "Configure seu ambiente, crie as tabelas de exemplo e execute seu primeiro SELECT."
---

Antes de qualquer coisa, você precisa de um lugar para executar SQL. Tem três opções — escolha a que funciona para você agora:

## Opção A — Online (sem instalar nada)

Acesse **[db-fiddle.com](https://www.db-fiddle.com)** e escolha o banco no topo da página. É a forma mais rápida de testar qualquer script deste site.

## Opção B — SQL Server Express (Windows)

1. Baixe o **SQL Server Express** em microsoft.com/sql-server (grátis)
2. Baixe o **SSMS** (SQL Server Management Studio) — o editor visual
3. Conecte em `localhost\SQLEXPRESS`

## Opção C — PostgreSQL

1. Baixe em **postgresql.org** (grátis, todas as plataformas)
2. Use o **pgAdmin** como editor visual ou o `psql` no terminal

---

## Script desta aula

Baixe o script completo:
**[⬇ download: 01-primeiros-passos.sql](/scripts/01-primeiros-passos.sql)**

---

## O que o script faz

### 1. Criando as tabelas de exemplo

Vamos usar um cenário simples: uma loja com clientes, produtos e pedidos. Esse mesmo conjunto de dados vai ser usado em todos os posts da seção Prática.

```sql
-- Tabela de clientes
CREATE TABLE clientes (
    id        INTEGER      NOT NULL,
    nome      VARCHAR(100) NOT NULL,
    email     VARCHAR(150),
    cidade    VARCHAR(80),
    pais      VARCHAR(50)  NOT NULL DEFAULT 'Brasil',
    CONSTRAINT pk_clientes PRIMARY KEY (id)
);

-- Tabela de produtos
CREATE TABLE produtos (
    id          INTEGER        NOT NULL,
    nome        VARCHAR(100)   NOT NULL,
    categoria   VARCHAR(50),
    preco       DECIMAL(10, 2) NOT NULL,
    estoque     INTEGER        NOT NULL DEFAULT 0,
    CONSTRAINT pk_produtos PRIMARY KEY (id)
);

-- Tabela de pedidos
CREATE TABLE pedidos (
    id          INTEGER        NOT NULL,
    id_cliente  INTEGER        NOT NULL,
    data_pedido DATE           NOT NULL,
    total       DECIMAL(10, 2),
    status      VARCHAR(20)    NOT NULL DEFAULT 'pendente',
    CONSTRAINT pk_pedidos PRIMARY KEY (id)
);
```

### 2. Inserindo dados de exemplo

```sql
INSERT INTO clientes (id, nome, email, cidade, pais) VALUES
    (1, 'Ana Lima',      'ana@email.com',    'São Paulo',    'Brasil'),
    (2, 'Carlos Mendes', 'carlos@email.com', 'Rio de Janeiro','Brasil'),
    (3, 'Julia Ferreira','julia@email.com',  'Curitiba',     'Brasil'),
    (4, 'Robert Smith',  'robert@email.com', 'New York',     'EUA'),
    (5, 'Maria Santos',  'maria@email.com',  'Lisboa',       'Portugal');

INSERT INTO produtos (id, nome, categoria, preco, estoque) VALUES
    (1, 'Notebook Pro',    'Eletrônicos', 4500.00, 15),
    (2, 'Mouse Ergonômico','Periféricos',   89.90, 80),
    (3, 'Teclado Mecânico','Periféricos',  320.00, 45),
    (4, 'Monitor 27"',     'Eletrônicos', 1890.00, 20),
    (5, 'Headset USB',     'Periféricos',  250.00, 35);

INSERT INTO pedidos (id, id_cliente, data_pedido, total, status) VALUES
    (1, 1, '2024-01-10', 4589.90, 'entregue'),
    (2, 2, '2024-01-12',  320.00, 'entregue'),
    (3, 1, '2024-01-15', 2140.00, 'enviado'),
    (4, 3, '2024-01-18',   89.90, 'pendente'),
    (5, 4, '2024-01-20', 4500.00, 'entregue');
```

### 3. Seu primeiro SELECT

```sql
-- Tudo da tabela clientes
SELECT * FROM clientes;

-- Apenas nome e cidade
SELECT nome, cidade FROM clientes;

-- Só clientes do Brasil
SELECT nome, cidade
FROM   clientes
WHERE  pais = 'Brasil';

-- Ordenado por nome
SELECT nome, cidade
FROM   clientes
WHERE  pais = 'Brasil'
ORDER BY nome;
```

> **Dica:** O `*` retorna todas as colunas. Em produção, prefira sempre listar as colunas explicitamente — é mais claro e mais eficiente.

---

No próximo post da teoria você vai entender cada parte do SELECT em detalhe. Na prática, vamos explorar filtros com WHERE.