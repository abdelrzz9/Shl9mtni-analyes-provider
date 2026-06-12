from fastapi import APIRouter, HTTPException
from ..schemas import MatrixRequest, MatrixResult
from ..sympy_engine import (
    matrix_add,
    matrix_multiply,
    matrix_determinant,
    matrix_inverse,
    matrix_transpose,
)
from ..logger import logger

router = APIRouter()


@router.post("/add", response_model=MatrixResult)
async def add(req: MatrixRequest):
    if req.matrix_b is None:
        raise HTTPException(status_code=400, detail="matrix_b required")
    try:
        return matrix_add(req.matrix, req.matrix_b)
    except Exception as e:
        logger.error("matrix add failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/multiply", response_model=MatrixResult)
async def multiply(req: MatrixRequest):
    if req.matrix_b is None:
        raise HTTPException(status_code=400, detail="matrix_b required")
    try:
        return matrix_multiply(req.matrix, req.matrix_b)
    except Exception as e:
        logger.error("matrix multiply failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/determinant", response_model=MatrixResult)
async def determinant(req: MatrixRequest):
    try:
        return matrix_determinant(req.matrix)
    except Exception as e:
        logger.error("matrix determinant failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/inverse", response_model=MatrixResult)
async def inverse(req: MatrixRequest):
    try:
        return matrix_inverse(req.matrix)
    except Exception as e:
        logger.error("matrix inverse failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail=str(e))


@router.post("/transpose", response_model=MatrixResult)
async def transpose(req: MatrixRequest):
    try:
        return matrix_transpose(req.matrix)
    except Exception as e:
        logger.error("matrix transpose failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail=str(e))
