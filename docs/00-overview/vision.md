# 🎯 Visão do Produto & Escopo

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Versão:** 1.0.0  
**Status:** Especificação Técnica Aprovada  

---

## 1. Proposta de Valor

O **Ecosystem Financeiro & Analítico** é uma plataforma integrada desenvolvida para centralizar, automatizar e analisar a vida financeira pessoal e de investimentos. A solução elimina o trabalho manual de consolidação de extratos e cotações, aplicando processos rigorosos de engenharia de dados (ETL), auditoria relacional, APIs de alta disponibilidade e interfaces analíticas visuais em tempo real.

---

## 2. Público-Alvo e Perfil de Uso

* **Investidores e Gestores Pessoais:** Pessoas que possuem movimentações financeiras em múltiplas instituições (bancos, corretoras, criptoatividades) e necessitam de uma visão consolidada do patrimônio líquido.
* **Engenheiros e Analistas de Dados:** Desenvolvedores e recrutadores interessados em avaliar uma arquitetura *end-to-end* completa com validação rigorosa, idempotência de ETL, auditoria em banco de dados relacional e consumo via API/BI.

---

## 3. Dores Resolvidas

1. **Descentralização de Extratos:** Eliminação da necessidade de conferir manualmente planilhas ou aplicativos isolados de diferentes bancos.
2. **Erros no Cálculo do Preço Médio:** Cálculo automatizado do Preço Médio Ponderado para ativos de renda variável/cripto sem falhas humanas.
3. **Inconsistência de Dados Duplicados:** Rejeição automática de reimportações acidentais de arquivos de extrato por meio de *hashing* SHA-256.
4. **Falta de Alertas em Tempo Real:** Monitoramento ativo que notifica o usuário antes que o orçamento estipulado para uma categoria seja ultrapassado.

---

## 4. Requisitos Funcionais (RF)

| ID | Requisito Funcional | Descrição Técnica |
| :--- | :--- | :--- |
| **RF-01** | Ingestão de Extratos | O sistema deve ler e processar arquivos CSV/Excel contendo transações financeiras. |
| **RF-02** | Deduplicação de Registros | O pipeline deve calcular o hash de cada transação e ignorar entradas duplicadas. |
| **RF-03** | Preço Médio de Ativos | Recalcular automaticamente o Preço Médio Ponderado a cada compra de ativo. |
| **RF-04** | Categorização & Teto | Permitir vincular limites de gastos mensais por categoria de despesa. |
| **RF-05** | API de Métricas | Expor endpoints REST com paginação e suporte a agregações de saldo e patrimônio. |
| **RF-06** | Alertas Automatizados | Enviar mensagens via Email/Telegram quando limites orçamentários forem violados. |
| **RF-07** | Dashboard Interativo | Exibir visões analíticas em web (Next.js) e relatórios executivos em Power BI. |

---

## 5. Requisitos Não Funcionais (RNF)

| ID | Requisito Não Funcional | Meta / Parâmetro Técnico |
| :--- | :--- | :--- |
| **RNF-01** | Idempotência de Ingestão | Cargas repetidas do mesmo arquivo fonte devem produzir zero duplicidades no banco. |
| **RNF-02** | Desempenho de Leitura | Resposta de consultas analíticas da API em tempo inferior a 100ms. |
| **RNF-03** | Auditabilidade | Histórico inalterável de todas as mutações (`INSERT`/`UPDATE`/`DELETE`) gravado em JSONB. |
| **RNF-04** | Validação de Dados | 100% dos dados de entrada validados via Pydantic/Schemas antes da gravação em banco. |
| **RNF-05** | Portabilidade | Ambiente containerizado via Docker Compose reproduzível em Linux, macOS e Windows. |