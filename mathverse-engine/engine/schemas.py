from pydantic import BaseModel, Field
from typing import Optional


class ExpressionRequest(BaseModel):
    expression: str = Field(..., min_length=1, max_length=10000)


class ExpressionResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str] = []
    latex_output: str
    numeric_value: Optional[float] = None


class DerivativeRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    order: int = Field(default=1, ge=1, le=100)


class DerivativeResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str


class IntegralRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    lower_bound: Optional[str] = None
    upper_bound: Optional[str] = None


class IntegralResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str


class LimitRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    approach_point: str = "0"
    direction: Optional[str] = None


class LimitResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str


class TaylorRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    center: str = "0"
    order: int = Field(default=5, ge=1, le=50)


class TaylorResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str
    terms: list[str] = []


class DLRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    point: str = "0"
    order: int = Field(default=5, ge=1, le=50)


class DLResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str
    terms: list[str]
    remainder: str
    order: int


class MatrixRequest(BaseModel):
    matrix: list[list[float]]
    matrix_b: Optional[list[list[float]]] = None


class MatrixResult(BaseModel):
    result: list[list[float]] | str
    simplified_result: str
    steps: list[str]
    latex_output: str


class StatisticsRequest(BaseModel):
    data: list[float]
    data2: Optional[list[float]] = None
    operation: str = Field(..., pattern=r"^(mean|median|mode|std|variance|min|max|sum|correlation|covariance)$")


class StatisticsResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str
    details: dict


class GraphRequest(BaseModel):
    function: str = Field(..., min_length=1, max_length=10000)
    variable: str = "x"
    x_min: float = -10
    x_max: float = 10
    step: float = Field(default=0.1, gt=0)


class GraphResult(BaseModel):
    result: str
    simplified_result: str
    steps: list[str]
    latex_output: str
    points: list[dict]


class ValidateResult(BaseModel):
    valid: bool


class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None
