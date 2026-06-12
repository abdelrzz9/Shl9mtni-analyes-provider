from fastapi import APIRouter, HTTPException
from ..schemas import DerivativeRequest
from ..sympy_engine import differentiate

router = APIRouter()


@router.post("/differentiate")
async def differentiate_endpoint(req: DerivativeRequest):
    try:
        return differentiate(req.function, req.variable, req.order)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
