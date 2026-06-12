from fastapi import APIRouter, HTTPException
from ..schemas import LimitRequest
from ..sympy_engine import evaluate_limit

router = APIRouter()


@router.post("/evaluate")
async def limit_endpoint(req: LimitRequest):
    try:
        return evaluate_limit(req.function, req.variable, req.approach_point, req.direction)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
