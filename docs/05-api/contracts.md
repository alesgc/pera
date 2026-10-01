# 📑 Contratos de API & Schemas DTO (Pydantic v2)

**Projeto:** Ecosystem Financeiro & Analítico (End-to-End)  
**Módulo:** Backend API (FastAPI)  
**Versão:** 1.0.0  

---

## 1. Visão Geral das Camadas de Transferência de Dados (DTOs)

A API utiliza modelos **Pydantic v2** para garantir a validação rigorosa dos payloads de entrada (request) e a serialização padronizada das respostas (response). Todos os modelos herdam de configurações base com conversão automática de atributos ORM (`from_attributes = True`).

```text
[Request JSON] ──► [Input Schema Pydantic] ──► [Controller/ORM] ──► [Output Schema Pydantic] ──► [Response JSON]
2. Schemas do Domínio de Transações e Categorias
2.1. Categoria DTOs
Python
from datetime import datetime
from decimal import Decimal
from enum import Enum
from pydantic import BaseModel, ConfigDict, Field


class TipoFluxoEnum(str, Enum):
    RECEITA = "RECEITA"
    DESPESA = "DESPESA"


class CategoriaBaseSchema(BaseModel):
    nome: str = Field(..., min_length=2, max_length=50, example="Alimentação")
    tipo: TipoFluxoEnum = Field(..., example=TipoFluxoEnum.DESPESA)
    orcamento_mensal_limite: Decimal = Field(
        default=Decimal("0.00"), ge=Decimal("0.00"), example=Decimal("1500.00")
    )


class CategoriaCreateSchema(CategoriaBaseSchema):
    pass


class CategoriaUpdateOrcamentoSchema(BaseModel):
    orcamento_mensal_limite: Decimal = Field(
        ..., ge=Decimal("0.00"), example=Decimal("2000.00")
    )


class CategoriaResponseSchema(CategoriaBaseSchema):
    model_config = ConfigDict(from_attributes=True)

    id: int
    criado_em: datetime
2.2. Transação DTOs
Python
from datetime import date
from typing import Optional


class TransacaoBaseSchema(BaseModel):
    data_transacao: date = Field(..., example="2026-09-15")
    descricao: str = Field(..., min_length=1, max_length=150, example="Supermercado")
    valor: Decimal = Field(..., gt=Decimal("0.00"), example=Decimal("250.75"))
    tipo: TipoFluxoEnum = Field(..., example=TipoFluxoEnum.DESPESA)
    categoria_id: int = Field(..., gt=0, example=1)
    meio_pagamento: Optional[str] = Field(default="OUTROS", max_length=30, example="PIX")


class TransacaoCreateSchema(TransacaoBaseSchema):
    pass


class TransacaoResponseSchema(TransacaoBaseSchema):
    model_config = ConfigDict(from_attributes=True)

    id: int
    categoria_nome: Optional[str] = Field(default=None, example="Alimentação")
    hash_transacao: Optional[str] = Field(default=None, example="a1b2c3d4e5f6...")
    criado_em: datetime
3. Schemas de Métricas Analíticas & Patrimônio
3.1. Resumo Mensal por Categoria
Python
class ResumoMensalCategoriaSchema(BaseModel):
    mes_ano: str = Field(..., example="2026-09")
    tipo: TipoFluxoEnum
    categoria: str
    total_gasto: Decimal
    orcamento_mensal_limite: Decimal
    orcamento_excedido: bool
3.2. Posição Patrimonial Consolidada
Python
class PosicaoAtivoSchema(BaseModel):
    ticker: str = Field(..., example="PETR4")
    tipo_ativo: str = Field(..., example="ACAO")
    quantidade_total: Decimal
    preco_medio: Decimal
    preco_atual: Decimal
    valor_total_mercado: Decimal
    resultado_nao_realizado: Decimal


class ConsolidaçãoPatrimonialSchema(BaseModel):
    saldo_caixa_liquido: Decimal = Field(..., example=Decimal("12500.50"))
    total_investido_mercado: Decimal = Field(..., example=Decimal("45000.00"))
    patrimonio_liquido_total: Decimal = Field(..., example=Decimal("57500.50"))
    posicao_ativos: list[PosicaoAtivoSchema]
4. Schemas de Resposta Padrão & Paginação
4.1. Envelope Generico de Paginação
Python
from typing import Generic, TypeVar

T = TypeVar("T")


class PaginatedResponseSchema(BaseModel, Generic[T]):
    items: list[T]
    total_records: int = Field(..., example=150)
    page: int = Field(..., example=1)
    limit: int = Field(..., example=50)
    total_pages: int = Field(..., example=3)
4.2. Schema de Erro Padrão
Python
class ErrorDetailSchema(BaseModel):
    field: Optional[str] = Field(default=None, example="valor")
    message: str = Field(..., example="O valor da transação deve ser maior que zero.")


class ErrorResponseSchema(BaseModel):
    error: str = Field(..., example="UNPROCESSABLE_ENTITY")
    message: str = Field(..., example="Erro de validação nos campos da requisição.")
    details: Optional[list[ErrorDetailSchema]] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)