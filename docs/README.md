# 📚 Central de Documentação Técnica

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Versão:** 1.0.0  
**SGBD Alvo:** PostgreSQL 15+  
**Linguagem Base:** Python 3.12+ / TypeScript  

---

## 🧭 Visão Geral & Índice Navegável

Esta pasta contém toda a especificação de arquitetura, modelagem de banco de dados, regras de negócio, contratos de API e diretrizes de interface do projeto. A documentação segue uma estrutura modular numerada para facilitar a leitura e o versionamento isolado no Git.

```text
docs/
├── 📄 README.md                      <-- Você está aqui (Índice Geral)
├── 📂 00-overview/                   <-- Visão macro e objetivos
├── 📂 01-architecture/               <-- Decisões de Arquitetura (ADRs) e Fluxos
├── 📂 02-database/                   <-- DDL SQL, Dicionário e Diagrama ER
├── 📂 03-business-rules/             <-- Regras de Cálculo, Finanças e Data Quality
├── 📂 04-etl-pipelines/              <-- Regras de Ingestão, Idempotência e Erros
├── 📂 05-api/                        <-- Contratos REST, Schemas Pydantic e Rotas
├── 📂 06-frontend-bi/                <-- Medidas DAX, UX e Diretrizes do Power BI
└── 📂 07-ops-dev/                    <-- Guia de Setup Local, Docker e Variáveis