from fastapi import APIRouter, HTTPException
from ..schemas import GraphRequest, GraphResult
from ..sympy_engine import plot_function
from ..logger import logger

router = APIRouter()


@router.post("/plot", response_model=GraphResult)
async def graph_endpoint(req: GraphRequest):
    try:
        return plot_function(req.function, req.variable, req.x_min, req.x_max, req.step)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("plot generation failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="plot generation failed")
