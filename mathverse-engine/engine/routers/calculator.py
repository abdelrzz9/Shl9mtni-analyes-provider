from fastapi import APIRouter, HTTPException
from ..schemas import ExpressionRequest, ExpressionResult, ValidateResult
from ..sympy_engine import evaluate_expression
from ..logger import logger

router = APIRouter()


@router.post("/evaluate", response_model=ExpressionResult)
async def evaluate(req: ExpressionRequest):
    try:
        return evaluate_expression(req.expression)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error("calculator evaluate failed", extra={"error": str(e)})
        raise HTTPException(status_code=422, detail="expression evaluation failed")


@router.post("/validate", response_model=ValidateResult)
async def validate(req: ExpressionRequest):
    try:
        evaluate_expression(req.expression)
        return {"valid": True}
    except Exception:
        return {"valid": False}
