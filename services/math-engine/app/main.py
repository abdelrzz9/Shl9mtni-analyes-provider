from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import calculator, derivatives, integrals, limits, taylor, matrix, statistics, graph

app = FastAPI(
    title="Math Engine API",
    description="Symbolic mathematics engine powered by SymPy",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(calculator.router, prefix="/api/v1/calculator", tags=["Calculator"])
app.include_router(derivatives.router, prefix="/api/v1/derivatives", tags=["Derivatives"])
app.include_router(integrals.router, prefix="/api/v1/integrals", tags=["Integrals"])
app.include_router(limits.router, prefix="/api/v1/limits", tags=["Limits"])
app.include_router(taylor.router, prefix="/api/v1/taylor", tags=["Taylor"])
app.include_router(matrix.router, prefix="/api/v1/matrix", tags=["Matrix"])
app.include_router(statistics.router, prefix="/api/v1/statistics", tags=["Statistics"])
app.include_router(graph.router, prefix="/api/v1/graph", tags=["Graph"])


@app.get("/health")
async def health():
    return {"status": "ok", "version": "1.0.0"}
