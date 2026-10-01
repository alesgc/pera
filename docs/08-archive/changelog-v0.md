```markdown
# 📜 Histórico de Evolução Arquitetural (v0.x - Legado)

> ⚠️ **DOCUMENTO ARQUIVADO / OBSOLETO**  
> **Status:** Deprecated (Substituído pela especificação técnica v1.0.0)  
> **Data de Arquivamento:** 2026-09-15  
> **Motivo:** Consolidação da arquitetura profissional End-to-End (Python, PostgreSQL, FastAPI, Next.js, Power BI).

---

## 1. Contexto das Versões Iniciais (v0.1 a v0.9)

Antes da estruturação da arquitetura em microsserviços e pipelines de dados containerizados em Docker, a gestão financeira operava com o seguinte fluxo legado:

* **v0.1 (Fase de Planilhas Locais):** Inserção manual de transações em arquivos Excel descentralizados sem validação de tipos ou controle de duplicidade.
* **v0.2 (Automação de Scripts Isolados):** Scripts em Python (*Panda scripts*) que rodavam localmente para consolidar extratos CSV simples, salvando o resultado em arquivos SQLite sem triggers de auditoria ou hash SHA-256.
* **v0.5 (API Monolítica Inicial):** Primeiros protótipos de rotas com endpoints síncronos gravando diretamente no SQLite sem camada de staging, sem testes de idempotência e sem envio automatizado de alertas por mensageria.

---

## 2. Decisões Técnicas Descontinuadas

| Decisão Descontinuada | Motivo da Descontinuação | Nova Solução Adotada (v1.0.0) |
| :--- | :--- | :--- |
| Persistência em SQLite | Falta de suporte a concorrência em gravações pesadas e limitações para consultas analíticas em JSONB. | PostgreSQL 15+ containerizado via Docker Compose. |
| Ingestão sem Hashing | Reimportação repetida do mesmo arquivo gerava duplicidade de saldos nos relatórios. | Deduplicação por Hash SHA-256 no arquivo e por registro (`hash_transacao`). |
| Processamento Síncrono no Backend | Upload de extratos grandes travava a execução das requisições web. | Separação estrita entre Engine ETL Batch e API REST (FastAPI). |