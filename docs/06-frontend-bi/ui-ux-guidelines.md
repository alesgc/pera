# 🎨 Diretrizes de UI/UX & Paleta Semântica

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Aplicações:** Painel Web Next.js / Relatórios Power BI  
**Versão:** 1.0.0  

---

## 1. Princípios de Design Visual

A camada de apresentação (Web e Power BI) foi projetada com base nos princípios de **Clareza Numérica, Baixa Carga Cognitiva e Semântica Visual Estrita**. O objetivo é permitir que o usuário avalie a saúde de suas finanças em menos de 5 segundos ao abrir a tela.

---

## 2. Paleta Semântica de Cores

As cores no sistema possuem significado estrito e padronizado em todas as telas, evitando ambiguidades na interpretação dos números.

```text
[VERDE]     ──► Entradas, Receitas, Rendimentos Positivos e Dentro do Orçamento.
[VERMELHO]  ──► Saídas, Despesas, Prejuízos de Ativos e Estouro do Teto Orçamentário.
[AMARELO]   ──► Alerta de Atenção (Gasto entre 90% e 100% do teto).
[GRAFITE]   ──► Métricas Neutras, Patrimônio Consolidado e Títulos de Cartões.
2.1. Tabela de Códigos Hexadecimais (HEX)SignificadoCorCódigo HEXExemplo de AplicaçãoReceita / PositivoEmerald Green#10B981Cartão de Receitas, Lucro de Investimentos, Badge "OK".Despesa / NegativoRose Red#EF4444Cartão de Despesas, Prejuízo, Alerta de Estouro.Alerta / AtençãoAmber Gold#F59E0BCategoria atingindo 90% do orçamento.Patrimônio / NeutroSlate / Dark Navy#1E293BSaldo Total Consolidado, Texto Principal, Títulos.Fundo PrincipalSoft Gray#F8FAFCBackground do Dashboard (Reduz fadiga visual).Bordas / SeparadoresLight Slate#E2E8F0Divisores de tabelas e contorno de cards.3. Formatação Monetária e NuméricaTodos os elementos de interface devem obedecer rigorosamente às normas de exibição abaixo:Símbolo de Moeda: Utilizar estritamente o padrão local R$ #.##0,00 (espaço simples após o símbolo de moeda).Casas Decimais:Valores Monetários: Sempre exatamente 2 casas decimais (ex: R$ 1.250,50).Quantidade de Ativos/Criptos: Até 6 casas decimais (ex: 0,004521 BTC).Percentuais: 1 ou 2 casas decimais acompanhadas do símbolo % (ex: 12,5%).Valores Negativos: Exibir com sinal de menos explícito e destaque em vermelho: -R$ 450,00.4. Diretrizes para Seleção de Gráficos e DashboardsPara evitar distorções de interpretação visual, aplicam-se as seguintes restrições:4.1. Regra dos Gráficos de Pizza / RoscaRestrição: PROIBIDO utilizar gráficos de pizza ou rosca para dimensões com mais de 5 categorias.Alternativa: Para analisar despesas por categoria (que frequentemente superam 5 itens), utilizar obrigatoriamente Gráficos de Barras Horizontais ordenados do maior valor para o menor.4.2. Layout Recomendado da Tela Principal (Grid System)Plaintext┌─────────────────────────────────────────────────────────────────────────┐
│ [KPI 1: Patrimônio]   [KPI 2: Receitas]   [KPI 3: Despesas]   [KPI 4: Saldo]│
├───────────────────────────────────────────┬─────────────────────────────┤
│ Gráfico de Linhas:                        │ Gráfico de Barras:          │
│ Evolução Patrimonial e Caixa (12 Meses)   │ Despesas por Categoria      │
├───────────────────────────────────────────┴─────────────────────────────┤
│ Tabela Paginada: Últimas Transações com Status de Validação e Ações     │
└─────────────────────────────────────────────────────────────────────────┘
5. Componentes e Usabilidade Web (Next.js)Modo Escuro / Claro (Dark Mode Support): O sistema deve oferecer suporte nativo a tema claro e escuro, ajustando os tons de fundo sem alterar a semântica do Verde/Vermelho.Estados de Carregamento (Skeleton Screen): Durante o carregamento das chamadas da API REST, exibir skeletons com pulso em cinza claro para evitar o Layout Shift.Feedback de Ação: Exibir confirmações do tipo Toast Notification ao inserir ou alterar uma transação.
---

<ElicitationsGroup message="Como deseja prosseguir para finalizar os documentos restantes ou avançar no código?">
  <Elicitation label="Gerar arquivos da pasta 07-ops-dev (setup-guide.md e env-variables.md)" query="Gere os arquivos da pasta docs/07-ops-dev: setup-guide.md (guia de ambiente/docker) e env-variables.md (dicionário de variáveis .env)."/>
  <Elicitation label="Iniciar implementação em código da Fase 1 (src/database/)" query="Avançar para a implementação técnica da Fase 1 em Python: crie o arquivo src/database/database.py com a conexão SQLAlchemy e src/database/models.py com os modelos ORM."/>
</ElicitationsGroup>