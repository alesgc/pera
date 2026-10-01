-- ==========================================
-- 1. TABELAS DE DOMÍNIO FINANCEIRO & ATIVOS
-- ==========================================

CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA')),
    orcamento_mensal_limite NUMERIC(12, 2) DEFAULT 0.00 CHECK (orcamento_mensal_limite >= 0),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    data_transacao DATE NOT NULL CHECK (data_transacao <= CURRENT_DATE),
    descricao VARCHAR(150) NOT NULL,
    valor NUMERIC(12, 2) NOT NULL CHECK (valor > 0),
    tipo VARCHAR(10) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA')),
    categoria_id INT NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    meio_pagamento VARCHAR(30) DEFAULT 'OUTROS',
    hash_transacao VARCHAR(64) UNIQUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ativos (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    tipo_ativo VARCHAR(30) NOT NULL CHECK (tipo_ativo IN ('ACAO', 'FII', 'CRIPTO', 'RENDA_FIXA')),
    quantidade_total NUMERIC(15, 6) DEFAULT 0.00 CHECK (quantidade_total >= 0),
    preco_medio NUMERIC(12, 2) DEFAULT 0.00 CHECK (preco_medio >= 0)
);

CREATE TABLE cotacoes_historico (
    id SERIAL PRIMARY KEY,
    ativo_id INT NOT NULL REFERENCES ativos(id) ON DELETE CASCADE,
    data_cotacao DATE NOT NULL,
    preco_fechamento NUMERIC(12, 2) NOT NULL CHECK (preco_fechamento > 0),
    CONSTRAINT uk_ativo_data UNIQUE (ativo_id, data_cotacao)
);

-- ==========================================
-- 2. TABELAS DE MENSAGERIA E ALERTAS
-- ==========================================

CREATE TABLE regras_alertas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL CHECK (tipo_alerta IN ('TETO_CATEGORIA', 'SALDO_MINIMO', 'VARIACAO_ATIVO')),
    categoria_id INT REFERENCES categorias(id) ON DELETE CASCADE,
    valor_limite NUMERIC(12, 2) NOT NULL,
    canal VARCHAR(20) NOT NULL CHECK (canal IN ('EMAIL', 'TELEGRAM')),
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE log_alertas (
    id SERIAL PRIMARY KEY,
    regra_id INT REFERENCES regras_alertas(id) ON DELETE SET NULL,
    destinatario VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    status_envio VARCHAR(20) NOT NULL CHECK (status_envio IN ('PENDENTE', 'SUCESSO', 'FALHA')),
    enviado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 3. TABELAS DE AUDITORIA E ETL
-- ==========================================

CREATE TABLE log_etl (
    id SERIAL PRIMARY KEY,
    nome_pipeline VARCHAR(100) NOT NULL,
    inicio_execucao TIMESTAMP NOT NULL,
    fim_execucao TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('EM_ANDAMENTO', 'SUCESSO', 'ERRO')),
    registros_inseridos INT DEFAULT 0,
    registros_rejeitados INT DEFAULT 0,
    mensagem_erro TEXT,
    nome_arquivo VARCHAR(255),
    hash_arquivo VARCHAR(64)
);

CREATE TABLE log_auditoria (
    id SERIAL PRIMARY KEY,
    nome_tabela VARCHAR(50) NOT NULL,
    registro_id INT NOT NULL,
    operacao VARCHAR(10) NOT NULL CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE')),
    dados_antigos JSONB,
    dados_novos JSONB,
    executado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 4. VIEWS ANALÍTICAS PARA API E DASHBOARD
-- ==========================================

CREATE VIEW vw_resumo_mensal AS
SELECT 
    TO_CHAR(data_transacao, 'YYYY-MM') AS mes_ano,
    tipo,
    c.nome AS categoria,
    SUM(valor) AS total_gasto,
    c.orcamento_mensal_limite
FROM transacoes t
JOIN categorias c ON t.categoria_id = c.id
GROUP BY TO_CHAR(data_transacao, 'YYYY-MM'), tipo, c.nome, c.orcamento_mensal_limite;