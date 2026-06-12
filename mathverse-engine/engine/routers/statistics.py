from fastapi import APIRouter, HTTPException
from ..schemas import StatisticsRequest, StatisticsResult
from ..sympy_engine import calculate_statistics
from ..logger import logger

router = APIRouter()


@router.post("/calculate", response_model=StatisticsResult)
async def statistics_endpoint(req: StatisticsRequest):
    try:
        return calculate_statistics(req.data, req.operation, req.data2)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("statistics calculation failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="statistics calculation failed")
