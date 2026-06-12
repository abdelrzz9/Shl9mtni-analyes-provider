import os


class Settings:
    app_name: str = "MathVerse Engine"
    app_version: str = "1.0.0"
    debug: bool = os.getenv("DEBUG", "false").lower() == "true"
    log_level: str = os.getenv("LOG_LEVEL", "info")
    cors_origins: list[str] = os.getenv(
        "CORS_ORIGINS", "http://localhost:3000"
    ).split(",")
    engine_timeout_seconds: int = int(os.getenv("ENGINE_TIMEOUT_SECONDS", "30"))
    max_expression_length: int = int(os.getenv("MAX_EXPRESSION_LENGTH", "10000"))
    max_matrix_size: int = int(os.getenv("MAX_MATRIX_SIZE", "100"))
    max_data_points: int = int(os.getenv("MAX_DATA_POINTS", "10000"))
    cache_enabled: bool = os.getenv("CACHE_ENABLED", "true").lower() == "true"
    cache_max_size: int = int(os.getenv("CACHE_MAX_SIZE", "500"))
    cache_ttl_seconds: int = int(os.getenv("CACHE_TTL_SECONDS", "3600"))


settings = Settings()
