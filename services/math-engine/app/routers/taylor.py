from fastapi import APIRouter, HTTPException
from ..schemas import TaylorRequest
from ..sympy_engine import taylor_series

router = APIRouter()


@router.post("/expand")
async def taylor_endpoint(req: TaylorRequest):
    try:
        return taylor_series(req.function, req.variable, req.center, req.order)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
