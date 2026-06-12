from fastapi import APIRouter, HTTPException
from ..schemas import IntegralRequest, IntegralResult
from ..sympy_engine import integrate
from ..logger import logger

router = APIRouter()


@router.post("/integrate", response_model=IntegralResult)
async def integrate_endpoint(req: IntegralRequest):
    try:
        return integrate(req.function, req.variable, req.lower_bound, req.upper_bound)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("integration failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="integration failed")
