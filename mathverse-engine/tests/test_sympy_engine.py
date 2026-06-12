import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from engine.sympy_engine import (
    evaluate_expression,
    differentiate,
    integrate,
    evaluate_limit,
    taylor_series,
    dl_expansion,
    matrix_add,
    matrix_multiply,
    matrix_determinant,
    matrix_inverse,
    matrix_transpose,
    calculate_statistics,
    plot_function,
    safe_parse,
)
from engine.sandbox import ExpressionValidator, TimeoutError


class TestExpressionValidation:
    def test_valid_expression(self):
        result = evaluate_expression("2 + 2")
        assert result["numeric_value"] == 4.0

    def test_complex_expression(self):
        result = evaluate_expression("sin(pi/2)")
        assert abs(result["numeric_value"] - 1.0) < 0.001

    def test_empty_expression_raises(self):
        import pytest
        with pytest.raises(ValueError):
            evaluate_expression("")

    def test_blocked_keywords(self):
        import pytest
        with pytest.raises(ValueError):
            evaluate_expression("__import__('os')")

    def test_long_expression_raises(self):
        import pytest
        with pytest.raises(ValueError):
            evaluate_expression("x" * 20000)


class TestDifferentiation:
    def test_basic_derivative(self):
        result = differentiate("x**2")
        assert "2*x" in result["result"] or "2*x" in result["simplified_result"]

    def test_trig_derivative(self):
        result = differentiate("sin(x)")
        assert "cos" in result["result"]

    def test_higher_order(self):
        result = differentiate("x**3", order=2)
        assert "6*x" in result["result"] or "6*x" in result["simplified_result"]

    def test_multivariable(self):
        result = differentiate("y**2", variable="y")
        assert "2*y" in result["result"]

    def test_steps_included(self):
        result = differentiate("x**2")
        assert len(result["steps"]) > 0


class TestIntegration:
    def test_indefinite_integral(self):
        result = integrate("x**2")
        assert "x**3/3" in result["result"]

    def test_definite_integral(self):
        result = integrate("x", lower_bound="0", upper_bound="1")
        assert "1/2" in result["result"] or "0.5" in result["result"]

    def test_trig_integral(self):
        result = integrate("cos(x)")
        assert "sin" in result["result"]


class TestLimits:
    def test_basic_limit(self):
        result = evaluate_limit("sin(x)/x", approach_point="0")
        assert "1" in result["result"]

    def test_left_handed_limit(self):
        result = evaluate_limit("1/x", approach_point="0", direction="left")
        assert result  # should not raise


class TestTaylorSeries:
    def test_basic_expansion(self):
        result = taylor_series("exp(x)", order=3)
        assert "x**3" in result["result"]

    def test_terms_included(self):
        result = taylor_series("sin(x)", order=5)
        assert len(result["terms"]) > 0


class TestDLExpansion:
    def test_basic_dl(self):
        result = dl_expansion("exp(x)", order=3)
        assert "x**3" in result["result"]

    def test_remainder_included(self):
        result = dl_expansion("sin(x)", order=5)
        assert "remainder" in result


class TestMatrix:
    def test_add(self):
        result = matrix_add([[1, 2], [3, 4]], [[5, 6], [7, 8]])
        assert result["result"] == [[6, 8], [10, 12]]

    def test_multiply(self):
        result = matrix_multiply([[1, 2], [3, 4]], [[2, 0], [1, 2]])
        assert result["result"] == [[4, 4], [10, 8]]

    def test_determinant(self):
        result = matrix_determinant([[1, 2], [3, 4]])
        assert float(result["result"]) == -2.0

    def test_inverse(self):
        result = matrix_inverse([[4, 7], [2, 6]])
        assert len(result["result"]) == 2

    def test_transpose(self):
        result = matrix_transpose([[1, 2, 3], [4, 5, 6]])
        assert len(result["result"]) == 3
        assert len(result["result"][0]) == 2


class TestStatistics:
    def test_mean(self):
        result = calculate_statistics([1, 2, 3, 4, 5], "mean")
        assert "3.0" in result["result"]

    def test_median(self):
        result = calculate_statistics([1, 3, 3, 6, 7, 8, 9], "median")
        assert "6.0" in result["result"]

    def test_std(self):
        result = calculate_statistics([2, 4, 4, 4, 5, 5, 7, 9], "std")
        assert float(result["result"]) > 0

    def test_min(self):
        result = calculate_statistics([3, 1, 4, 1, 5, 9, 2], "min")
        assert "1" in result["result"]

    def test_max(self):
        result = calculate_statistics([3, 1, 4, 1, 5, 9, 2], "max")
        assert "9" in result["result"]


class TestGraph:
    def test_plot_points(self):
        result = plot_function("sin(x)", x_min=0, x_max=6.28, step=0.5)
        assert len(result["points"]) > 0

    def test_plot_metadata(self):
        result = plot_function("x**2", x_min=-5, x_max=5, step=1)
        assert result["result"] is not None


class TestSafety:
    def test_expression_validator(self):
        ExpressionValidator.validate("2+2")
        assert True

    def test_blocked_import(self):
        import pytest
        with pytest.raises(ValueError):
            ExpressionValidator.validate("__import__('os')")

    def test_blocked_eval(self):
        import pytest
        with pytest.raises(ValueError):
            ExpressionValidator.validate("eval('2+2')")
