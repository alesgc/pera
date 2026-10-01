# 🔀 Mapeamento de Ingestão (Source-to-Target)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Engine ETL (Python/Pandas)  
**Versão:** 1.0.0  

---

## 1. Visão Geral das Fontes de Dados

O pipeline de dados ingere dados brutos de duas origens principais:

1. **Extratos Bancários Locais (Arquivos Flutuantes):** Arquivos `.csv` e `.xlsx` exportados de instituições financeiras contendo o histórico de movimentações financeiras.
2. **APIs de Cotação de Mercado (REST JSON):** Serviços externos de mercado financeiro (ex: Yahoo Finance / BRAPI) para captura de preços de fechamento históricos dos ativos em carteira.

---

## 2. De-Para: Extratos de Transações (CSV $\rightarrow$ Table `transacoes`)

| Campo Fonte (CSV/Excel) | Tipo Fonte | Campo Alvo (`transacoes`) | Tipo Alvo (PostgreSQL) | Regra de Transformação / Sanitize | Fallback / Padrão |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `Data`, `Dt_Transacao`, `Date` | String | `data_transacao` | `DATE` | Conversão de formatos (`DD/MM/YYYY`, `DD-MM-YYYY`) para ISO 8601 (`YYYY-MM-DD`). | **Rejeita** se data for inválida ou futura. |
| `Descricao`, `Historico`, `Memo` | String | `descricao` | `VARCHAR(150)` | Remoção de caracteres especiais, espaços duplos e trim: `.strip()`. | **Rejeita** se vazio. |
| `Valor`, `Monto`, `Amount` | String / Float | `valor` | `NUMERIC(12,2)` | Remove `R$`, converte `,` para `.` e extrai o valor absoluto ($\vert{}x\vert{}$). | **Rejeita** se $\le 0.00$. |
| `Tipo`, `Entrada/Saida` | String | `tipo` | `VARCHAR(10)` | Mapeia termos (`'CREDITO'`/`'ENTRADA'` $\rightarrow$ `'RECEITA'`; `'DEBITO'`/`'SAIDA'` $\rightarrow$ `'DESPESA'`). | Infere pelo sinal do valor caso o campo não exista. |
| `Categoria` | String | `categoria_id` | `INT` | Busca o `id` exato na tabela `categorias`. Se não existir, associa à categoria padrão. | Categoria `'Outros'` (`id` padrão). |
| `Meio_Pagamento` | String | `meio_pagamento` | `VARCHAR(30)` | Padroniza para caixa alta (`'PIX'`, `'CARTAO_CREDITO'`, `'BOLETO'`, `'TRANSFERENCIA'`). | `'OUTROS'` |
| *Derivado em Runtime* | - | `hash_transacao` | `VARCHAR(64)` | Algoritmo SHA-256 da concatenação: `data + valor + descricao_limpa + categoria_id`. | **Rejeita/Ignora** se hash for duplicado no banco. |

---

## 3. De-Para: APIs de Cotação de Ativos (JSON $\rightarrow$ Table `cotacoes_historico`)

| Campo Payload JSON (API) | Tipo Payload | Campo Alvo (`cotacoes_historico`) | Tipo Alvo | Regra de Transformação |
| :--- | :--- | :--- | :--- | :--- |
| `symbol`, `ticker` | String | `ativo_id` | `INT` | Busca o `id` correspondente na tabela `ativos` via `ticker.upper()`. |
| `date`, `regularMarketTime` | String / Unix | `data_cotacao` | `DATE` | Converte Timestamp Unix ou String UTC para o formato `YYYY-MM-DD`. |
| `close`, `regularMarketPrice` | Float | `preco_fechamento` | `NUMERIC(12,2)` | Valida se preço $> 0.00$ e arredonda para 2 casas decimais. |

---

## 4. Pipeline de Enriquecimento e Normalização

Antes de persisitir os dados na tabela de destino, o dataframe Pandas executa as seguintes etapas sequenciais:

```text
1. Normalização de Cabeçalho ──► Lowercase, remoção de acentos e espaços por '_'.
2. Mapeamento de Colunas   ──► Renomeia colunas conhecidas para a nomenclatura oficial.
3. Tratamento Numérico     ──► Converte strings monetárias em tipos Decimais/Float.
4. Deduplicação em Memória ──► Remove linhas idênticas dentro do próprio lote (drop_duplicates).
5. Validação com Pydantic  ──► Garante que cada linha obedece às regras do schema DTO.