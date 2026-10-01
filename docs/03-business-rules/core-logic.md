# 📐 Regras de Negócio & Lógica Core

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Versão:** 1.2.0  
**Status:** Especificação Técnica Aprovada  

---

## 1. Segregação e Classificação dos Fluxos Financeiros

Para preservar a precisão dos KPIs de custo de vida e evitar falsos positivos no motor de alertas, as movimentações no sistema são estritamente categorizadas em três tipos:

```text
               ┌──► RECEITA       (Aumento de Caixa / Entradas de salário, dividendos)
TRANSAÇÃO ─────┼──► DESPESA       (Redução de Caixa por Custo de Vida / Consumo)
               └──► INVESTIMENTO  (Realocação de Caixa ──► Patrimônio em Custódia de Ativos)
RECEITA: Entradas financeiras. Incrementam o saldo de caixa em liquidez.DESPESA: Custo de vida e saídas operacionais. Consomem o teto orçamentário mensal da categoria e reduzem o caixa.INVESTIMENTO: Aporte ou alocação de capital em ativos (Ações, FIIs, Criptos, Renda Fixa, Stocks, REITs).Impacto no Caixa: Reduz o saldo disponível em conta corrente.Impacto no Patrimônio: Incrementa a custódia do ativo (quantidade_total e preco_medio).Impacto no Teto Orçamentário: ZERO. O valor investido é desconsiderado na verificação de violação de limites orçamentários operacionais.2. Dolarização & Conversão de Ativos Internacionais (PTAX)Para ativos negociados em moeda estrangeira (ex: Stocks e REITs cotados em USD), a consolidação patrimonial em BRL aplica a cotação oficial PTAX de Fechamento divulgada pelo Banco Central do Brasil.2.1. Fórmula de Conversão Patrimonial (USD $\rightarrow$ BRL)O valor de mercado em BRL de um ativo cotado em dólar é dado por:$$\text{Valor Mercado}_{\text{BRL}} = \text{Qtd}_{\text{total}} \times \text{Cotação}_{\text{USD}} \times \text{PTAX}_{\text{dia}}$$Onde:$\text{Cotação}_{\text{USD}}$: Último preço de fechamento registrado na tabela cotacoes_historico.$\text{PTAX}_{\text{dia}}$: Última taxa de câmbio PTAX de venda registrada na tabela taxas_cambio com data $\le$ data da cotação.3. Estratégia de Migração de Banco de Dados (Alembic)Para gerenciar a evolução do banco de dados relacional sem depender de scripts SQL executados manualmente, o projeto utiliza o Alembic integrado ao SQLAlchemy.3.1. Workflow de MigraçõesPlaintext[Ajuste em src/database/models.py] ──► [alembic revision --autogenerate] ──► [alembic upgrade head]
Modelos Declarativos: Toda alteração de estrutura (novas colunas, índices ou restrições) deve ser realizada primeiro no arquivo src/database/models.py.Geração Automática: O comando alembic revision --autogenerate -m "descricao_da_mudanca" compara o estado das classes Python com o esquema do PostgreSQL e cria o arquivo de migração versionado na pasta alembic/versions/.Aplicação Segura: O comando alembic upgrade head aplica as alterações mantendo a tabela alembic_version atualizada.4. Recálculo de Preço Médio Ponderado (Operações de Compra)O Preço Médio Ponderado ($\text{PM}$) é atualizado na moeda nativa do ativo (BRL ou USD) a cada nova inserção de compra:$$\text{PM}_{\text{novo}} = \frac{(\text{Qtd}_{\text{atual}} \times \text{PM}_{\text{atual}}) + (\text{Qtd}_{\text{comprada}} \times \text{Preço}_{\text{compra}})}{\text{Qtd}_{\text{atual}} + \text{Qtd}_{\text{comprada}}}$$Abatimento em Vendas: Mantém o $\text{PM}_{\text{atual}}$ inalterado e reduz a quantidade_total. Se a quantidade zerar, o $\text{PM}$ é redefinido para 0.00.