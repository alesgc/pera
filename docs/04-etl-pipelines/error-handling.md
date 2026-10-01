# 🚨 Tratamento de Erros, Quarentena & Idempotência

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Governance & Resilience  
**Versão:** 1.0.0  

---

## 1. Estratégia de Idempotência em Dois Níveis

Para garantir a **reprodutibilidade segura** dos pipelines de dados (permitindo reexecuções sem gerar registros duplicados ou alterar métricas acumuladas), o sistema aplica controle de idempotência em duas etapas:

```text
                       [Arquivo de Extrato Recebido]
                                     │
                        Calcula Hash SHA-256 do Arquivo
                                     │
                   ┌─────────────────┴─────────────────┐
                   ▼                                   ▼
          Hash existe em log_etl?             Hash NÃO existe em log_etl
                   │                                   │
         [ABORTA PROCESSAMENTO]              [Inicia Carga de Registros]
        (Retorna Status: SUCESSO)                      │
                                             Calcula Hash por Linha (SHA-256)
                                                       │
                                            ┌──────────┴──────────┐
                                            ▼                     ▼
                                     Hash no Banco?        Hash NãO existe
                                            │                     │
                                   [IGNORA REGISTRO]      [INSERE NO POSTGRES]
1.1. Nível 1: Deduplicação de Arquivo CompletoNo início da execução, o script calcula a hash SHA-256 sobre a totalidade do conteúdo binário do arquivo:Se hash_arquivo já consta na tabela log_etl com status 'SUCESSO', o pipeline registra uma mensagem informativa e encerra a execução sem gravar dados no banco.1.2. Nível 2: Deduplicação Linha a LinhaCaso o arquivo seja novo, porém contenha transações previamente importadas em outros extratos, a deduplicação ocorre na coluna hash_transacao utilizando a cláusula SQL:SQLINSERT INTO transacoes (...) VALUES (...)
ON CONFLICT (hash_transacao) DO NOTHING;
2. Tratamento de Falhas e Arquivo de QuarentenaPara evitar que uma única linha corrompida (ex: formato de data inválido ou valor corrompido) interrompa o processamento de um lote com centenas de linhas válidas, o pipeline adota a estratégia de quarentena.2.1. Fluxo de Segregação de Registros InválidosCaptura do Erro: Durante a validação via modelo Pydantic (TransacaoSchema), exceções do tipo ValidationError são capturadas individualmente por registro.Isolamento em Quarentena: A linha com falha é appendada em um arquivo de erro gravado em data/quarantine/:Nome do Arquivo: erros_ingestao_YYYYMMDD_HHMMSS.csvEstrutura: O arquivo contém todas as colunas originais do dado bruto acrescido da coluna motivo_erro.Mapeamento de Métricas: A contagem de linhas rejeitadas é atualizada em tempo de execução.3. Estados do Pipeline e Governança (log_etl)Toda execução de pipeline deve ser obrigatoriamente registrada na tabela log_etl, cobrindo o ciclo de vida completo do processamento.Snippet de códigostateDiagram-v2
    [*] --> EM_ANDAMENTO : Inicia Script / Insere Log
    EM_ANDAMENTO --> SUCESSO : Carga Concluída (100% ou Parcial com Quarentena)
    EM_ANDAMENTO --> ERRO : Falha Crítica de Conexão ou Infraestrutura
    SUCESSO --> [*]
    ERRO --> [*]
3.1. Classificação de FalhasCategoria da FalhaExemploComportamento do PipelineStatus em log_etlErro de Schema/SintaxeData "31/02/2026" ou valor contendo texto.Move a linha para a quarentena e continua as demais.'SUCESSO' (com registros_rejeitados > 0)Integridade de NegócioTentativa de venda sem saldo em carteira.Aborta o registro específico e grava em quarentena.'SUCESSO' (com registros_rejeitados > 0)Falha de InfraestruturaPerda de conexão com o PostgreSQL ou queda da rede.Realiza ROLLBACK total do lote no banco de dados.'ERRO' (com mensagem_erro preenchida)4. Script de Reprocessamento da QuarentenaRegistros salvos no diretório de quarentena podem ser reprocessados após a correção manual do arquivo através do comando CLI:Bashpython -m src.etl.pipeline_reprocessamento --quarantine-file data/quarantine/erros_ingestao_20261001.csv

---

<ElicitationsGroup message="Como deseja prosseguir com os arquivos de documentação?">
  <Elicitation label="Gerar os arquivos da pasta 05-api (contracts.md e endpoints.md)" query="Gere os arquivos da pasta docs/05-api: contracts.md (Schemas Pydantic e DTOs) e endpoints.md (especificação de rotas REST)."/>
  <Elicitation label="Avançar para o código da Fase 1 (src/database/database.py e models.py)" query="Avançar para a implementação técnica da Fase 1: crie o arquivo src/database/database.py para conexão SQLAlchemy e src/database/models.py com os modelos ORM."/>
</ElicitationsGroup>