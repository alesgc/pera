```markdown
# 🔑 Dicionário de Variáveis de Ambiente (`.env`)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Configuration Management  
**Versão:** 1.0.0  

---

## 1. Visão Geral das Configurações

O arquivo `.env` fica localizado na raiz do projeto e gerencia todas as credenciais de banco, portas de serviços, chaves de API e parâmetros de execução. Em código Python, essas variáveis são lidas e validadas pela classe `Settings` no módulo `src/config.py`.

---

## 2. Tabela de Variáveis de Ambiente

| Nome da Variável | Tipo | Obrigatorio? | Valor Padrão (Dev) | Descrição e Finalidade |
| :--- | :--- | :--- | :--- | :--- |
| **Meta & Ambiente** | | | | |
| `PROJECT_NAME` | String | Não | `"Ecosystem Financeiro"` | Nome exibido na documentação Swagger do FastAPI. |
| `ENV` | Enum | Não | `"dev"` | Tipo do ambiente (`dev`, `test`, `prod`). |
| `DEBUG` | Boolean | Não | `True` | Habilita logs detalhados e depuração no servidor. |
| **API & Servidor** | | | | |
| `API_HOST` | String | Não | `"0.0.0.0"` | Endereço IP onde a API escutará as requisições. |
| `API_PORT` | Integer | Não | `8000` | Porta local utilizada pelo Uvicorn para o FastAPI. |
| `API_V1_PREFIX` | String | Não | `"/api/v1"` | Prefixo global das rotas REST. |
| **PostgreSQL Database** | | | | |
| `POSTGRES_USER` | String | **Sim** | `"postgres"` | Usuário do banco de dados. |
| `POSTGRES_PASSWORD` | String | **Sim** | `"postgres"` | Senha de acesso ao banco. |
| `POSTGRES_HOST` | String | **Sim** | `"localhost"` | Host do banco (`localhost` ou nome do container `postgres`). |
| `POSTGRES_PORT` | Integer | **Sim** | `5432` | Porta de conexão do PostgreSQL. |
| `POSTGRES_DB` | String | **Sim** | `"finance_db"` | Nome do banco de dados relacional. |
| **Pipeline ETL** | | | | |
| `ETL_BATCH_SIZE` | Integer | Não | `1000` | Quantidade de registros por lote de escrita no banco. |
| `MAX_FILE_SIZE_MB` | Integer | Não | `10` | Tamanho máximo permitido para upload de extratos em MB. |
| **Mensageria & Alertas** | | | | |
| `TELEGRAM_BOT_TOKEN` | String | Não | `None` | Token de autenticação retornado pelo BotFather do Telegram. |
| `TELEGRAM_CHAT_ID` | String | Não | `None` | ID do chat/canal de destino das notificações. |
| `SMTP_SERVER` | String | Não | `"smtp.gmail.com"`| Endereço do servidor SMTP para envio de e-mails. |
| `SMTP_PORT` | Integer | Não | `587` | Porta de conexão TLS do servidor SMTP. |
| `SMTP_EMAIL` | String | Não | `None` | E-mail remetente utilizado para notificações. |
| `SMTP_PASSWORD` | String | Não | `None` | Senha de aplicativo ou token de serviço do servidor SMTP. |

---

## 3. Arquivo de Exemplo (`.env.example`)

Abaixo está o conteúdo exato que deve constar no arquivo `.env.example` versionado no Git:

```ini
# ==========================================
# METADADOS DA APLICAÇÃO
# ==========================================
PROJECT_NAME="Ecosystem Financeiro & Analítico"
ENV=dev
DEBUG=True

# ==========================================
# SERVIDOR FASTAPI
# ==========================================
API_HOST=0.0.0.0
API_PORT=8000
API_V1_PREFIX=/api/v1

# ==========================================
# POSTGRESQL DATABASE
# ==========================================
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=finance_db

# ==========================================
# CONFIGURAÇÕES DE ETL
# ==========================================
ETL_BATCH_SIZE=1000
MAX_FILE_SIZE_MB=10

# ==========================================
# ALERTAS E NOTIFICAÇÕES (TELEGRAM / EMAIL)
# ==========================================
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=
SMTP_PASSWORD=

---

<ElicitationsGroup message="Toda a estrutura de documentação (pastas 00 a 07) foi finalizada com sucesso! Qual o próximo passo do projeto?">
  <Elicitation label="Iniciar o código da Fase 1: Conexão PostgreSQL (src/database/database.py)" query="Vamos iniciar a Fase 1 da implementação: crie a configuração da sessão do SQLAlchemy com PostgreSQL em src/database/database.py."/>
  <Elicitation label="Gerar os modelos ORM das tabelas em Python (src/database/models.py)" query="Gere o arquivo src/database/models.py mapeando todas as tabelas e relacionamentos usando SQLAlchemy ORM."/>
</ElicitationsGroup>