# 📝 ADR 0001: Escolha do PostgreSQL como Banco de Dados Relacional Principal

* **Status:** Aprovado
* **Data:** 2026-10-01
* **Decisores:** Time de Arquitetura e Engenharia de Dados

---

## 1. Contexto e Problema

Para a construção do **Ecosystem Financeiro & Analítico**, era necessário selecionar um Sistema Gerenciador de Banco de Dados (SGBD) central que atendesse a requisitos operacionais e analíticos exigentes:

1. Garantia estrita de **transacionalidade ACID** no registro de movimentações financeiras.
2. Capacidade de armazenar e consultar históricos mutacionais e logs de auditoria em **estruturas JSON semiestruturadas** sem perda de desempenho.
3. Suporte a **regras de integridade** nativas no banco (`CHECK constraints`, `FOREIGN KEYs`, `UNIQUE constraints`) para impedir dados inconsistentes na fonte.
4. Alta compatibilidade com ferramentas de **Business Intelligence (Power BI)** e frameworks ORM em Python (**SQLAlchemy**).

---

## 2. Opções Consideradas

1. **SQLite:** Excelente para aplicações desktop/locais e fácil setup, mas possui limitações em concorrência de escrita, falta de suporte avançado a JSONB e restrições no processamento de consultas analíticas pesadas.
2. **MySQL / MariaDB:** Bastante popular e de alta performance em leitura, porém apresenta suporte a tipos JSON mais limitado e menor eficiência em consultas analíticas complexas comparado ao PostgreSQL.
3. **MongoDB (NoSQL):** Ótimo para documentos dinâmicos e escalabilidade horizontal, mas peca no suporte nativo a restrições relacionais rígidas e agregações financeiras complexas com `JOINs`.
4. **PostgreSQL (RDBMS):** Banco relacional avançado, suporte nativo de alta performance a `JSONB`, suporte robusto a *Views*, Triggers, CTEs (*Common Table Expressions*) e restrições de tabela.

---

## 3. Decisão Escolhida

Decidiu-se adotar o **PostgreSQL (versão 15+)** como o banco de dados principal do projeto.

### Fatores Decisivos:
* **Suporte Nativo a JSONB:** Permite criar a tabela `log_auditoria` gravando os campos `dados_antigos` e `dados_novos` em JSON mantendo a capacidade de indexação e busca em subcampos.
* **Integridade Relacional Declarativa:** Utilização de cláusulas `CHECK (valor > 0)` e `CHECK (orcamento_mensal_limite >= 0)` diretamente no DDL do banco como segunda camada de defesa contra erros da aplicação.
* **Views e Agregações Analíticas:** A criação da `vw_resumo_mensal` simplifica e acelera as consultas consumidas pela API FastAPI e pelo Power BI.
* **Ecossistema:** Integração transparente com `psycopg2`, `SQLAlchemy`, `Alembic` e conectores nativos do Power BI Desktop.

---

## 4. Consequências

### Positivas:
* Governança e auditoria completa de alterações em tempo real via JSONB.
* Garantia de consistência dos dados financeiros diretamente na camada de persistência.
* Desempenho consistente em consultas analíticas agregadas via SQL nativo.

### Negativas / Custos:
* Requer o provisionamento de um serviço de banco dedicado (via container Docker no ambiente de desenvolvimento).
* Consumo de recursos de memória/CPU superior ao de bancos embutidos como SQLite.