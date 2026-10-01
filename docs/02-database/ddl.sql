-- ==============================================================================
-- PROJETO: Ecosystem Financeiro & Analítico (End-to-End)
-- DESCRIÇÃO: Script DDL com Suporte a Multimoeda (USD/PTAX) e Views Analíticas
-- VERSÃO: 1.2.0
-- SGBD ALVO: PostgreSQL 15+
-- ==============================================================================

DROP VIEW IF EXISTS vw_posicao_ativos_consolidada CASCADE;
DROP VIEW IF EXISTS vw_resumo_mensal CASCADE;
DROP TABLE IF EXISTS log_auditoria CASCADE;
DROP TABLE IF EXISTS log_etl CASCADE;
DROP TABLE IF EXISTS log_alertas CASCADE;
DROP TABLE IF EXISTS regras_alertas CASCADE;
DROP TABLE IF EXISTS taxas_cambio CASCADE;
DROP TABLE IF EXISTS cotacoes_historico CASCADE;
DROP TABLE IF EXISTS ativos CASCADE;
DROP TABLE IF EXISTS transacoes CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;

-- ==============================================================================
-- 1. TABELAS DE DOMÍNIO FINANCEIRO & ATIVOS MULTIMOEDA
-- ==============================================================================

-- Tabela: categorias
CREATE TABLE categorias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    tipo VARCHAR(15) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA', 'INVESTIMENTO')),
    orcamento_mensal_limite NUMERIC(12, 2) DEFAULT 0.00 CHECK (orcamento_mensal_limite >= 0),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: transacoes
CREATE TABLE transacoes (
    id SERIAL PRIMARY KEY,
    data_transacao DATE NOT NULL CHECK (data_transacao <= CURRENT_DATE),
    descricao VARCHAR(150) NOT NULL,
    valor NUMERIC(12, 2) NOT NULL CHECK (valor > 0),
    tipo VARCHAR(15) NOT NULL CHECK (tipo IN ('RECEITA', 'DESPESA', 'INVESTIMENTO')),
    categoria_id INT NOT NULL REFERENCES categorias(id) ON DELETE RESTRICT,
    meio_pagamento VARCHAR(30) DEFAULT 'OUTROS',
    hash_transacao VARCHAR(64) UNIQUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: ativos
CREATE TABLE ativos (
    id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL UNIQUE,
    nome VARCHAR(100) NOT NULL,
    tipo_ativo VARCHAR(30) NOT NULL CHECK (tipo_ativo IN ('ACAO', 'FII', 'CRIPTO', 'RENDA_FIXA', 'STOCK', 'REIT')),
    moeda_cotacao VARCHAR(3) NOT NULL DEFAULT 'BRL' CHECK (moeda_cotacao IN ('BRL', 'USD')),
    quantidade_total NUMERIC(15, 6) DEFAULT 0.00 CHECK (quantidade_total >= 0),
    preco_medio NUMERIC(12, 2) DEFAULT 0.00 CHECK (preco_medio >= 0)
);

-- Tabela: cotacoes_historico
CREATE TABLE cotacoes_historico (
    id SERIAL PRIMARY KEY,
    ativo_id INT NOT NULL REFERENCES ativos(id) ON DELETE CASCADE,
    data_cotacao DATE NOT NULL,
    preco_fechamento NUMERIC(12, 2) NOT NULL CHECK (preco_fechamento > 0),
    CONSTRAINT uk_ativo_data UNIQUE (ativo_id, data_cotacao)
);

-- Tabela: taxas_cambio (Histórico da PTAX do Banco Central USD -> BRL)
CREATE TABLE taxas_cambio (
    id SERIAL PRIMARY KEY,
    data_referencia DATE NOT NULL CHECK (data_referencia <= CURRENT_DATE),
    moeda_origem VARCHAR(3) NOT NULL DEFAULT 'USD',
    moeda_destino VARCHAR(3) NOT NULL DEFAULT 'BRL',
    taxa_ptax_fechamento NUMERIC(10, 4) NOT NULL CHECK (taxa_ptax_fechamento > 0),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_cambio_data_moeda UNIQUE (data_referencia, moeda_origem, moeda_destino)
);

-- ==============================================================================
-- 2. TABELAS DE MENSAGERIA, ETL E AUDITORIA
-- ==============================================================================

CREATE TABLE regras_alertas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_alerta VARCHAR(30) NOT NULL CHECK (tipo_alerta IN ('TETO_CATEGORIA', 'SALDO_MINIMO', 'VARIACAO_ATIVO')),
    categoria_id INT REFERENCES categorias(id) ON DELETE CASCADE,
    valor_limite NUMERIC(12, 2) NOT NULL CHECK (valor_limite >= 0),
    canal VARCHAR(20) NOT NULL CHECK (canal IN ('EMAIL', 'TELEGRAM')),
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_alertas (
    id SERIAL PRIMARY KEY,
    regra_id INT REFERENCES regras_alertas(id) ON DELETE SET NULL,
    destinatario VARCHAR(100) NOT NULL,
    mensagem TEXT NOT NULL,
    status_envio VARCHAR(20) NOT NULL CHECK (status_envio IN ('PENDENTE', 'SUCESSO', 'FALHA')),
    enviado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE log_etl (
    id SERIAL PRIMARY KEY,
    nome_pipeline VARCHAR(100) NOT NULL,
    inicio_execucao TIMESTAMP NOT NULL,
    fim_execucao TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('EM_ANDAMENTO', 'SUCESSO', 'ERRO')),
    registros_inseridos INT DEFAULT 0 CHECK (registros_inseridos >= 0),
    registros_rejeitados INT DEFAULT 0 CHECK (registros_rejeitados >= 0),
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

-- ==============================================================================
-- 3. ÍNDICES DE PERFORMANCE
-- ==============================================================================

CREATE INDEX idx_transacoes_data ON transacoes(data_transacao);
CREATE INDEX idx_transacoes_categoria ON transacoes(categoria_id);
CREATE INDEX idx_transacoes_tipo ON transacoes(tipo);
CREATE INDEX idx_cotacoes_ativo_data ON cotacoes_historico(ativo_id, data_cotacao DESC);
CREATE INDEX idx_taxas_cambio_data ON taxas_cambio(data_referencia DESC);

-- ==============================================================================
-- 4. TRIGGER DE AUDITORIA
-- ==============================================================================

CREATE OR REPLACE FUNCTION fn_trg_auditoria_transacoes()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO log_auditoria(nome_tabela, registro_id, operacao, dados_antigos)
        VALUES ('transacoes', OLD.id, 'DELETE', to_jsonb(OLD));
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO log_auditoria(nome_tabela, registro_id, operacao, dados_antigos, dados_novos)
        VALUES ('transacoes', NEW.id, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO log_auditoria(nome_tabela, registro_id, operacao, dados_novos)
        VALUES ('transacoes', NEW.id, 'INSERT', to_jsonb(NEW));
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_transacoes
AFTER INSERT OR UPDATE OR DELETE ON transacoes
FOR EACH ROW EXECUTE FUNCTION fn_trg_auditoria_transacoes();

-- ==============================================================================
-- 5. VIEWS ANALÍTICAS
-- ==============================================================================

-- View 1: Resumo Mensal de Gastos Operacionais (Apenas DESPESA)
CREATE VIEW vw_resumo_mensal AS
SELECT 
    TO_CHAR(t.data_transacao, 'YYYY-MM') AS mes_ano,
    t.tipo,
    c.nome AS categoria,
    SUM(t.valor) AS total_gasto,
    c.orcamento_mensal_limite,
    CASE 
        WHEN t.tipo = 'DESPESA' 
             AND c.orcamento_mensal_limite > 0 
             AND SUM(t.valor) > c.orcamento_mensal_limite THEN TRUE
        ELSE FALSE
    END AS orcamento_excedido
FROM transacoes t
JOIN categorias c ON t.categoria_id = c.id
GROUP BY TO_CHAR(t.data_transacao, 'YYYY-MM'), t.tipo, c.nome, c.orcamento_mensal_limite;

-- View 2: Posição Consolidada de Ativos Convertida para BRL via PTAX
CREATE VIEW vw_posicao_ativos_consolidada AS
SELECT 
    a.id AS ativo_id,
    a.ticker,
    a.nome,
    a.tipo_ativo,
    a.moeda_cotacao,
    a.quantidade_total,
    a.preco_medio AS preco_medio_original,
    c.preco_fechamento AS preco_atual_original,
    COALESCE(tc.taxa_ptax_fechamento, 1.0000) AS taxa_ptax_aplicada,
    CASE 
        WHEN a.moeda_cotacao = 'USD' THEN c.preco_fechamento * COALESCE(tc.taxa_ptax_fechamento, 1.0000)
        ELSE c.preco_fechamento
    END AS preco_atual_brl,
    (a.quantidade_total * CASE 
        WHEN a.moeda_cotacao = 'USD' THEN c.preco_fechamento * COALESCE(tc.taxa_ptax_fechamento, 1.0000)
        ELSE c.preco_fechamento
    END) AS valor_total_mercado_brl
FROM ativos a
LEFT JOIN LATERAL (
    SELECT preco_fechamento, data_cotacao
    FROM cotacoes_historico
    WHERE ativo_id = a.id
    ORDER BY data_cotacao DESC
    LIMIT 1
) c ON TRUE
LEFT JOIN LATERAL (
    SELECT taxa_ptax_fechamento
    FROM taxas_cambio
    WHERE data_referencia <= COALESCE(c.data_cotacao, CURRENT_DATE)
    ORDER BY data_referencia DESC
    LIMIT 1
) tc ON a.moeda_cotacao = 'USD';