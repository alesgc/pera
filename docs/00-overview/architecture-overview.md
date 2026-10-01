# 🏗️ Arquitetura Macro do Sistema

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Padrão de Arquitetura:** Arquitetura Modular em Camadas com Pipelines Desacoplados  

---

## 1. Visão Geral da Arquitetura

O sistema é estruturado em **cinco camadas desacopladas**, garantindo que cada componente possua uma responsabilidade única e bem definida. Essa abordagem permite a manutenção isolada de qualquer módulo (por exemplo, atualizar o frontend Web sem impactar os pipelines de ETL ou as rotas da API).

```mermaid
flowchart TB
    subgraph Fonts ["1. Fontes de Dados Externas"]
        CSV[Extratos CSV / Excel]
        API_COT[APIs de Cotações de Mercado]
    end

    subgraph ETL_Layer ["2. Camada de Ingestão & Qualidade (Python)"]
        ETL_Engine[Engine ETL Pandas]
        Val_Pydantic[Validação Pydantic & Hashing SHA-256]
        ETL_Engine --> Val_Pydantic
    end

    subgraph DB_Layer ["3. Camada de Armazenamento & Auditoria (PostgreSQL)"]
        DB_Core[(Tabelas Transacionais: transacoes, ativos)]
        DB_Audit[(Tabela log_auditoria - JSONB)]
        DB_Logs[(Tabela log_etl)]
        DB_Views[Views Analíticas: vw_resumo_mensal]
    end

    subgraph Service_Layer ["4. Camada de Serviços Backend (FastAPI & Worker)"]
        API_Core[FastAPI REST Engine]
        Worker_Alerts[Worker de Mensageria]
    end

    subgraph Consumer_Layer ["5. Camada de Consumo & Apresentação"]
        Web_App[Dashboard Web Next.js / Tailwind]
        PBI_Dash[Power BI Reports / DAX]
        Telegram_Email[Notificações: Telegram / Email]
    end

    %% Fluxos de Conexão
    CSV --> ETL_Engine
    API_COT --> ETL_Engine
    Val_Pydantic --> DB_Core
    Val_Pydantic --> DB_Logs
    DB_Core -.->|Triggers| DB_Audit

    DB_Core --> DB_Views
    DB_Views --> API_Core
    DB_Core --> PBI_Dash

    API_Core --> Web_App
    API_Core --> Worker_Alerts
    Worker_Alerts --> Telegram_Email

2. Detalhamento dos Módulos e Responsabilidades
2.1. Engine ETL (Python)
Função: Ingestão, limpeza e transformação de extratos brutos e cotações.

Tecnologias: Python 3.12, Pandas, Pydantic, SQLAlchemy.

Mecanismos Principais:

Leitura e padronização de datas, moedas e categorias.

Geração de hash SHA-256 por registro para garantir idempotência.

Registro de métricas de execução na tabela log_etl.

2.2. Banco de Dados Relacional (PostgreSQL)
Função: Persistência transacional, garantia de integridade referencial, auditoria e agregação para leitura rápida.

Tecnologias: PostgreSQL 15+.

Mecanismos Principais:

Restrições nativas (CHECK, UNIQUE, FOREIGN KEY).

Histórico de alterações mutacionais em coluna do tipo JSONB (log_auditoria).

Views analíticas pré-agregadas (vw_resumo_mensal) para otimização de performance.

2.3. API REST Backend (FastAPI)
Função: Exposição de endpoints assíncronos de alta performance para consulta e inserção de dados.

Tecnologias: FastAPI, Uvicorn, Pydantic v2.

Mecanismos Principais:

Paginação de consultas por padrão (page, limit).

Respostas de erro padronizadas em JSON com status codes HTTP semânticos.

Validação automática de payload via schemas Pydantic.

2.4. Painel Web (Next.js) & Power BI
Função: Visualização interativa e acompanhamento executivo de dados.

Tecnologias: Next.js 14, React, Tailwind CSS, Power BI Desktop (DAX).

Mecanismos Principais:

Dashboard web responsivo consumindo a API REST em formato JSON.

Relatórios executivos em Power BI conectados ao PostgreSQL para análises temporais avançadas em DAX (acumulado mensal, rentabilidade, comparações MoM).

2.5. Worker de Alertas & Mensageria
Função: Avaliação contínua de regras de negócio e disparo de notificações sem intervenção humana.

Tecnologias: Python, Requests, Bot API do Telegram, SMTP.

Mecanismos Principais:

Verificação do estouro de teto orçamentário por categoria.

Disparo de mensagens automáticas com atualização do status em log_alertas.

3. Decisões Estratégicas de Arquitetura
Desacoplamento do ETL e da API: O pipeline ETL executa de forma independente da API REST. Isso garante que cargas pesadas de dados não travem o servidor web.

Uso de SQL Views para Métricas: Em vez de realizar cálculos complexos em memória no Python/Node.js toda vez que a API for consultada, as agregações pesadas são delegadas ao banco PostgreSQL por meio de Views otimizadas.

Auditoria Centralizada via JSONB: Qualquer alteração em tabelas críticas grava o estado anterior e posterior em formato JSON, garantindo rastreabilidade sem poluir as tabelas de domínio.


---

<ElicitationsGroup message="Como deseja dar continuidade ao desenvolvimento do repositório?">
  <Elicitation label="Gerar os arquivos da pasta 01-architecture (data-flow.md e ADRs)" query="Gere os arquivos da pasta docs/01-architecture: data-flow.md e os documentos de ADR (0001-escolha-postgresql.md e 0002-estrategia-etl-python.md)."/>
  <Elicitation label="Avançar para o código da Fase 1 (src/database/database.py e models.py)" query="Vamos para o código da Fase 1: crie a conexão do SQLAlchemy em src/database/database.py e os modelos ORM em src/database/models.py."/>
</ElicitationsGroup>