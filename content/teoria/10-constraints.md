---
title: "Constraints (Restrições)"
date: 2026-01-10
weight: 100
tags: ["intermediário", "constraints", "primary-key", "foreign-key"]
categories: ["Teoria"]
description: "Garanta a integridade dos dados com PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK e NOT NULL."
---

Constraints são **regras que o banco aplica automaticamente** para garantir a qualidade e integridade dos dados.

## PRIMARY KEY

Identifica unicamente cada linha. Implica NOT NULL + UNIQUE.

```sql
CONSTRAINT pk_clientes PRIMARY KEY (id)

-- Chave primária composta
CONSTRAINT pk_matriculas PRIMARY KEY (id_aluno, id_curso)
```

## FOREIGN KEY

Garante que o valor referenciado existe na tabela pai.

```sql
CONSTRAINT fk_pedidos_cliente
    FOREIGN KEY (id_cliente) REFERENCES clientes (id)
```

### ON DELETE / ON UPDATE

| Opção | Comportamento |
|---|---|
| `CASCADE` | propaga a exclusão/atualização |
| `RESTRICT` | impede se houver filhos |
| `SET NULL` | seta NULL na FK |
| `NO ACTION` | igual a RESTRICT (padrão) |

## UNIQUE

```sql
CONSTRAINT uq_clientes_email UNIQUE (email)
```

Permite NULL (uma linha pode ter NULL; múltiplas NULLs são permitidas na maioria dos SGBDs).

## NOT NULL

Declarado inline na coluna:

```sql
nome VARCHAR(100) NOT NULL
```

## CHECK

Valida um domínio de valores:

```sql
CONSTRAINT ck_nota  CHECK (nota BETWEEN 1 AND 5)
CONSTRAINT ck_ativo CHECK (ativo IN ('S', 'N'))
CONSTRAINT ck_preco CHECK (preco > 0)
```

## DEFAULT

```sql
pais      VARCHAR(50) NOT NULL DEFAULT 'Brasil'
criado_em TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
```

## Adicionar/remover em tabela existente

```sql
ALTER TABLE clientes
    ADD CONSTRAINT uq_email UNIQUE (email);

ALTER TABLE clientes
    DROP CONSTRAINT uq_email;
```

## Próximo passo

[Módulo 11 — Índices](/teoria/11-indices/)
