---
title: "Downloads — Scripts SQL"
description: "Todos os scripts SQL do blog, organizados por tema. Prontos para usar no seu SGBD."
toc: false
---

Scripts seguindo **ANSI SQL** — funcionam no PostgreSQL, SQL Server, MySQL, Oracle e outros SGBDs compatíveis. Cada arquivo é comentado e pode ser executado direto.

---

## 📦 Download Completo

<a href="/sql-site/scripts/todos-os-scripts.zip" download class="download-all-btn">
  ⬇ Baixar todos os scripts (.zip)
</a>

---

## 📄 Scripts por Tema

### Fundamentos

| Tema | Arquivo |
|------|---------|
| Ambiente e Primeiros Passos | <a href="/sql-site/scripts/01-primeiros-passos.sql" download>⬇ 01-primeiros-passos.sql</a> |
| SELECT e WHERE | <a href="/sql-site/scripts/02-select-where.sql" download>⬇ 02-select-where.sql</a> |
| ORDER BY, DISTINCT e LIMIT | <a href="/sql-site/scripts/03-order-distinct-limit.sql" download>⬇ 03-order-distinct-limit.sql</a> |
| Funções de Agregação | <a href="/sql-site/scripts/04-agregacao.sql" download>⬇ 04-agregacao.sql</a> |
| GROUP BY e HAVING | <a href="/sql-site/scripts/05-group-by-having.sql" download>⬇ 05-group-by-having.sql</a> |

### Modelagem e Manipulação

| Tema | Arquivo |
|------|---------|
| JOINs | <a href="/sql-site/scripts/06-joins.sql" download>⬇ 06-joins.sql</a> |
| Subqueries | <a href="/sql-site/scripts/07-subqueries.sql" download>⬇ 07-subqueries.sql</a> |
| INSERT, UPDATE e DELETE | <a href="/sql-site/scripts/08-dml.sql" download>⬇ 08-dml.sql</a> |
| DDL — Criação de Tabelas | <a href="/sql-site/scripts/09-ddl.sql" download>⬇ 09-ddl.sql</a> |
| Constraints | <a href="/sql-site/scripts/10-constraints.sql" download>⬇ 10-constraints.sql</a> |

### Performance e Estruturas Avançadas

| Tema | Arquivo |
|------|---------|
| Índices | <a href="/sql-site/scripts/11-indices.sql" download>⬇ 11-indices.sql</a> |
| Transações (ACID) | <a href="/sql-site/scripts/12-transacoes.sql" download>⬇ 12-transacoes.sql</a> |
| Views | <a href="/sql-site/scripts/13-views.sql" download>⬇ 13-views.sql</a> |
| CTEs (WITH) | <a href="/sql-site/scripts/14-ctes.sql" download>⬇ 14-ctes.sql</a> |
| Window Functions | <a href="/sql-site/scripts/15-window-functions.sql" download>⬇ 15-window-functions.sql</a> |
| Funções JSON | <a href="/sql-site/scripts/16-funcoes-json.sql" download>⬇ 16-funcoes-json.sql</a> |
| Funções XML | <a href="/sql-site/scripts/17-funcoes-xml.sql" download>⬇ 17-funcoes-xml.sql</a> |

---

> 💡 Rode o script `01-primeiros-passos.sql` primeiro — ele cria as tabelas `clientes`, `produtos` e `pedidos` usadas nos outros exemplos.

<style>
.download-all-btn {
  display: inline-block;
  background: #0070f3;
  color: white !important;
  padding: 12px 28px;
  border-radius: 8px;
  font-weight: bold;
  text-decoration: none;
  font-size: 1.1rem;
  margin: 8px 0;
  transition: background 0.2s;
}
.download-all-btn:hover { background: #005bb5; }
</style>
