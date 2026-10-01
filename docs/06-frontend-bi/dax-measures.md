# 📊 Catálogo de Medidas DAX (Power BI)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Business Intelligence (Power BI Desktop)  
**Versão:** 1.0.0  

---

## 1. Visão Geral das Medidas DAX

Para garantir alta performance e evitar recálculos desnecessários no modelo do Power BI, todas as métricas analíticas são calculadas utilizando **medidas explícitas em DAX** sobre as *Views* otimizadas do PostgreSQL (`vw_resumo_mensal`) e tabelas relacionais.

---

## 2. Medidas de Fluxo de Caixa (Receitas e Despesas)

### 2.1. Total de Receitas
Calcula a soma de todas as entradas financeiras no período selecionado.

```dax
[Total Receitas] = 
CALCULATE(
    SUM(transacoes[valor]),
    transacoes[tipo] = "RECEITA"
)
2.2. Total de Despesas
Calcula o somatório de saídas e despesas registradas.

Snippet de código
[Total Despesas] = 
CALCULATE(
    SUM(transacoes[valor]),
    transacoes[tipo] = "DESPESA"
)
2.3. Saldo Líquido Operacional
Diferença absoluta entre receitas e despesas.

Snippet de código
[Saldo Liquido] = [Total Receitas] - [Total Despesas]
2.4. Taxa de Comprometimento (Expense Rate %)
Mede a proporção da receita acumulada que foi comprometida com despesas no mês.

Snippet de código
[Taxa Comprometimento %] = 
DIVIDE(
    [Total Despesas],
    [Total Receitas],
    0
)
3. Análise Temporal & Comparação Mês a Mês (MoM)
3.1. Despesas no Mês Anterior (MoM)
Retorna o total de despesas do mês civil imediatamente anterior para fins de comparação.

Snippet de código
[Despesas Mes Anterior] = 
CALCULATE(
    [Total Despesas],
    DATEADD(calendario[Data], -1, MONTH)
)
3.2. Variação Percentual de Despesas (MoM %)
Mede o crescimento ou redução percentual dos gastos em relação ao mês anterior.

Snippet de código
[Variacao Despesas MoM %] = 
VAR DespesaAtual = [Total Despesas]
VAR DespesaAnterior = [Despesas Mes Anterior]
RETURN
DIVIDE(
    DespesaAtual - DespesaAnterior,
    DespesaAnterior,
    0
)
3.3. Despesas Acumuladas no Ano (YTD - Year to Date)
Soma acumulada de gastos desde o primeiro dia do ano corrente até a data selecionada.

Snippet de código
[Despesas YTD] = 
TOTALYTD(
    [Total Despesas],
    calendario[Data]
)
4. Gestão Orçamentária & Teto por Categoria
4.1. Teto Orçamentário Total
Soma dos limites mensais configurados para as categorias ativas.

Snippet de código
[Orcamento Limite Total] = 
SUM(vw_resumo_mensal[orcamento_mensal_limite])
4.2. Desvio do Orçamento (R$)
Mede a diferença entre o gasto real executado e o limite estipulado.

Snippet de código
[Desvio Orcamento] = [Total Despesas] - [Orcamento Limite Total]
4.3. Status de Estouro Orçamentário (KPI Indicator)
Retorna um indicador numérico para formatação condicional de cores nos gráficos e cartões:

1: Dentro do limite (Verde)

2: Próximo do limite (≥90% e ≤100%) (Amarelo)

3: Estourou o teto (>100%) (Vermelho)

Snippet de código
[Status Orcamento KPI] = 
VAR Executado = [Total Despesas]
VAR Limite = [Orcamento Limite Total]
RETURN
IF(
    Limite == 0,
    1,
    SWITCH(
        TRUE(),
        Executado > Limite, 3,
        Executado >= (Limite * 0.90), 2,
        1
    )
)
5. Avaliação da Carteira de Investimentos
5.1. Total Investido a Mercado
Soma da valorização atualizada de todos os ativos da carteira com base no preço de fechamento mais recente.

Snippet de código
[Patrimonio Investido Mercado] = 
SUMX(
    ativos,
    ativos[quantidade_total] * RELATED(cotacoes_historico[preco_fechamento])
)
5.2. Lucro/Prejuízo Não Realizado (R$)
Calcula o ganho ou perda de capital não realizado sobre o preço médio de aquisição.

Snippet de código
[Resultado Nao Realizado R$] = 
SUMX(
    ativos,
    (RELATED(cotacoes_historico[preco_fechamento]) - ativos[preco_medio]) * ativos[quantidade_total]
)