---
title: "Analisando Consumo de CPU no SQL Server"
date: 2024-01-15
draft: false
tags: ["sql-server", "performance", "dmv", "cpu"]
categories: ["Performance"]
description: "Como identificar quais queries estão consumindo mais CPU usando DMVs do SQL Server"
---

Se você precisa identificar rapidamente quais queries estão comendo a CPU do seu SQL Server, esta DMV resolve em segundos.

## O Script

```sql
SELECT TOP 20
    qs.total_worker_time / qs.execution_count AS avg_cpu_time,
    qs.total_worker_time                       AS total_cpu_time,
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    SUBSTRING(
        qt.text,
        (qs.statement_start_offset / 2) + 1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
          END - qs.statement_start_offset) / 2) + 1
    ) AS query_text,
    DB_NAME(qt.dbid) AS database_name,
    qp.query_plan
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY avg_cpu_time DESC;
```

## Como interpretar

| Coluna | O que significa |
|---|---|
| `avg_cpu_time` | Tempo médio de CPU por execução (microssegundos) |
| `total_cpu_time` | CPU total gasta desde o último restart |
| `execution_count` | Quantas vezes a query foi executada |
| `query_text` | Texto da query |

## Dicas

- Execute com frequência para capturar o padrão de uso
- Valores acima de 100.000 microssegundos por execução merecem atenção
- Analise o `query_plan` no XML Plan Viewer para identificar operadores custosos