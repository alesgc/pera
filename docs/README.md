# 🚀 Ecosystem Financeiro & Analítico (End-to-End)

> **Categoria:** Python / SQL / Web  
> **Links:** [Repositório](https://github.com/alesgc/ecosystem-financeiro) | [Deploy](https://finance-ecosystem.vercel.app)

<!-- PORTFOLIO:SUMMARY_START -->
Plataforma analítica e operacional integrada para gestão financeira e de investimentos. Une pipeline de ingestão ETL automatizado em Python, persistência relacional em PostgreSQL, API REST de alta performance em FastAPI, interface interativa em Next.js, relatórios analíticos em Power BI e sistema de mensageria para alertas orçamentários.
<!-- PORTFOLIO:SUMMARY_END -->

---

## 📌 01. Motivação & Contexto
<!-- PORTFOLIO:MOTIVATION_START -->
A fragmentação de dados financeiros em múltiplos extratos bancários, planilhas manuais e corretoras dificulta a consolidação do patrimônio líquido e o controle rigoroso de despesas. A falta de padronização gera inconsistências, impede a identificação oportuna de estouros de orçamento e torna o cálculo do preço médio de ativos de investimentos um processo lento e propenso a falhas humanas. 

Este projeto foi concebido para resolver a dor da descentralização, automatizando o ciclo de vida completo do dado: da extração bruta à decisão estratégica visual.
<!-- PORTFOLIO:MOTIVATION_END -->

## 🛠️ 02. Solução Técnica & Arquitetura
<!-- PORTFOLIO:SOLUTION_START -->
Foi projetada uma arquitetura orientada a serviços e pipelines desacoplados (*Clean Architecture* simplificada) cobrindo quatro camadas principais:

1. **Camada de Ingestão e ETL (Python/Pandas/Pydantic):** Leitura idempotente de extratos (CSV/Excel) e cotações de mercado via API. Aplica controle de duplicações via *hash* SHA-256 e validação estrita de esquemas.
2. **Camada de Armazenamento & Auditoria (PostgreSQL):** Modelo relacional com suporte a tabelas de domínio (transações, categorias, ativos), auditoria mutacional em JSONB (`log_auditoria`), logs de pipeline (`log_etl`) e *Views* analíticas otimizadas para consulta.
3. **Camada de Serviços & Consumo (FastAPI + Next.js + Power BI):** API REST assíncrona expondo métricas agregadas e endpoints paginados, consumidos por uma interface web responsiva em Next.js/Tailwind e por relatórios em Power BI (com modelos em DAX).
4. **Motor de Alertas & Mensageria (Worker Python):** Monitor em segundo plano que avalia regras de negócios (ex: estouro de limite por categoria) e dispara notificações automáticas via E-mail e Telegram.
<!-- PORTFOLIO:SOLUTION_END -->

## 📈 03. Impacto & Resultados
<!-- PORTFOLIO:IMPACT_START -->
* **100% de Idempotência:** Eliminação total de transações duplicadas no banco através de verificação por hash SHA-256 no pipeline ETL.
* **Redução no Tempo de Leitura:** Resposta média de consultas analíticas em sub-100ms utilizando *SQL Views* indexadas para agregações mensais.
* **Governança de Dados:** Rastreabilidade completa e auditabilidade de alterações via logs em JSONB para conformidade de dados.
* **Automação de Alertas:** Notificação em tempo real sobre desvios orçamentários sem necessidade de intervenção humana manual.
<!-- PORTFOLIO:IMPACT_END -->

---

## 💻 Guia de Implementação e Execução

### 🛠️ Stack Tecnológica Detalhada

| Camada | Tecnologia / Biblioteca | Versão |
| :--- | :--- | :--- |
| **Linguagem Base** | Python | 3.12+ |
| **Banco de Dados** | PostgreSQL | 15+ |
| **Engenharia de Dados** | Pandas, Pydantic, SQLAlchemy, Psycopg2 | Últimas |
| **Backend & API** | FastAPI, Uvicorn | 0.110+ |
| **Frontend Web** | Next.js, React, Tailwind CSS | 14+ |
| **Business Intelligence** | Power BI Desktop (DAX) | - |
| **Ambiente & Deploy** | Docker, Docker Compose, Vercel | - |

---

### 📂 Estrutura de Pastas e Módulos

```text
.
├── docs/                      # Documentação detalhada e modularizada do projeto
│   ├── 00-overview/           # Visão macro da arquitetura
│   ├── 01-architecture/       # Decisões de arquitetura (ADRs) e fluxos de dados
│   ├── 02-database/           # DDL.sql, Diagrama ER e Dicionário de dados
│   ├── 03-business-rules/     # Fórmulas de preço médio, patrimônio e data quality
│   ├── 04-etl-pipelines/      # Regras de quarentena, logs e idempotência
│   ├── 05-api/                # Schemas Pydantic e contratos de rotas
│   └── 06-frontend-bi/        # Medidas DAX e guia visual
├── src/
│   ├── api/                   # Aplicação FastAPI (rotas, controllers)
│   ├── etl/                   # Scripts de extração, tratamento e validação (Pandas)
│   ├── database/              # Conexão, migrations e modelos SQLAlchemy
│   ├── workers/               # Script de mensageria e disparo de alertas
│   └── web/                   # Aplicação Next.js (Dashboard)
├── docker-compose.yml         # Containerização do PostgreSQL e instâncias
├── .env.example               # Modelo de variáveis de ambiente
├── requirements.txt           # Dependências do ecossistema Python
└── README.md                  # Este arquivo de apresentação