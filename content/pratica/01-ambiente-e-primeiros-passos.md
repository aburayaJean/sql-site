---
title: "Prática 01 — Ambiente e Primeiros Passos"
date: 2026-01-01
weight: 10
tags: ["iniciante", "setup"]
categories: ["Prática"]
description: "Configure o ambiente e crie as tabelas base usadas em todos os módulos."
---

{{< download-script src="/scripts/01-primeiros-passos.sql" name="01-primeiros-passos.sql" >}}

Antes de qualquer coisa, execute o script acima. Ele cria as três tabelas do nosso modelo e insere dados de exemplo.

## O que o script faz

1. Cria `clientes` (7 registros)
2. Cria `produtos` (7 registros)
3. Cria `pedidos` (9 registros)
4. Exibe um resumo com `COUNT` de cada tabela

## Como executar

**PostgreSQL (psql):**
```bash
psql -U postgres -d meu_banco -f 01-primeiros-passos.sql
```

**SQL Server (sqlcmd):**
```bash
sqlcmd -S localhost -U sa -P senha -d meu_banco -i 01-primeiros-passos.sql
```

**Ou cole diretamente no DBeaver / pgAdmin / SSMS.**

## Verificação

Após executar, você deve ver:

| tabela | total |
|---|---|
| clientes | 7 |
| produtos | 7 |
| pedidos | 9 |

Se os números baterem, você está pronto para o próximo módulo!
