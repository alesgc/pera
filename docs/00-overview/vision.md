# Documentação de Arquitetura de Dados & Regras de Negócio

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)

**Versão:** 1.0.0

**Status:** Especificação Técnica Aprovada

**SGBD Alvo:** PostgreSQL 15+

---

## 1. Visão Geral do Sistema

O **Ecosystem Financeiro & Analítico** é uma plataforma analítica e operacional unificada. O sistema engloba a ingestão e tratamento de dados brutos de finanças e investimentos, armazenamento relacional estruturado, exposição via API REST, visualizações em tempo real (Web e Power BI) e um motor de automação de alertas.

```
┌────────────────────────┐
│  Fontes de Dados       │ (Arquivos CSV / Extratos / APIs de Cotação)
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  1. Engine ETL         │ (Python, Pandas, Pydantic, Logging)
└───────────┬────────────┘
            │
            ▼
┌────────────────────────┐
│  2. Banco de Dados     │ (PostgreSQL: Relacional, Audit, Logs, Views)
└─────┬──────────────┬───┘
      │              │
      ▼              ▼
┌───────────┐  ┌──────────────┐
│ 3. API    │  │ 4. Power BI  │ (Dashboards Analíticos & DAX)
└─────┬─────┘  └──────────────┘
      │
      ├──────────────────────────────┐
      ▼                              ▼
┌───────────┐                  ┌─────────────┐
│ 5. Web    │ (Next.js/Tailwind)│ 6. Worker   │ (Alertas/Mensageria)
└───────────┘                  └─────────────┘

```

---

## 2. Mapeamento de Entidades e Domínio de Dados

| Camada / Domínio | Entidades / Conjunto | Campos Principais | Finalidade e Regra de Negócio |
| --- | --- | --- | --- |
| **Transações** | `transacoes`, `categorias` | `id`, `data_transacao`, `valor`, `tipo`, `categoria_id`, `descricao`, `meio_pagamento` | Registrar entradas e saídas financeiras; associar teto orçamentário por categoria. |
| **Investimentos** | `ativos`, `cotacoes_historico` | `ticker`, `nome`, `tipo_ativo`, `quantidade_total`, `preco_medio`, `preco_fechamento` | Acompanhar posição patrimonial, movimentações de compra/venda e variação de mercado. |
| **ETL & Qualidade** | `log_etl` | `id`, `nome_pipeline`, `inicio_execucao`, `fim_execucao`, `status`, `registros_inseridos`, `hash_arquivo` | Garantir idempotência na carga de arquivos e auditabilidade do pipeline de dados. |
| **Auditoria** | `log_auditoria` | `id`, `nome_tabela`, `registro_id`, `operacao`, `dados_antigos`, `dados_novos`, `executado_em` | Rastreamento histórico de alterações via payload JSONB (INSERT/UPDATE/DELETE). |
| **Mensageria & Alertas** | `regras_alertas`, `log_alertas` | `id`, `tipo_alerta`, `valor_limite`, `canal`, `mensagem`, `status_envio`, `enviado_em` | Disparo e rastreamento de notificações (E-mail/Telegram) acionadas por regras de negócio. |
| **API & BI** | `vw_resumo_mensal` (View) | `mes_ano`, `tipo`, `categoria`, `total_gasto`, `orcamento_mensal_limite` | Camada de agregação otimizada para alimentar endpoints REST e dashboards. |

---

## 3. DDL do Banco de Dados (PostgreSQL)

```sql
-- ==========================================
-- 1. TABELAS DE DOMÍNIO FINANCEIRO & ATIVOS
-- ==========================================

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA')),
    orcamento_mensal_limite NUMERIC(12, 2) DEFAULT 0.00 CHECK (orcamento_mensal_limite >= 0),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    data_transacao DATE NOT NULL CHECK (data_transacao <= CURRENT_DATE),
    descricao VARCHAR(150) NOT NULL,
    valor NUMERIC(12, 2) NOT NULL CHECK (valor > 0),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA')),
    categoria_id INT NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    meio_pagamento VARCHAR(30) DEFAULT 'OUTROS',
    hash_transacao VARCHAR(64) UNIQUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ativos (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    tipo_ativo VARCHAR(30) NOT NULL CHECK (tipo_ativo IN ('ACAO', 'FII', 'CRIPTO', 'RENDA_FIXA')),
    quantidade_total NUMERIC(15, 6) DEFAULT 0.00 CHECK (quantidade_total >= 0),
    preco_medio NUMERIC(12, 2) DEFAULT 0.00 CHECK (preco_medio >= 0)
);

CREATE TABLE cotacoes_historico (
    id SERIAL PRIMARY KEY,
    ativo_id INT NOT NULL REFERENCES ativos(id) ON DELETE CASCADE,
    data_cotacao DATE NOT NULL,
    preco_fechamento NUMERIC(12, 2) NOT NULL CHECK (preco_fechamento > 0),
    CONSTRAINT uk_ativo_data UNIQUE (ativo_id, data_cotacao)
);

-- ==========================================
-- 2. TABELAS DE MENSAGERIA E ALERTAS
-- ==========================================

CREATE TABLE regras_alertas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL CHECK (tipo_alerta IN ('TETO_CATEGORIA', 'SALDO_MINIMO', 'VARIACAO_ATIVO')),
    categoria_id INT REFERENCES categorias(id) ON DELETE CASCADE,
    valor_limite NUMERIC(12, 2) NOT NULL,
    canal VARCHAR(20) NOT NULL CHECK (canal IN ('EMAIL', 'TELEGRAM')),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE log_alertas (
    id SERIAL PRIMARY KEY,
    regra_id INT REFERENCES regras_alertas(id) ON DELETE SET NULL,
    destinatario VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    status_envio VARCHAR(20) NOT NULL CHECK (status_envio IN ('PENDENTE', 'SUCESSO', 'FALHA')),
    enviado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. TABELAS DE AUDITORIA E ETL
-- ==========================================

CREATE TABLE log_etl (
    id SERIAL PRIMARY KEY,
    nome_pipeline VARCHAR(100) NOT NULL,
    inicio_execucao TIMESTAMP NOT NULL,
    fim_execucao TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('EM_ANDAMENTO', 'SUCESSO', 'ERRO')),
    registros_inseridos INT DEFAULT 0,
    registros_rejeitados INT DEFAULT 0,
    mensagem_erro TEXT,
    nome_arquivo VARCHAR(255),
    hash_arquivo VARCHAR(64)
);

CREATE TABLE log_auditoria (
    id SERIAL PRIMARY KEY,
    nome_tabela VARCHAR(50) NOT NULL,
    registro_id INT NOT NULL,
    operacao VARCHAR(10) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    dados_antigos JSONB,
    dados_novos JSONB,
    executado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 4. VIEWS ANALÍTICAS PARA API E DASHBOARD
-- ==========================================

CREATE VIEW vw_resumo_mensal AS
SELECT 
    TO_CHAR(data_transacao, 'YYYY-MM') AS mes_ano,
    tipo,
    c.nome AS categoria,
    SUM(valor) AS total_gasto,
    c.orcamento_mensal_limite
FROM transacoes t
JOIN categorias c ON t.categoria_id = c.id
GROUP BY TO_CHAR(data_transacao, 'YYYY-MM'), tipo, c.nome, c.orcamento_mensal_limite;

```

---

## 4. Regras de Negócio (Core Logic)

### 4.1. Recálculo de Preço Médio em Ativos

Nas operações de compra de ativos, o preço médio é atualizado pela média ponderada das quantidades e preços de aquisição:

$$\text{PM}_{\text{novo}} = \frac{(\text{Qtd}_{\text{atual}} \times \text{PM}_{\text{atual}}) + (\text{Qtd}_{\text{comprada}} \times \text{Preço}_{\text{compra}})}{\text{Qtd}_{\text{atual}} + \text{Qtd}_{\text{comprada}}}$$

### 4.2. Venda de Ativos

Vendas subtraem a `quantidade_total` do ativo sem alterar o `preco_medio`. Transações com quantidade superior ao saldo em carteira devem ser rejeitadas pela aplicação.

### 4.3. Avaliação de Teto Orçamentário

Se $\sum \text{despesas\_categoria\_mes} > \text{orcamento\_mensal\_limite}$, o sistema grava um registro na tabela `log_alertas` com o status `'PENDENTE'`.

### 4.4. Consolidação Patrimonial

O saldo patrimonial total é derivado pela equação:

$$\text{Patrimônio Total} = \sum (\text{Qtd}_{\text{ativo}} \times \text{Última Cotação}) + (\sum \text{Receitas} - \sum \text{Despesas})$$

---

## 5. Regras de Validação & Data Quality

| Entidade / Campo | Regra Técnica / Padrão | Ação / Tratamento de Erro |
| --- | --- | --- |
| `transacoes.valor` | Numérico estritamente positivo ($> 0$). | Rejeição imediata (`HTTP 422` ou log de erro ETL). |
| `transacoes.data_transacao` | Menor ou igual à data atual ($\le \text{CURRENT\_DATE}$). | Rejeitar lançamentos com datas futuras. |
| `transacoes.hash_transacao` | Hash SHA-256 gerado a partir de `data + valor + descricao + categoria_id`. | Bloquear inserções duplicadas no banco. |
| `ativos.ticker` | Expressão Regular: `^[A-Z0-9]{4,10}$` | Aplicar `.strip().upper()` antes de validar. |
| `categorias.orcamento_mensal_limite` | Numérico maior ou igual a zero ($\ge 0$). | Exibir erro de validação caso seja negativo. |

---

## 6. Regras de ETL e Ingestão de Dados

1. **Idempotência por Hash de Arquivo:** Cada arquivo processado tem seu hash SHA-256 gravado na coluna `log_etl.hash_arquivo`. Se o mesmo hash for detectado em execuções futuras, a carga é abortada.
2. **Estratégia de Staging e Falhas Parciais:** Linhas com erros de formato são gravadas em arquivo de erros (log/quarentena) incrementando `registros_rejeitados`, permitindo que os registros válidos sigam para gravação no banco.
3. **Rastreabilidade de Pipeline:**
* **Início:** Insere registro em `log_etl` com status `'EM_ANDAMENTO'`.
* **Conclusão:** Atualiza `fim_execucao`, `status` (`'SUCESSO'` ou `'ERRO'`), `registros_inseridos` e `registros_rejeitados`.



---

## 7. Regras de Web & API (FastAPI)

### 7.1. Padronização de HTTP Status Codes

* `200 OK`: Execução de consulta ou leitura bem-sucedida.
* `201 Created`: Inserção de novo registro (transação, ativo ou alerta).
* `400 Bad Request`: Erro de regra de negócio ou parâmetros incorretos.
* `422 Unprocessable Entity`: Falha na validação do schema Pydantic.
* `500 Internal Server Error`: Erro inesperado no servidor/banco de dados.

### 7.2. Paginação Obrigatória

Endpoints de listagem devem aceitar os parâmetros de query `page` (padrão 1) e `limit` (padrão 50, máximo 200).

### 7.3. Estrutura Padrão de Retorno de Erro

```json
{
  "error": "NOME_DO_ERRO",
  "message": "Descrição detalhada sobre a causa do erro",
  "timestamp": "2026-10-01T14:00:00Z"
}

```

---

## 8. Regras de Visualização, UX & BI

* **Paleta Semântica de Cores:**
* **Verde:** Receitas, rendimentos positivos e metas atingidas.
* **Vermelho:** Despesas, prejuízos de ativos e estouro de teto orçamentário.
* **Azul / Grafite:** Métricas neutras (patrimônio total, saldo líquido consolidado).


* **Formatação Monetária:** Valores em moeda devem utilizar obrigatoriamente a formatação: `R$ #.##0,00`.
* **Diretrizes de Gráficos:**
* Proibido o uso de gráficos de pizza ou rosca para dimensões com mais de 5 categorias. Nesses casos, utilizar gráficos de barras horizontais ordenadas.
* Filtros temporais padrão: Mês atual para visão de caixa; Histórico completo para evolução patrimonial.



---

## 9. Estrutura de Arquivos para o Repositório de Docs

```text
docs/
├── architecture/
│   ├── data-flow.md          # Diagramas de fluxo de dados
│   └── architecture-overview.md
├── database/
│   ├── ddl.sql               # Script SQL consolidado
│   └── data-dictionary.md    # Dicionário de dados
├── rules/
│   ├── business-rules.md     # Regras de negócio e cálculos
│   └── etl-rules.md          # Regras de validação e ingestão
└── README.md                 # Sumário executivo da documentação

```