```markdown
# 🔌 Especificação de Endpoints REST (FastAPI)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Host Local:** `http://localhost:8000`  
**Swagger UI:** `http://localhost:8000/docs`  
**Versão:** 1.0.0  

---

## 1. Resumo das Rotas Disponíveis

| Método | Endpoint | Descrição | Status Code |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Verificação de integridade do servidor e banco de dados. | `200 OK` |
| `GET` | `/api/v1/transacoes` | Listagem paginada de transações com filtros temporais. | `200 OK` |
| `POST` | `/api/v1/transacoes` | Inserção de uma nova transação com deduplicação. | `201 Created` |
| `GET` | `/api/v1/categorias` | Lista todas as categorias cadastradas. | `200 OK` |
| `POST` | `/api/v1/categorias` | Cadastra uma nova categoria. | `201 Created` |
| `PATCH` | `/api/v1/categorias/{id}/orcamento` | Atualiza o teto orçamentário mensal de uma categoria. | `200 OK` |
| `GET` | `/api/v1/ativos` | Consulta a posição consolidada de ativos de investimento. | `200 OK` |
| `GET` | `/api/v1/metrics/resumo-mensal` | Retorna o consumo orçamentário agregado da view SQL. | `200 OK` |
| `GET` | `/api/v1/metrics/patrimonio` | Retorna a consolidação do patrimônio líquido total. | `200 OK` |

---

## 2. Detalhamento Técnico dos Endpoints Core

### 2.1. `GET /api/v1/transacoes`
Retorna a lista paginada de transações registradas no sistema.

#### Parâmetros de Query:
* `page` (int, opcional, padrão `1`): Número da página.
* `limit` (int, opcional, padrão `50`, max `200`): Quantidade de itens por página.
* `data_inicio` (date, opcional, formato `YYYY-MM-DD`): Filtro de data inicial.
* `data_fim` (date, opcional, formato `YYYY-MM-DD`): Filtro de data final.
* `categoria_id` (int, opcional): Filtra transações por categoria específica.
* `tipo` (string, opcional): `'RECEITA'` ou `'DESPESA'`.

#### Exemplo de Resposta (`200 OK`):
```json
{
  "items": [
    {
      "id": 102,
      "data_transacao": "2026-09-15",
      "descricao": "Supermercado Semanal",
      "valor": "340.50",
      "tipo": "DESPESA",
      "categoria_id": 2,
      "categoria_nome": "Alimentação",
      "meio_pagamento": "PIX",
      "hash_transacao": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "criado_em": "2026-09-15T18:30:00Z"
    }
  ],
  "total_records": 1,
  "page": 1,
  "limit": 50,
  "total_pages": 1
}
2.2. POST /api/v1/transacoes
Cria um novo registro de transação financeira no banco de dados.

Payload de Entrada (Request Body):
JSON
{
  "data_transacao": "2026-09-20",
  "descricao": "Pagamento de Aluguel",
  "valor": 1800.00,
  "tipo": "DESPESA",
  "categoria_id": 1,
  "meio_pagamento": "TRANSFERENCIA"
}
Respostas Possíveis:
201 Created: Transação criada com sucesso.

422 Unprocessable Entity: Data futura, valor negativo ou campos inválidos.

400 Bad Request: Transação duplicada identificada via hash SHA-256.

2.3. GET /api/v1/metrics/resumo-mensal
Consulta a visão analítica vw_resumo_mensal agregando os totais de gastos e o status do teto orçamentário.

Parâmetros de Query:
mes_ano (string, opcional, exemplo "2026-09"): Mês de referência.

Exemplo de Resposta (200 OK):
JSON
[
  {
    "mes_ano": "2026-09",
    "tipo": "DESPESA",
    "categoria": "Alimentação",
    "total_gasto": "1650.00",
    "orcamento_mensal_limite": "1500.00",
    "orcamento_excedido": true
  },
  {
    "mes_ano": "2026-09",
    "tipo": "DESPESA",
    "categoria": "Moradia",
    "total_gasto": "1800.00",
    "orcamento_mensal_limite": "2000.00",
    "orcamento_excedido": false
  }
]
2.4. GET /api/v1/metrics/patrimonio
Calcula em tempo real a consolidação do saldo financeiro em caixa e a valorização a mercado dos ativos da carteira.

Exemplo de Resposta (200 OK):
JSON
{
  "saldo_caixa_liquido": "12500.50",
  "total_investido_mercado": "45000.00",
  "patrimonio_liquido_total": "57500.50",
  "posicao_ativos": [
    {
      "ticker": "PETR4",
      "tipo_ativo": "ACAO",
      "quantidade_total": "500.000000",
      "preco_medio": "32.50",
      "preco_atual": "38.00",
      "valor_total_mercado": "19000.00",
      "resultado_nao_realizado": "2750.00"
    }
  ]
}
3. Padrão de Resposta de Erro (4xx e 5xx)
Todas as falhas tratadas na API retornam uma estrutura padronizada com cabeçalho Content-Type: application/json.

JSON
{
  "error": "UNPROCESSABLE_ENTITY",
  "message": "Erro de validação nos campos informados.",
  "details": [
    {
      "field": "valor",
      "message": "Input should be greater than 0"
    }
  ],
  "timestamp": "2026-10-01T15:00:00Z"
}

---

<ElicitationsGroup message="Como deseja prosseguir para finalizar a documentação ou iniciar o código?">
  <Elicitation label="Gerar arquivos da pasta 06-frontend-bi (dax-measures.md e ui-ux-guidelines.md)" query="Gere os arquivos da pasta docs/06-frontend-bi: dax-measures.md (catálogo de fórmulas DAX para o Power BI) e ui-ux-guidelines.md (guia visual e cores)."/>
  <Elicitation label="Iniciar o código da Fase 1 (src/database/database.py e models.py)" query="Avançar para a implementação da Fase 1 em Python: crie o arquivo src/database/database.py com a conexão SQLAlchemy e src/database/models.py com os modelos ORM das tabelas."/>
</ElicitationsGroup>