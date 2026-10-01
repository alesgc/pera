import os
from enum import Enum
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class EnvironmentType(str, Enum):
    DEVELOPMENT = "dev"
    TESTING = "test"
    PRODUCTION = "prod"


class Settings(BaseSettings):
    """
    Gerenciador central de configurações da aplicação.
    Lê automaticamente variáveis do arquivo .env ou do sistema operacional.
    """
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False
    )

    # ------------------------------------------
    # Metadados do Projeto
    # ------------------------------------------
    PROJECT_NAME: str = "Ecosystem Financeiro & Analítico"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = "Plataforma integrada de gestão financeira, ETL e inteligência de ativos."
    ENV: EnvironmentType = EnvironmentType.DEVELOPMENT
    DEBUG: bool = True

    # ------------------------------------------
    # Servidor & API (FastAPI)
    # ------------------------------------------
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    API_V1_PREFIX: str = "/api/v1"

    # ------------------------------------------
    # Banco de Dados (PostgreSQL)
    # ------------------------------------------
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "finance_db"

    @property
    def DATABASE_URL(self) -> str:
        """Gera a URL de conexão do SQLAlchemy dinamicamente."""
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    # ------------------------------------------
    # Parâmetros do Pipeline ETL
    # ------------------------------------------
    ETL_BATCH_SIZE: int = 1000
    MAX_FILE_SIZE_MB: int = 10

    # ------------------------------------------
    # Alertas & Notificações (Telegram e Email)
    # ------------------------------------------
    TELEGRAM_BOT_TOKEN: str | None = None
    TELEGRAM_CHAT_ID: str | None = None
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_EMAIL: str | None = None
    SMTP_PASSWORD: str | None = None


# Instância global para importação simplificada nos módulos
settings = Settings()