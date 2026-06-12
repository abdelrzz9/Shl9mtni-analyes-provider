from pydantic import BaseModel
from typing import Optional


class ExpressionRequest(BaseModel):
    expression: str


class ExpressionResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str] = []
    latex_output: str


class DerivativeRequest(BaseModel):
    function: str
    variable: str = "x"
    order: int = 1


class IntegralRequest(BaseModel):
    function: str
    variable: str = "x"
    lower_bound: Optional[str] = None
    upper_bound: Optional[str] = None


class LimitRequest(BaseModel):
    function: str
    variable: str = "x"
    approach_point: str = "0"
    direction: Optional[str] = None


class TaylorRequest(BaseModel):
    function: str
    variable: str = "x"
    center: str = "0"
    order: int = 5


class MatrixRequest(BaseModel):
    matrix: list[list[float]]
    matrix_b: Optional[list[list[float]]] = None


class StatisticsRequest(BaseModel):
    data: list[float]
    data2: Optional[list[float]] = None
    operation: str


class GraphRequest(BaseModel):
    function: str
    variable: str = "x"
    x_min: float = -10
    x_max: float = 10
    step: float = 0.1
