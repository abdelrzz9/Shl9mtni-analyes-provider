from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import settings
from .logger import logger
from .routers import (
    calculator,
    derivatives,
    dl,
    graph,
    integrals,
    limits,
    matrix,
    statistics,
    taylor,
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info(
        "starting mathverse-engine",
        extra={"version": settings.app_version, "debug": settings.debug},
    )
    yield
    logger.info("shutting down mathverse-engine")


app = FastAPI(
    title=settings.app_name,
    description="Symbolic mathematics engine powered by SymPy",
    version=settings.app_version,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(
        "unhandled exception",
        extra={"path": str(request.url), "error": str(exc)},
    )
    return JSONResponse(
        status_code=500,
        content={"detail": "internal server error", "error_code": "INTERNAL_ERROR"},
    )


app.include_router(calculator.router, prefix="/api/v1/calculator", tags=["Calculator"])
app.include_router(derivatives.router, prefix="/api/v1/derivatives", tags=["Derivatives"])
app.include_router(integrals.router, prefix="/api/v1/integrals", tags=["Integrals"])
app.include_router(limits.router, prefix="/api/v1/limits", tags=["Limits"])
app.include_router(taylor.router, prefix="/api/v1/taylor", tags=["Taylor"])
app.include_router(dl.router, prefix="/api/v1/dl", tags=["DL"])
app.include_router(matrix.router, prefix="/api/v1/matrix", tags=["Matrix"])
app.include_router(statistics.router, prefix="/api/v1/statistics", tags=["Statistics"])
app.include_router(graph.router, prefix="/api/v1/graph", tags=["Graph"])


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "version": settings.app_version,
        "cache_size": 0,
    }
