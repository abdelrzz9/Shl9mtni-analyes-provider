import sympy as sp
from sympy.parsing.sympy_parser import parse_expr, standard_transformations, implicit_multiplication_application
import numpy as np
from typing import Optional


transformations = (
    standard_transformations + (implicit_multiplication_application,)
)


def safe_parse(expression: str) -> sp.Expr:
    expr_clean = expression.replace("inf", "oo").replace("infinity", "oo").replace("-oo", "-oo")
    return parse_expr(expr_clean, transformations=transformations)


def to_latex(expr: sp.Expr) -> str:
    return sp.latex(expr)


def differentiate(function: str, variable: str = "x", order: int = 1) -> dict:
    x = sp.symbols(variable)
    expr = safe_parse(function)
    steps = []
    result = expr
    for i in range(order):
        steps.append(f"Step {i + 1}: Differentiate {to_latex(result)}")
        result = sp.diff(result, x)
    simplified = sp.simplify(result)
    steps.append(f"Simplified: {to_latex(simplified)}")
    return {
        "result": str(result),
        "simplified_result": str(simplified),
        "steps": steps,
        "latex_output": to_latex(simplified),
    }


def integrate(function: str, variable: str = "x",
              lower_bound: Optional[str] = None,
              upper_bound: Optional[str] = None) -> dict:
    x = sp.symbols(variable)
    expr = safe_parse(function)
    steps = [f"Integrate {to_latex(expr)} with respect to {variable}"]
    if lower_bound is not None and upper_bound is not None:
        a = safe_parse(lower_bound)
        b = safe_parse(upper_bound)
        result = sp.integrate(expr, (x, a, b))
        steps.append(f"Definite integral from {lower_bound} to {upper_bound}")
    else:
        result = sp.integrate(expr, x)
    simplified = sp.simplify(result)
    steps.append(f"Result: {to_latex(simplified)}")
    return {
        "result": str(result),
        "simplified_result": str(simplified),
        "steps": steps,
        "latex_output": to_latex(simplified),
    }


def evaluate_limit(function: str, variable: str = "x",
                    approach_point: str = "0",
                    direction: Optional[str] = None) -> dict:
    x = sp.symbols(variable)
    expr = safe_parse(function)
    point = safe_parse(approach_point)
    steps = [f"Evaluate limit of {to_latex(expr)} as {variable} -> {approach_point}"]
    if direction == "right":
        result = sp.limit(expr, x, point, dir="+")
        steps.append("Right-handed limit (from above)")
    elif direction == "left":
        result = sp.limit(expr, x, point, dir="-")
        steps.append("Left-handed limit (from below)")
    else:
        result = sp.limit(expr, x, point)
    steps.append(f"Result: {to_latex(result)}")
    return {
        "result": str(result),
        "simplified_result": str(sp.simplify(result)),
        "steps": steps,
        "latex_output": to_latex(result),
    }


def taylor_series(function: str, variable: str = "x",
                  center: str = "0", order: int = 5) -> dict:
    x = sp.symbols(variable)
    expr = safe_parse(function)
    c = safe_parse(center)
    steps = [f"Expand {to_latex(expr)} around {variable}={center} to order {order}"]
    series = sp.series(expr, x, c, order + 1).removeO()
    steps.append(f"Series: {to_latex(series)}")
    terms = [str(term) for term in series.as_ordered_terms()]
    return {
        "result": str(series),
        "simplified_result": str(sp.simplify(series)),
        "steps": steps,
        "latex_output": to_latex(series),
        "terms": terms,
    }


def matrix_add(matrix_a: list[list[float]], matrix_b: list[list[float]]) -> dict:
    a = sp.Matrix(matrix_a)
    b = sp.Matrix(matrix_b)
    result = a + b
    return {
        "result": result.tolist(),
        "simplified_result": str(result),
        "steps": ["Matrix addition performed element-wise"],
        "latex_output": sp.latex(result),
    }


def matrix_multiply(matrix_a: list[list[float]], matrix_b: list[list[float]]) -> dict:
    a = sp.Matrix(matrix_a)
    b = sp.Matrix(matrix_b)
    result = a * b
    return {
        "result": result.tolist(),
        "simplified_result": str(result),
        "steps": ["Matrix multiplication performed"],
        "latex_output": sp.latex(result),
    }


def matrix_determinant(matrix: list[list[float]]) -> dict:
    m = sp.Matrix(matrix)
    result = m.det()
    return {
        "result": str(result),
        "simplified_result": str(sp.simplify(result)),
        "steps": ["Determinant computed"],
        "latex_output": sp.latex(result),
    }


def matrix_inverse(matrix: list[list[float]]) -> dict:
    m = sp.Matrix(matrix)
    result = m.inv()
    return {
        "result": result.tolist(),
        "simplified_result": str(result),
        "steps": ["Matrix inverse computed"],
        "latex_output": sp.latex(result),
    }


def matrix_transpose(matrix: list[list[float]]) -> dict:
    m = sp.Matrix(matrix)
    result = m.T
    return {
        "result": result.tolist(),
        "simplified_result": str(result),
        "steps": ["Matrix transposed"],
        "latex_output": sp.latex(result),
    }


def calculate_statistics(data: list[float],
                          operation: str,
                          data2: Optional[list[float]] = None) -> dict:
    arr = np.array(data)
    steps = [f"Operation: {operation}"]
    result = None

    if operation == "mean":
        result = float(np.mean(arr))
        steps.append(f"Mean = {result}")
    elif operation == "median":
        result = float(np.median(arr))
        steps.append(f"Median = {result}")
    elif operation == "mode":
        values, counts = np.unique(arr, return_counts=True)
        max_count = np.max(counts)
        modes = values[counts == max_count].tolist()
        result = modes
        steps.append(f"Mode(s) = {result}")
    elif operation == "std":
        result = float(np.std(arr, ddof=1))
        steps.append(f"Standard deviation = {result}")
    elif operation == "variance":
        result = float(np.var(arr, ddof=1))
        steps.append(f"Variance = {result}")
    elif operation == "min":
        result = float(np.min(arr))
        steps.append(f"Min = {result}")
    elif operation == "max":
        result = float(np.max(arr))
        steps.append(f"Max = {result}")
    elif operation == "sum":
        result = float(np.sum(arr))
        steps.append(f"Sum = {result}")
    elif operation == "correlation" and data2 is not None:
        arr2 = np.array(data2)
        result = float(np.corrcoef(arr, arr2)[0, 1])
        steps.append(f"Correlation = {result}")
    elif operation == "covariance" and data2 is not None:
        arr2 = np.array(data2)
        result = float(np.cov(arr, arr2, ddof=1)[0, 1])
        steps.append(f"Covariance = {result}")
    else:
        raise ValueError(f"Unknown operation: {operation}")

    return {
        "result": str(result),
        "simplified_result": str(result),
        "steps": steps,
        "latex_output": str(result),
        "details": {
            "count": len(data),
            "operation": operation,
        },
    }


def plot_function(function: str, variable: str = "x",
                  x_min: float = -10, x_max: float = 10,
                  step: float = 0.1) -> dict:
    x = sp.symbols(variable)
    expr = safe_parse(function)
    f = sp.lambdify(x, expr, "numpy")
    x_vals = np.arange(x_min, x_max + step, step)
    y_vals = f(x_vals)
    # Replace inf/nan with None
    y_vals = [float(y) if np.isfinite(y) else None for y in y_vals]
    points = [
        {"x": float(x_val), "y": y_val}
        for x_val, y_val in zip(x_vals, y_vals)
        if y_val is not None
    ]
    return {
        "result": f"Generated {len(points)} points",
        "simplified_result": str(len(points)),
        "steps": [f"Generated {len(points)} points from x={x_min} to x={x_max}"],
        "latex_output": sp.latex(expr),
        "points": points,
    }


def evaluate_expression(expression: str) -> dict:
    expr = safe_parse(expression)
    simplified = sp.simplify(expr)
    numeric = None
    try:
        numeric = float(expr.evalf())
    except (TypeError, ValueError):
        pass
    result = {
        "result": str(expr),
        "simplified_result": str(simplified),
        "steps": [f"Parsed: {to_latex(expr)}", f"Simplified: {to_latex(simplified)}"],
        "latex_output": to_latex(simplified),
    }
    if numeric is not None:
        result["numeric_value"] = numeric
    return result
