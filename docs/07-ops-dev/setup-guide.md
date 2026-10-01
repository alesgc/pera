# 🛠️ Guia de Setup & Execução do Ambiente Local

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** DevOps & Operations  
**Versão:** 1.2.0  

---

## 1. Pré-requisitos de Sistema

Antes de iniciar a instalação, certifique-se de ter os seguintes utilitários instalados em sua máquina (Linux, macOS ou Windows via WSL2):

* **Python:** Versão `3.12+` (com `pip` e `venv` configurados)
* **Docker & Docker Compose:** Docker Engine `24+` e Docker Compose `v2+`
* **Node.js:** Versão `20+` (LTS) e gerenciador `npm`
* **Git:** Versão `2.40+`

---

## 2. Passo a Passo de Provisionamento e Instalação

### Passo 1: Clonar o Repositório
```bash
git clone [https://github.com/alesgc/ecosystem-financeiro.git](https://github.com/alesgc/ecosystem-financeiro.git)
cd ecosystem-financeiro
Passo 2: Configurar as Variáveis de Ambiente
Crie o arquivo .env na raiz do projeto clonando o modelo .env.example:

Bash
cp .env.example .env
Passo 3: Provisionar a Infraestrutura via Docker
Suba a instância isolada do PostgreSQL em segundo plano:

Bash
docker-compose up -d postgres
Para verificar se o container do banco está ativo e saudável:

Bash
docker-compose ps
Passo 4: Configurar o Ambiente Virtual Python
Crie o ambiente isolado .venv e instale as dependências de produção e desenvolvimento:

Bash
# Criação do ambiente virtual
python3 -m venv .venv

# Ativação do ambiente
# Linux/macOS:
source .venv/bin/activate
# Windows (PowerShell):
.venv\Scripts\Activate.ps1

# Atualização do pip e instalação de pacotes
pip install --upgrade pip
pip install -r requirements.txt
Passo 5: Gerenciamento de Migrações de Banco de Dados (Alembic)
Execute as migrações do Alembic para criar/atualizar o esquema do banco de dados relacional:

Bash
# Aplicar todas as migrações pendentes até a versão mais recente (Head)
alembic upgrade head
Para criar novas migrações após alterar os modelos SQLAlchemy em src/database/models.py:

Bash
alembic revision --autogenerate -m "descricao_da_alteracao"
Passo 6: Executar a Carga Inicial de Dados (ETL)
Inicie a ingestão do arquivo de extrato de exemplo para povoar o banco:

Bash
python -m src.etl.pipeline_transacoes --file data/sample/extrato_inicial.csv
Passo 7: Iniciar o Servidor Backend (FastAPI)
Suba a API REST assíncrona em modo de desenvolvimento com live reload:

Bash
uvicorn src.api.main:app --reload --host 0.0.0.0 --port 8000
Swagger UI (Documentação Interativa): http://localhost:8000/docs

ReDoc: http://localhost:8000/redoc

Passo 8: Iniciar o Painel Web (Next.js)
Em um novo terminal, acesse a pasta da aplicação web e suba o servidor de desenvolvimento:

Bash
cd src/web
npm install
npm run dev
Aplicaçao Web: http://localhost:3000

3. Comandos Úteis de Desenvolvimento e Qualidade
Execução da Suíte de Testes (Pytest)
Bash
# Executa todos os testes unitários com relatório de cobertura
pytest
Formatação e Linting de Código
Bash
# Verificar problemas de código via Ruff
ruff check .

# Formatar código automaticamente via Black
black .
Encerrar e Limpar Containers do Docker
Bash
# Para os containers sem apagar o volume de dados
docker-compose down

# Para os containers e limpa os volumes do banco de dados (Reset total)
docker-compose down -v

---

<FollowUp label="Tudo atualizado! Podemos iniciar a Fase 1 da implementação criando src/database/database.py e models.py?" query="Vamos iniciar a Fase 1 da implementação técnica: crie o arquivo src/database/database.py para conexão SQLAlchemy e o arquivo src/database/models.py com os modelos ORM das tabelas atualizadas."/>