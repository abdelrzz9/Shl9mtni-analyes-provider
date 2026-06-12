from fastapi import APIRouter, HTTPException
from ..schemas import TaylorRequest, TaylorResult
from ..sympy_engine import taylor_series
from ..logger import logger

router = APIRouter()


@router.post("/expand", response_model=TaylorResult)
async def taylor_endpoint(req: TaylorRequest):
    try:
        return taylor_series(req.function, req.variable, req.center, req.order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("taylor expansion failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="taylor expansion failed")
