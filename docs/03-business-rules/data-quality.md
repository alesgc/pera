# 🛡️ Regras de Validação & Qualidade de Dados (Data Quality)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Versão:** 1.0.0  
**Status:** Especificação Técnica Aprovada  

---

## 1. Princípios de Data Quality do Ecossistema

Para manter a confiabilidade das métricas exibidas nos dashboards e APIs, todas as camadas da aplicação seguem cinco pilares fundamentais:

1. **Completude:** Campos essenciais para cálculo e agrupamento (`data`, `valor`, `categoria`) não podem ser nulos.
2. **Exatidão:** Valores monetários não podem ser negativos nem possuir precisão menor do que duas casas decimais.
3. **Consistência:** Um ativo não pode ser negociado sem estar devidamente cadastrado na tabela `ativos`.
4. **Unicidade:** O mesmo evento financeiro não pode coexistir sob hashes idênticos.
5. **Atualidade:** Transações financeiras passadas não podem possuir datas no futuro em relação ao momento de ingestão.

---

## 2. Matriz de Validação de Campos por Entidade

| Entidade | Campo | Tipo / Formato | Regra de Validação Técnica | Tratamento em Caso de Falha |
| :--- | :--- | :--- | :--- | :--- |
| `transacoes` | `valor` | `NUMERIC(12,2)` | Estritamente positivo ($> 0.00$). | Rejeição do registro com erro `HTTP 422` ou envio para quarentena. |
| `transacoes` | `data_transacao` | `DATE` | Menor ou igual à data atual ($\le \text{CURRENT\_DATE}$). | Rejeição (impede lançamentos futuros de despesas passadas). |
| `transacoes` | `tipo` | `VARCHAR(10)` | Restrito aos valores `'RECEITA'` ou `'DESPESA'`. | Erro de validação de Schema Pydantic. |
| `transacoes` | `hash_transacao` | `VARCHAR(64)` | String hexa única de 64 caracteres. | Ignora inserção se duplicado (`ON CONFLICT DO NOTHING`). |
| `ativos` | `ticker` | `VARCHAR(10)` | Regex: `^[A-Z0-9]{4,10}$` (Caixa alta e sem caracteres especiais). | Sanitização automática via `.strip().upper()`. |
| `ativos` | `quantidade_total`| `NUMERIC(15,6)`| Maior ou igual a zero ($\ge 0.000000$). | Impede venda com saldo insuficiente (`HTTP 400`). |
| `categorias` | `orcamento_limite`| `NUMERIC(12,2)`| Maior ou igual a zero ($\ge 0.00$). | Rejeição caso seja informado valor negativo. |

---

## 3. Sanitização e Transformação de Dados de Entrada

No pipeline ETL, os dados brutos de extratos passam pelas seguintes transformações de limpeza antes da validação de schema:

```text
[Dado Bruto] ──► [Limpeza de Strings] ──► [Parsing de Datas/Moedas] ──► [Validação Pydantic]
3.1. Tratamento de Formato Monetário
Entradas como "R$ 1.250,50", "1250.50" ou " 1250,50 " são padronizadas via expressão regular para o tipo de dado float Python e validadas no Pydantic como Decimal com 2 casas.

3.2. Normalização de Datas
Múltiplos formatos de entrada (DD/MM/YYYY, YYYY-MM-DD, DD-MM-YYYY) são convertidos estritamente para o padrão ISO-8601 (YYYY-MM-DD).

4. Estratégia de Quarentena e Ingestão Parcial
Durante o processamento de um lote de arquivo de extrato (ex: CSV de 500 linhas):

Validação Linha a Linha: Se a linha 42 possuir um valor inválido (ex: valor = -15.00), o pipeline não aborda o processamento completo das outras 499 linhas.

Arquivo de Quarentena: A linha inválida é copiada para o diretório data/quarantine/erros_YYYYMMDD_HHMMSS.csv acompanhada do motivo da falha.

Métricas no Banco: A execução grava os contadores finais no log do pipeline:

log_etl.registros_inseridos = 499

log_etl.registros_rejeitados = 1

log_etl.status = 'SUCESSO' (com alertas de linhas em quarentena)


---

<ElicitationsGroup message="Como deseja prosseguir para os próximos arquivos da documentação?">
  <Elicitation label="Gerar arquivos da pasta 04-etl-pipelines (source-to-target.md e error-handling.md)" query="Gere os arquivos da pasta docs/04-etl-pipelines: source-to-target.md (mapeamento De-Para) e error-handling.md (estratégia de quarentena e idempotência)."/>
  <Elicitation label="Ir direto para a implementação em código da Fase 1 (src/database/)" query="Avançar para a implementação da Fase 1: crie o arquivo src/database/database.py para conexão SQLAlchemy e src/database/models.py com os modelos ORM."/>
</ElicitationsGroup>