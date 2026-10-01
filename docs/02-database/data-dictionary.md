# 📖 Dicionário de Dados

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**SGBD:** PostgreSQL 15+  
**Versão do Esquema:** 1.2.0  

---

## 1. Tabela: `categorias`
Armazena a classificação das transações financeiras e os limites orçamentários mensais definidos pelo usuário.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único da categoria. |
| `nome` | `VARCHAR(50)` | Não | `UK` | Único | Nome da categoria (ex: Alimentação, Moradia, Salário). |
| `tipo` | `VARCHAR(15)` | Não | - | `CHECK (tipo IN ('RECEITA', 'DESPESA', 'INVESTIMENTO'))` | Classificação do fluxo de caixa. |
| `orcamento_mensal_limite` | `NUMERIC(12,2)` | Sim | - | `0.00` (`CHECK >= 0`) | Teto limite de gasto mensal configurado para alertas. |
| `criado_em` | `TIMESTAMP` | Sim | - | `CURRENT_TIMESTAMP` | Data e hora de criação do registro. |

---

## 2. Tabela: `transacoes`
Tabela transacional core onde são registradas todas as entradas, saídas financeiras e aportes em investimentos do sistema.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único da transação. |
| `data_transacao` | `DATE` | Não | - | `CHECK (<= CURRENT_DATE)` | Data em que a movimentação ocorreu. |
| `descricao` | `VARCHAR(150)`| Não | - | - | Descrição textual (ex: Compra Mercado Livre). |
| `valor` | `NUMERIC(12,2)`| Não | - | `CHECK (valor > 0)` | Valor monetário absoluto da movimentação. |
| `tipo` | `VARCHAR(15)` | Não | - | `CHECK (tipo IN ('RECEITA', 'DESPESA', 'INVESTIMENTO'))` | Tipo da movimentação. |
| `categoria_id` | `INT` | Não | `FK` | `REFERENCES categorias(id)` | Vínculo com a categoria da transação. |
| `meio_pagamento` | `VARCHAR(30)` | Sim | - | `'OUTROS'` | Forma de pagamento (ex: Pix, Cartão Crédito, Boleto). |
| `hash_transacao` | `VARCHAR(64)` | Sim | `UK` | Único (SHA-256) | Hash determinístico dos campos para deduplicação no ETL. |
| `criado_em` | `TIMESTAMP` | Sim | - | `CURRENT_TIMESTAMP` | Timestamp do momento da inserção. |
| `atualizado_em` | `TIMESTAMP` | Sim | - | `CURRENT_TIMESTAMP` | Timestamp do momento da última modificação. |

---

## 3. Tabela: `ativos`
Mapeia a carteira de investimentos nacionais e internacionais, mantendo o saldo de quantidade e preço médio.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único do ativo. |
| `ticker` | `VARCHAR(10)` | Não | `UK` | Único | Código do ativo no mercado (ex: PETR4, AAPL, BTC). |
| `nome` | `VARCHAR(100)`| Não | - | - | Nome completo da empresa/ativo. |
| `tipo_ativo` | `VARCHAR(30)` | Não | - | `CHECK (tipo_ativo IN ('ACAO', 'FII', 'CRIPTO', 'RENDA_FIXA', 'STOCK', 'REIT'))` | Classe do investimento. |
| `moeda_cotacao` | `VARCHAR(3)` | Não | - | `'BRL'` (`CHECK IN ('BRL', 'USD')`) | Moeda nativa de negociação do ativo. |
| `quantidade_total`| `NUMERIC(15,6)`| Sim | - | `0.00` (`CHECK >= 0`) | Quantidade total acumulada em custódia. |
| `preco_medio` | `NUMERIC(12,2)`| Sim | - | `0.00` (`CHECK >= 0`) | Preço médio de aquisição na moeda nativa. |

---

## 4. Tabela: `cotacoes_historico`
Histórico temporal de cotações na moeda original do ativo para avaliação patrimonial.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador do registro de cotação. |
| `ativo_id` | `INT` | Não | `FK` | `REFERENCES ativos(id)` | Vínculo com o ativo correspondente. |
| `data_cotacao` | `DATE` | Não | - | - | Data de fechamento do mercado. |
| `preco_fechamento`| `NUMERIC(12,2)`| Não | - | `CHECK (preco_fechamento > 0)` | Preço de encerramento do ativo na moeda nativa. |
| *Constraint UK* | - | - | `UK` | `UNIQUE(ativo_id, data_cotacao)` | Impede duplicidade de cotação para o mesmo ativo no dia. |

---

## 5. Tabela: `taxas_cambio`
Histórico de taxas cambiais oficiais (PTAX do Banco Central) para conversão USD $\rightarrow$ BRL.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único da cotação de câmbio. |
| `data_referencia` | `DATE` | Não | `UK` | `CHECK (<= CURRENT_DATE)` | Data oficial da cotação PTAX. |
| `moeda_origem` | `VARCHAR(3)` | Não | `UK` | `'USD'` | Moeda base de conversão. |
| `moeda_destino` | `VARCHAR(3)` | Não | `UK` | `'BRL'` | Moeda de destino. |
| `taxa_ptax_fechamento`| `NUMERIC(10,4)`| Não | - | `CHECK (> 0)` | Taxa oficial PTAX de venda divulgada pelo BACEN. |

---

## 6. Tabela: `regras_alertas`
Configurações de regras para gatilhos de mensageria e notificações.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único da regra. |
| `nome` | `VARCHAR(100)`| Não | - | - | Nome amigável da regra. |
| `tipo_alerta` | `VARCHAR(30)` | Não | - | `CHECK (tipo_alerta IN ('TETO_CATEGORIA', ...))` | Tipo de regra monitorada. |
| `categoria_id` | `INT` | Sim | `FK` | `REFERENCES categorias(id)` | Categoria associada. |
| `valor_limite` | `NUMERIC(12,2)`| Não | - | `CHECK (valor_limite >= 0)` | Limite gatilho para acionamento do alerta. |
| `canal` | `VARCHAR(20)` | Não | - | `CHECK (canal IN ('EMAIL', 'TELEGRAM'))` | Canal de destino da notificação. |
| `ativo` | `BOOLEAN` | Sim | - | `TRUE` | Status de habilitação da regra. |

---

## 7. Tabela: `log_alertas`
Rastreio histórico de mensagens e notificações disparadas pelo worker.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador único do log. |
| `regra_id` | `INT` | Sim | `FK` | `REFERENCES regras_alertas(id)` | Regra de origem que gerou o disparo. |
| `destinatario` | `VARCHAR(100)`| Não | - | - | Endereço de e-mail ou Chat ID do Telegram. |
| `mensagem` | `TEXT` | Não | - | - | Conteúdo completo da mensagem enviada. |
| `status_envio` | `VARCHAR(20)` | Não | - | `CHECK (status_envio IN ('PENDENTE', 'SUCESSO', 'FALHA'))` | Estado da entrega da mensagem. |
| `enviado_em` | `TIMESTAMP` | Sim | - | `CURRENT_TIMESTAMP` | Data/hora da tentativa de envio. |

---

## 8. Tabela: `log_etl`
Métricas de saúde e governança dos pipelines de ingestão de dados.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador da execução do pipeline. |
| `nome_pipeline` | `VARCHAR(100)`| Não | - | - | Nome da rotina (ex: `pipeline_transacoes`). |
| `inicio_execucao`| `TIMESTAMP` | Não | - | - | Timestamp de início do processamento. |
| `fim_execucao` | `TIMESTAMP` | Sim | - | - | Timestamp de conclusão do processamento. |
| `status` | `VARCHAR(20)` | Não | - | `CHECK (status IN ('EM_ANDAMENTO', 'SUCESSO', 'ERRO'))` | Estado final do pipeline. |
| `registros_inseridos`| `INT` | Sim | - | `0` (`CHECK >= 0`) | Quantidade de linhas gravadas com sucesso no banco. |
| `registros_rejeitados`| `INT` | Sim | - | `0` (`CHECK >= 0`) | Quantidade de linhas enviadas para quarentena. |
| `mensagem_erro` | `TEXT` | Sim | - | - | Stacktrace ou mensagem de falha crítica. |
| `nome_arquivo` | `VARCHAR(255)`| Sim | - | - | Nome original do arquivo importado. |
| `hash_arquivo` | `VARCHAR(64)` | Sim | - | Hash SHA-256 | Hash do arquivo fonte completo para evitar recargas. |

---

## 9. Tabela: `log_auditoria`
Trilhas de auditoria mutacional gravando payloads inteiros do estado anterior e posterior das tabelas.

| Coluna | Tipo de Dado | Nulo? | Chave | Padrão / Restrição | Descrição |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `id` | `SERIAL` | Não | `PK` | Autoincremento | Identificador do log de auditoria. |
| `nome_tabela` | `VARCHAR(50)` | Não | - | - | Nome da tabela auditada (ex: `transacoes`). |
| `registro_id` | `INT` | Não | `PK` | - | ID do registro afetado na tabela de origem. |
| `operacao` | `VARCHAR(10)` | Não | - | `CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))` | Tipo da mutação executada. |
| `dados_antigos` | `JSONB` | Sim | - | - | Payload completo antes da alteração (em JSON). |
| `dados_novos` | `JSONB` | Sim | - | - | Payload completo após a alteração (em JSON). |
| `executado_em` | `TIMESTAMP` | Sim | - | `CURRENT_TIMESTAMP` | Data e hora do acionamento da trigger. |

---

## 10. Views Analíticas

### 10.1. View: `vw_resumo_mensal`
Visão analítica pré-agregada por mês e categoria para monitoramento do teto orçamentário.

| Coluna | Tipo de Dado | Descrição |
| :--- | :--- | :--- |
| `mes_ano` | `TEXT` | Identificador do mês/ano no formato `YYYY-MM`. |
| `tipo` | `VARCHAR(15)` | Classificação (`RECEITA`, `DESPESA`, `INVESTIMENTO`). |
| `categoria` | `VARCHAR(50)` | Nome da categoria. |
| `total_gasto` | `NUMERIC` | Soma acumulada dos valores no período. |
| `orcamento_mensal_limite`| `NUMERIC` | Teto orçamentário mensal da categoria. |
| `orcamento_excedido` | `BOOLEAN` | Flag (`TRUE`/`FALSE`) calculada apenas sobre `DESPESA`. |

### 10.2. View: `vw_posicao_ativos_consolidada`
Visão analítica da carteira de investimentos com conversão cambial automática em BRL via cotação PTAX.

| Coluna | Tipo de Dado | Descrição |
| :--- | :--- | :--- |
| `ativo_id` | `INT` | Identificador único do ativo. |
| `ticker` | `VARCHAR(10)` | Ticker do ativo. |
| `nome` | `VARCHAR(100)`| Nome amigável do ativo. |
| `tipo_ativo` | `VARCHAR(30)` | Classe do ativo. |
| `moeda_cotacao` | `VARCHAR(3)` | Moeda nativa (`BRL` ou `USD`). |
| `quantidade_total`| `NUMERIC` | Quantidade total em custódia. |
| `preco_medio_original`| `NUMERIC` | Preço médio de aquisição na moeda nativa. |
| `preco_atual_original`| `NUMERIC` | Última cotação de fechamento na moeda nativa. |
| `taxa_ptax_aplicada`  | `NUMERIC` | Taxa PTAX utilizada para conversão (1.0000 para BRL). |
| `preco_atual_brl`     | `NUMERIC` | Preço unitário convertido para BRL. |
| `valor_total_mercado_brl`| `NUMERIC` | Valoração total do ativo na carteira em BRL. |