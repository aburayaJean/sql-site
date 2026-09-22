---
title: "Pense em conjuntos, não em linhas"
description: "A virada de chave de quem vem da programação: por que um UPDATE resolve em milissegundos o que um loop leva segundos para fazer."
date: 2026-09-22T08:09:00-04:00
weight: 9
roadmap: "set-based"
tags: ["fundamentos", "iniciante", "performance"]
---

Último post dos Fundamentos, e talvez o que mais vai mudar o jeito como você escreve SQL.

Quem aprende a programar primeiro em C#, Java, Python ou qualquer outra linguagem aprende a resolver problemas **linha por linha**: pega um item, processa, pega o próximo. Aí chega no SQL e faz a mesma coisa. Funciona, mas é o jeito mais lento possível de usar um banco de dados.

## O banco pensa em conjuntos

Lembra do Codd e do modelo relacional? Ele se baseia em **teoria dos conjuntos**. Uma tabela é um conjunto de linhas, e os comandos SQL operam sobre **conjuntos inteiros** de uma vez.

Compare os dois pedidos que você pode fazer ao banco:

**Pensando em linhas:**
> "Pega o primeiro produto. Aumenta 10% no preço. Salva. Pega o próximo. Aumenta 10%. Salva. Pega o próximo..."

**Pensando em conjuntos:**
> "Aumenta 10% no preço de todos os produtos de Informática."

```sql
-- Só para ilustrar, não precisa rodar este
UPDATE dbo.Produtos
SET    Preco = Preco * 1.10
WHERE  Categoria = N'Informática';
```

No segundo jeito você descreve **o resultado**, e o banco decide como fazer da forma mais eficiente. Lembra do SQL declarativo, do post sobre SQL e T-SQL? É a mesma ideia levada para a prática.

## Por que o linha a linha é tão mais lento

Não é "um pouquinho" mais lento. Muitas vezes é **cem, mil vezes** mais lento. Alguns motivos:

- **Cada comando tem um custo fixo:** ser interpretado, ter um plano escolhido, pedir e liberar locks. No loop, você paga esse custo em cada linha.
- **Cada comando é uma transação.** Sem uma transação explícita, cada `UPDATE` do loop é confirmado sozinho, e cada confirmação precisa esperar a gravação no transaction log, no disco. Mil linhas, mil esperas de disco.
- **O otimizador não consegue ajudar.** Com o conjunto inteiro, ele pode escolher o melhor caminho, usar paralelismo, ler as páginas em sequência. Com uma linha de cada vez, não sobra nada para otimizar.
- **Se o loop roda na aplicação, piora:** cada linha vira uma ida e volta pela rede.

A comunidade SQL tem até um apelido para isso: **RBAR**, *Row By Agonizing Row* ("linha por agonizante linha").

## Então cursor e loop são proibidos?

Não. Tem caso em que processar item por item é o certo: rodar um comando administrativo em cada banco da instância, chamar uma procedure que só aceita um registro por vez, processar em lotes para não travar uma tabela gigante. O ponto é que **loop deve ser a exceção que você escolhe conscientemente**, não o primeiro reflexo.

A pergunta para fazer sempre: *"dá para escrever isso como uma operação sobre o conjunto inteiro?"* Quase sempre dá.

## Bora pra prática

Vamos medir. Criar uma tabela com 100 mil linhas e aumentar 10% em todas: primeiro com um loop, depois com um `UPDATE` só. Use o banco Loja. Se ainda não criou, rode o [script de setup](/sql-site/scripts/fundamentos/00-loja-setup.sql).

### Preparar a tabela

```sql
USE Loja;

DROP TABLE IF EXISTS dbo.TesteConjuntos;

CREATE TABLE dbo.TesteConjuntos (
    Id    INT           NOT NULL CONSTRAINT PK_TesteConjuntos PRIMARY KEY,
    Valor DECIMAL(12,2) NOT NULL
);

-- Gera 100.000 linhas de uma vez (sim, sem loop)
INSERT INTO dbo.TesteConjuntos (Id, Valor)
SELECT TOP (100000)
       ROW_NUMBER() OVER (ORDER BY (SELECT NULL)),
       100.00
FROM   sys.all_objects AS a
CROSS JOIN sys.all_objects AS b;

SELECT COUNT(*) AS Linhas FROM dbo.TesteConjuntos;
```

O próprio `INSERT` já é pensamento em conjunto: ele combina uma tabela de sistema com ela mesma para fabricar linhas, e numera cada uma com `ROW_NUMBER`. Não se preocupe com os detalhes; o truque tem post próprio.

### Jeito 1: linha a linha

```sql
SET NOCOUNT ON;

DECLARE @inicio DATETIME2 = SYSDATETIME(),
        @id     INT       = 1;

WHILE @id <= 100000
BEGIN
    UPDATE dbo.TesteConjuntos
    SET    Valor = Valor * 1.10
    WHERE  Id = @id;

    SET @id += 1;
END;

SELECT DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()) AS MsLinhaALinha;
GO
```

Vai buscar um café. Dependendo da sua máquina e do seu disco, isso leva de alguns segundos a mais de um minuto.

### Jeito 2: o conjunto inteiro

```sql
DECLARE @inicio DATETIME2 = SYSDATETIME();

UPDATE dbo.TesteConjuntos
SET    Valor = Valor * 1.10;

SELECT DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()) AS MsConjunto;
GO
```

Compare os dois números. Os tempos exatos variam de máquina para máquina, mas a diferença costuma ser de **dezenas a centenas de vezes**. Mesmo resultado, uma linha de código, e muito mais rápido.

### Um bônus para pensar

Rode o jeito 1 de novo, mas com o loop inteiro dentro de uma transação:

```sql
SET NOCOUNT ON;

DECLARE @inicio DATETIME2 = SYSDATETIME(),
        @id     INT       = 1;

BEGIN TRANSACTION;

WHILE @id <= 100000
BEGIN
    UPDATE dbo.TesteConjuntos
    SET    Valor = Valor * 1.10
    WHERE  Id = @id;

    SET @id += 1;
END;

COMMIT TRANSACTION;

SELECT DATEDIFF(MILLISECOND, @inicio, SYSDATETIME()) AS MsLoopComTransacao;
GO
```

Ficou bem mais rápido que o primeiro loop, não ficou? Agora são 100 mil `UPDATE`s, mas uma única confirmação no log, em vez de 100 mil. Ainda assim, deve perder feio para o `UPDATE` único. Essa é a primeira pista de um assunto enorme que a gente vai destrinchar na trilha de performance: **o que o banco está esperando** enquanto sua query roda.

### Limpeza

```sql
DROP TABLE dbo.TesteConjuntos;
```

## Fim dos Fundamentos

Se você chegou até aqui, já sabe o que é um banco de dados e um SGBD, entende a diferença entre relacional e NoSQL, sabe o que é SQL e T-SQL, conhece as famílias de comandos e a hierarquia do SQL Server, entende o caminho de uma query até o banco, a ordem lógica de execução, o NULL, e pensa em conjuntos.

Não é pouca coisa. Com essa base, todo o resto vai fazer muito mais sentido.

---

**Próxima parada:** Ambiente e Ferramentas, onde a gente monta o seu ambiente com calma e aprende a tirar o máximo do SSMS.
