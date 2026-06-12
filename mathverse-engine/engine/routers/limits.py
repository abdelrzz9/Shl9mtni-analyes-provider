from fastapi import APIRouter, HTTPException
from ..schemas import LimitRequest, LimitResult
from ..sympy_engine import evaluate_limit
from ..logger import logger

router = APIRouter()


@router.post("/evaluate", response_model=LimitResult)
async def limit_endpoint(req: LimitRequest):
    try:
        return evaluate_limit(req.function, req.variable, req.approach_point, req.direction)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("limit evaluation failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="limit evaluation failed")
