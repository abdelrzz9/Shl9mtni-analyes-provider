from fastapi import APIRouter, HTTPException
from ..schemas import MatrixRequest
from ..sympy_engine import matrix_add, matrix_multiply, matrix_determinant, matrix_inverse, matrix_transpose

router = APIRouter()


@router.post("/add")
async def add(req: MatrixRequest):
    if req.matrix_b is None:
        raise HTTPException(status_code=400, detail="matrix_b required")
    try:
        return matrix_add(req.matrix, req.matrix_b)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/multiply")
async def multiply(req: MatrixRequest):
    if req.matrix_b is None:
        raise HTTPException(status_code=400, detail="matrix_b required")
    try:
        return matrix_multiply(req.matrix, req.matrix_b)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/determinant")
async def determinant(req: MatrixRequest):
    try:
        return matrix_determinant(req.matrix)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/inverse")
async def inverse(req: MatrixRequest):
    try:
        return matrix_inverse(req.matrix)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/transpose")
async def transpose(req: MatrixRequest):
    try:
        return matrix_transpose(req.matrix)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
