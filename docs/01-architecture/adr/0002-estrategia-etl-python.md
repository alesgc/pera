# 📝 ADR 0002: Estratégia de ETL em Python com Deduplicação via SHA-256

* **Status:** Aprovado
* **Data:** 2026-10-01
* **Decisores:** Time de Arquitetura e Engenharia de Dados

---

## 1. Contexto e Problema

O pipeline de ingestão de dados recebe extratos bancários em formatos legados (`.csv` e `.xlsx`) frequentemente exportados manualmente pelos usuários. Esse cenário traz dois grandes desafios:

1. **Inconsistência de Formatos:** Variação de separadores de colunas, nomes de cabeçalhos, formatos de data (`DD/MM/YYYY` vs `YYYY-MM-DD`) e números com vírgula/ponto.
2. **Reimportação Acidental:** Alto risco de o mesmo arquivo ou extratos com períodos sobrepostos serem importados múltiplas vezes, gerando duplicidade nos registros de saldo e receitas/despesas.

---

## 2. Opções Consideradas

1. **Ferramentas de Orquestração / ETL (Apache Airflow / Meltano):** Muito robustas para pipelines corporativos massivos, porém adicionam complexidade excessiva de infraestrutura e curva de aprendizado para um projeto simplificado e ágil.
2. **Tratamento Direto via SQL (`ON CONFLICT DO NOTHING` com chaves simples):** Requer dependência excessiva de chaves primárias compostas no banco e dificulta o tratamento de erros de formato antes do `INSERT`.
3. **Engine Customizada em Python (Pandas + Pydantic + SHA-256):** Pipeline em código Python utilizando **Pandas** para manipulação matricial, **Pydantic** para validação de esquemas e cálculo de **Hash SHA-256** determinístico por registro/arquivo.

---

## 3. Decisão Escolhida

Decidiu-se construir uma **Engine ETL customizada em Python (3.12+)** integrando **Pandas**, **Pydantic** e **Hashing SHA-256**.

### Estratégia de Implementação:
1. **Deduplicação de Arquivos:** Ao iniciar o processamento, calcula-se o hash SHA-256 do arquivo completo e verifica-se a existência prévia na tabela `log_etl`. Se já foi processado com sucesso, a execução é interrompida.
2. **Deduplicação de Linhas:** Para cada registro extraído, gera-se um hash único baseado na combinação dos campos fundamentais:
   $$\text{Hash} = \text{SHA256}(\text{data\_transacao} + \text{valor} + \text{descricao} + \text{categoria\_id})$$
   O valor resultante é gravado no campo `hash_transacao` (definido como `UNIQUE` no PostgreSQL).
3. **Validação de Tipos com Pydantic:** Todas as linhas passam por um schema Pydantic para validação estrita de data, limites numéricos e remoção de espaços/caracteres inválidos.

---

## 4. Consequências

### Positivas:
* **Garantia de 100% de Idempotência:** Repetir a ingestão do mesmo arquivo produz zero duplicidades no banco de dados.
* **Falha Parcial Controlada:** Linhas inválidas são enviadas para quarentena sem abortar os registros válidos do mesmo lote.
* **Arquitetura Leve e Portável:** Executável via simples scripts CLI (`python -m src.etl.pipeline`) sem dependência de serviços externos complexos como Airflow.

### Negativas / Custos:
* Ligeiro *overhead* computacional para calcular o hash SHA-256 de milhares de linhas durante a carga.
* A alteração retroativa na lógica de geração de hashes pode invalidar a verificação de duplicatas antigas.