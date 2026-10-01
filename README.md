# 🍐 PERA — Ecosystem Financeiro & Analítico

> **Pēra** *(do latim pēra: saquinho de moedas / bolsa de cinto medieval)*  
> Plataforma de Engenharia de Dados, Analytics e Gestão de Ativos Multimoeda.

---

## 🏛️ Contexto Identitário & Conceito

O **Pera** é estruturado conceitualmente como uma solução corporativa de *Wealth Management* e *Financial Analytics*. O nome resgata a origem latina da palavra **pēra** — o saquinho de moedas amarrado ao cinto na Idade Média, que servia como a carteira padrão para o transporte de recursos e moedas de ouro/prata.

Em termos de engenharia, o projeto simula um ecossistema de nível de produção para consolidar dados transacionais e de mercado financeiro, aplicando princípios de **arquitetura limpa, resiliência de ETL, idempotência, auditoria mutacional e modelagem analítica multimoeda**.

---

## 📐 Arquitetura do Sistema

```text
[ Extratos CSV/Excel ] ──► [ Engine ETL (Python/Pandas) ] ──► [ PostgreSQL 15+ ] ──► [ FastAPI REST API ] ──► [ Next.js Dashboard ]
[ APIs de Mercado ]    ──► [ Validação Pydantic v2 ]       │                  │
                                                            ├──► [ JSONB Audit ] └──► [ Power BI Reports ]
                                                            └──► [ PTAX Cambial]

```

### Principais Pilares Técnicos

1. **Deduplicação & Idempotência (SHA-256):** Hashing determinístico em dois níveis (arquivo e transação individual).
2. **Segregação de Fluxo Operacional:** Separação estrita entre `RECEITA`, `DESPESA` (custo de vida) e `INVESTIMENTO` (alocação de capital em ativos), garantindo que compras de ações não distorçam o teto orçamentário.
3. **Multimoeda & PTAX (USD/BRL):** Avaliação patrimonial com conversão automática de ativos cotados em Dólar (`USD`) usando a taxa oficial PTAX de fechamento do Banco Central do Brasil.
4. **Governança & Quarentena:** Isolamento de registros corrompidos em arquivo CSV de quarentena sem interromper o lote de carga.
5. **Schema Evolution:** Controle evolutivo de banco de dados e migrações DDL via **Alembic**.

---

## 📂 Estrutura da Documentação (`/docs`)

A documentação técnica do ecossistema está organizada sequencialmente:

| Diretório | Descrição e Conteúdo |
| --- | --- |
| **[`docs/00-architecture`](https://www.google.com/search?q=./docs/00-architecture)** | Arquitetura geral do sistema, diagramas de fluxo e decisões de design (ADRs). |
| **[`docs/01-requirements`](https://www.google.com/search?q=./docs/01-requirements)** | Requisitos funcionais (RFs) e não funcionais (RNFs). |
| **[`docs/02-database`](https://www.google.com/search?q=./docs/02-database)** | Script `ddl.sql` (v1.2.0), Dicionário de Dados e diagramas ER. |
| **[`docs/03-business-rules`](https://www.google.com/search?q=./docs/03-business-rules)** | Fórmulas matematicas de Preço Médio, PTAX, regras de liquidez e quarentena. |
| **[`docs/04-etl-pipelines`](https://www.google.com/search?q=./docs/04-etl-pipelines)** | Mapeamentos Source-to-Target, tratamento de erros e idempotência. |
| **[`docs/05-api`](https://www.google.com/search?q=./docs/05-api)** | Contratos Pydantic DTOs e especificação dos endpoints REST do FastAPI. |
| **[`docs/06-frontend-bi`](https://www.google.com/search?q=./docs/06-frontend-bi)** | Catálogo de medidas DAX para o Power BI e guia visual/paleta semântica. |
| **[`docs/07-ops-dev`](https://www.google.com/search?q=./docs/07-ops-dev)** | Guia de instalação local, Docker Compose e dicionário de `.env`. |
| **[`docs/08-archive`](https://www.google.com/search?q=./docs/08-archive)** | Histórico de alterações e especificações descontinuadas. |

---

## 🛠️ Stack Tecnológica

* **Linguagem & Core:** Python 3.12+ / Pandas / Pydantic v2
* **Banco de Dados:** PostgreSQL 15+ / SQLAlchemy ORM / Alembic Migrations
* **Backend API:** FastAPI / Uvicorn
* **Frontend Web:** Next.js 14 / TypeScript / Tailwind CSS
* **Business Intelligence:** Power BI Desktop (DAX / Tabular Model)
* **DevOps & Infra:** Docker / Docker Compose / Git

---

## 🚀 Como Executar o Projeto Localmente

### 1. Subir a Infraestrutura (PostgreSQL)

```bash
cp .env.example .env
docker-compose up -d postgres

```

### 2. Configurar o Ambiente Python e Aplicar Migrações

```bash
python3 -m venv .venv
source .venv/bin/activate  # No Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Aplicar migrações do banco com Alembic
alembic upgrade head

```

### 3. Executar o Backend API (FastAPI)

```bash
uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000

```

* **Swagger UI:** `http://localhost:8000/docs`

```

---

<ElicitationsGroup message="A documentação institucional e técnica está 100% pronta e consolidada. Deseja iniciar a implementação da Fase 1 em código Python?">
  <Elicitation label="Criar conexão SQLAlchemy e gerenciador de sessões (src/database/database.py)" query="Inicie a Fase 1 da implementação técnica: crie o arquivo src/database/database.py com a conexão SQLAlchemy e o gerenciador de sessões."/>
  <Elicitation label="Mapear modelos ORM no Python (src/database/models.py)" query="Gere o arquivo src/database/models.py com todos os modelos ORM das tabelas atualizadas usando SQLAlchemy."/>
</ElicitationsGroup>

```