from fastapi import APIRouter, HTTPException
from ..schemas import DLRequest, DLResult
from ..sympy_engine import dl_expansion

router = APIRouter()


@router.post("/expand", response_model=DLResult)
async def dl_endpoint(req: DLRequest):
    try:
        return dl_expansion(req.function, req.variable, req.point, req.order)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=422, detail=str(e))
