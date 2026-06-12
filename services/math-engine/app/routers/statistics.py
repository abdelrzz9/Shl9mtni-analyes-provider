from fastapi import APIRouter, HTTPException
from ..schemas import StatisticsRequest
from ..sympy_engine import calculate_statistics

router = APIRouter()


@router.post("/calculate")
async def statistics_endpoint(req: StatisticsRequest):
    try:
        return calculate_statistics(req.data, req.operation, req.data2)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
