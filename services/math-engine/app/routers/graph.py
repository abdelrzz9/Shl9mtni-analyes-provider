from fastapi import APIRouter, HTTPException
from ..schemas import GraphRequest
from ..sympy_engine import plot_function

router = APIRouter()


@router.post("/plot")
async def graph_endpoint(req: GraphRequest):
    try:
        return plot_function(req.function, req.variable, req.x_min, req.x_max, req.step)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
