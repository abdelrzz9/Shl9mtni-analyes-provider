from fastapi.testclient import TestClient

from engine.main import app

client = TestClient(app)


class TestHealth:
    def test_health_endpoint(self):
        response = client.get("/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "ok"
        assert "version" in data

    def test_health_method_not_allowed(self):
        response = client.post("/health")
        assert response.status_code == 405


class TestCalculator:
    def test_evaluate_simple(self):
        response = client.post("/api/v1/calculator/evaluate", json={"expression": "2 + 2"})
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == "4"

    def test_evaluate_trig(self):
        response = client.post("/api/v1/calculator/evaluate", json={"expression": "sin(pi/2)"})
        assert response.status_code == 200
        data = response.json()
        assert abs(float(data["numeric_value"]) - 1.0) < 0.001

    def test_evaluate_empty_expression(self):
        response = client.post("/api/v1/calculator/evaluate", json={"expression": ""})
        assert response.status_code == 422

    def test_evaluate_blocked_keyword(self):
        response = client.post("/api/v1/calculator/evaluate", json={"expression": "__import__('os')"})
        assert response.status_code == 400

    def test_validate_valid(self):
        response = client.post("/api/v1/calculator/validate", json={"expression": "x**2 + 1"})
        assert response.status_code == 200
        assert response.json()["valid"] is True

    def test_validate_invalid(self):
        response = client.post("/api/v1/calculator/validate", json={"expression": "@@@@"})
        assert response.status_code == 200
        assert response.json()["valid"] is False


class TestDerivatives:
    def test_differentiate_simple(self):
        response = client.post("/api/v1/derivatives/differentiate", json={
            "function": "x**2", "variable": "x", "order": 1
        })
        assert response.status_code == 200
        data = response.json()
        assert "2*x" in data["result"]

    def test_differentiate_invalid_function(self):
        response = client.post("/api/v1/derivatives/differentiate", json={
            "function": "", "variable": "x", "order": 1
        })
        assert response.status_code == 422


class TestIntegrals:
    def test_integrate_indefinite(self):
        response = client.post("/api/v1/integrals/integrate", json={
            "function": "x", "variable": "x"
        })
        assert response.status_code == 200
        data = response.json()
        assert "x**2" in data["result"] or "x^2" in data["result"]

    def test_integrate_definite(self):
        response = client.post("/api/v1/integrals/integrate", json={
            "function": "x", "variable": "x",
            "lower_bound": "0", "upper_bound": "1"
        })
        assert response.status_code == 200
        data = response.json()
        assert "1/2" in data["result"] or "0.5" in data["result"]

    def test_integrate_invalid(self):
        response = client.post("/api/v1/integrals/integrate", json={
            "function": "", "variable": "x"
        })
        assert response.status_code == 422


class TestLimits:
    def test_limit_simple(self):
        response = client.post("/api/v1/limits/evaluate", json={
            "function": "1/x", "variable": "x", "approach_point": "oo"
        })
        assert response.status_code == 200
        data = response.json()
        assert "0" in data["result"]

    def test_limit_invalid_function(self):
        response = client.post("/api/v1/limits/evaluate", json={
            "function": "", "variable": "x", "approach_point": "0"
        })
        assert response.status_code == 422


class TestTaylor:
    def test_taylor_simple(self):
        response = client.post("/api/v1/taylor/expand", json={
            "function": "sin(x)", "variable": "x", "center": "0", "order": 3
        })
        assert response.status_code == 200
        data = response.json()
        assert "x" in data["result"]

    def test_taylor_invalid_function(self):
        response = client.post("/api/v1/taylor/expand", json={
            "function": "", "variable": "x", "center": "0", "order": 3
        })
        assert response.status_code == 422


class TestDL:
    def test_dl_simple(self):
        response = client.post("/api/v1/dl/expand", json={
            "function": "sin(x)", "variable": "x", "point": "0", "order": 3
        })
        assert response.status_code == 200
        data = response.json()
        assert "x" in data["result"]

    def test_dl_invalid_function(self):
        response = client.post("/api/v1/dl/expand", json={
            "function": "", "variable": "x", "point": "0", "order": 3
        })
        assert response.status_code == 422


class TestMatrix:
    def test_matrix_add(self):
        response = client.post("/api/v1/matrix/add", json={
            "matrix": [[1, 2], [3, 4]],
            "matrix_b": [[5, 6], [7, 8]]
        })
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == [[6, 8], [10, 12]]

    def test_matrix_multiply(self):
        response = client.post("/api/v1/matrix/multiply", json={
            "matrix": [[1, 2], [3, 4]],
            "matrix_b": [[2, 0], [1, 2]]
        })
        assert response.status_code == 200
        data = response.json()
        assert data["result"] == [[4, 4], [10, 8]]

    def test_matrix_determinant(self):
        response = client.post("/api/v1/matrix/determinant", json={
            "matrix": [[1, 2], [3, 4]]
        })
        assert response.status_code == 200
        data = response.json()
        assert float(data["result"]) == -2.0

    def test_matrix_inverse(self):
        response = client.post("/api/v1/matrix/inverse", json={
            "matrix": [[4, 7], [2, 6]]
        })
        assert response.status_code == 200
        data = response.json()
        assert abs(data["result"][0][0] - 0.6) < 0.01

    def test_matrix_transpose(self):
        response = client.post("/api/v1/matrix/transpose", json={
            "matrix": [[1, 2, 3], [4, 5, 6]]
        })
        assert response.status_code == 200
        data = response.json()
        assert len(data["result"]) == 3
        assert len(data["result"][0]) == 2


class TestStatistics:
    def test_statistics_mean(self):
        response = client.post("/api/v1/statistics/calculate", json={
            "data": [1, 2, 3, 4, 5],
            "operation": "mean"
        })
        assert response.status_code == 200
        data = response.json()
        assert float(data["result"]) == 3.0

    def test_statistics_median(self):
        response = client.post("/api/v1/statistics/calculate", json={
            "data": [1, 3, 3, 6, 7, 8, 9],
            "operation": "median"
        })
        assert response.status_code == 200
        data = response.json()
        assert float(data["result"]) == 6.0

    def test_statistics_std(self):
        response = client.post("/api/v1/statistics/calculate", json={
            "data": [2, 4, 4, 4, 5, 5, 7, 9],
            "operation": "std"
        })
        assert response.status_code == 200
        data = response.json()
        assert float(data["result"]) > 0

    def test_statistics_invalid_operation(self):
        response = client.post("/api/v1/statistics/calculate", json={
            "data": [1, 2, 3],
            "operation": "invalid"
        })
        assert response.status_code == 422


class TestGraph:
    def test_graph_simple(self):
        response = client.post("/api/v1/graph/plot", json={
            "function": "x", "x_min": -10, "x_max": 10
        })
        assert response.status_code == 200
        data = response.json()
        assert len(data["points"]) > 0

    def test_graph_invalid_function(self):
        response = client.post("/api/v1/graph/plot", json={
            "function": "", "x_min": -10, "x_max": 10
        })
        assert response.status_code == 422


class TestGlobalErrorHandling:
    def test_nonexistent_route(self):
        response = client.get("/api/v1/nonexistent")
        assert response.status_code == 404

    def test_invalid_json(self):
        response = client.post(
            "/api/v1/calculator/evaluate",
            data="not json",
            headers={"Content-Type": "application/json"},
        )
        assert response.status_code == 422
