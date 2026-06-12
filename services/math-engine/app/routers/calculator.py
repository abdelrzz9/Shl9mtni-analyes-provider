from fastapi import APIRouter, HTTPException
from ..schemas import ExpressionRequest, ExpressionResult
from ..sympy_engine import evaluate_expression

router = APIRouter()


@router.post("/evaluate", response_model=ExpressionResult)
async def evaluate(req: ExpressionRequest):
    try:
        return evaluate_expression(req.expression)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/validate")
async def validate(req: ExpressionRequest):
    try:
        evaluate_expression(req.expression)
        return {"valid": True}
    except Exception:
        return {"valid": False}
