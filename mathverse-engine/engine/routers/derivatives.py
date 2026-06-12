from fastapi import APIRouter, HTTPException
from ..schemas import DerivativeRequest, DerivativeResult
from ..sympy_engine import differentiate
from ..logger import logger

router = APIRouter()


@router.post("/differentiate", response_model=DerivativeResult)
async def differentiate_endpoint(req: DerivativeRequest):
    try:
        return differentiate(req.function, req.variable, req.order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("differentiate failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="differentiation failed")
