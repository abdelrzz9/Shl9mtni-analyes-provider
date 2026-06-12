# API Reference

## mathverse-api (Go/Gin)

Base URL: `http://localhost:8080`

### Health

| Method | Path      | Description       |
|--------|-----------|-------------------|
| GET    | `/health` | Service health    |

### Calculator

| Method | Path                            | Description  |
|--------|---------------------------------|--------------|
| POST   | `/api/v1/calculator/evaluate`   | Evaluate expression |
| POST   | `/api/v1/calculator/validate`   | Validate expression |

**Request (evaluate):**
```json
{"expression": "2 + 2"}
```

**Response:**
```json
{"result": 4.0, "latex_output": "4"}
```

### Derivatives

| Method | Path                                    | Description    |
|--------|-----------------------------------------|----------------|
| POST   | `/api/v1/derivatives/differentiate`     | Differentiate  |

**Request:**
```json
{"function": "x**2", "variable": "x", "order": 1}
```

**Response:**
```json
{"result": "2*x", "steps": "...", "latex_output": "..."}
```

### Integrals

| Method | Path                              | Description |
|--------|-----------------------------------|-------------|
| POST   | `/api/v1/integrals/integrate`     | Integrate   |

**Request (indefinite):**
```json
{"function": "x**2", "variable": "x"}
```

**Request (definite):**
```json
{"function": "x**2", "variable": "x", "lower_bound": "0", "upper_bound": "1"}
```

### Limits

| Method | Path                          | Description |
|--------|-------------------------------|-------------|
| POST   | `/api/v1/limits/evaluate`     | Evaluate limit |

**Request:**
```json
{"function": "sin(x)/x", "variable": "x", "approach_point": "0", "direction": "+"}
```

### Taylor Series

| Method | Path                          | Description |
|--------|-------------------------------|-------------|
| POST   | `/api/v1/taylor/expand`       | Expand series |

**Request:**
```json
{"function": "exp(x)", "variable": "x", "center": "0", "order": 5}
```

### Matrix

| Method | Path                              | Description  |
|--------|-----------------------------------|--------------|
| POST   | `/api/v1/matrix/add`              | Add matrices |
| POST   | `/api/v1/matrix/multiply`         | Multiply     |
| POST   | `/api/v1/matrix/determinant`      | Determinant  |
| POST   | `/api/v1/matrix/inverse`          | Inverse      |
| POST   | `/api/v1/matrix/transpose`        | Transpose    |

**Request:**
```json
{"matrix": "[[1,2],[3,4]]", "matrix_b": "[[5,6],[7,8]]"}
```

### Statistics

| Method | Path                                | Description |
|--------|-------------------------------------|-------------|
| POST   | `/api/v1/statistics/calculate`      | Calculate   |

**Request:**
```json
{"data": [1, 2, 3, 4, 5], "operation": "mean"}
```

Operations: `mean`, `median`, `mode`, `std_dev`, `variance`, `correlation`

### Graph

| Method | Path                       | Description |
|--------|----------------------------|-------------|
| POST   | `/api/v1/graph/plot`       | Plot function |

**Request:**
```json
{"function": "sin(x)", "x_min": -10, "x_max": 10, "step": 0.1}
```

### History

| Method | Path                            | Description       |
|--------|---------------------------------|-------------------|
| GET    | `/api/v1/history`               | List history      |
| POST   | `/api/v1/history`               | Add entry         |
| DELETE | `/api/v1/history/clear`         | Clear all         |
| DELETE | `/api/v1/history/:id`           | Delete entry      |
| POST   | `/api/v1/history/:id/favorite`  | Toggle favorite   |

---

## mathverse-engine (Python/FastAPI)

Base URL: `http://localhost:8000`

### Health

| Method | Path      | Description       |
|--------|-----------|-------------------|
| GET    | `/health` | Service health    |

### Math Endpoints

All under `/api/v1/` — mirrors the Go API endpoints exactly:

| Group        | Endpoint              | Methods |
|--------------|-----------------------|---------|
| calculator   | `/calculator/evaluate`| POST    |
|              | `/calculator/validate`| POST    |
| derivatives  | `/derivatives/differentiate` | POST |
| integrals    | `/integrals/integrate`| POST    |
| limits       | `/limits/evaluate`    | POST    |
| taylor       | `/taylor/expand`      | POST    |
| matrix       | `/matrix/add`         | POST    |
|              | `/matrix/multiply`    | POST    |
|              | `/matrix/determinant` | POST    |
|              | `/matrix/inverse`     | POST    |
|              | `/matrix/transpose`   | POST    |
| statistics   | `/statistics/calculate`| POST    |
| graph        | `/graph/plot`         | POST    |

All responses follow this pattern:
```json
{
  "result": "...",
  "simplified_result": "...",
  "steps": "...",
  "latex_output": "..."
}
```
