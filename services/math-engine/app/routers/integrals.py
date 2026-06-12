from fastapi import APIRouter, HTTPException
from ..schemas import IntegralRequest
from ..sympy_engine import integrate

router = APIRouter()


@router.post("/integrate")
async def integrate_endpoint(req: IntegralRequest):
    try:
        return integrate(req.function, req.variable, req.lower_bound, req.upper_bound)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
