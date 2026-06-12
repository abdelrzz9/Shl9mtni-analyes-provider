# mathverse-engine

Python/FastAPI symbolic mathematics engine powered by SymPy and NumPy.

## Development

```bash
pip install -r requirements.txt
uvicorn engine.main:app --reload --port 8000
```

## Endpoints

All under `/api/v1/`:

| Router      | Operations                                    |
|-------------|-----------------------------------------------|
| calculator  | evaluate, validate                            |
| derivatives | differentiate                                 |
| integrals   | integrate                                     |
| limits      | evaluate limit                                |
| taylor      | expand series                                 |
| matrix      | add, multiply, determinant, inverse, transpose |
| statistics  | mean, median, mode, std_dev, variance, correlation |
| graph       | plot function                                 |

See `../docs/api-reference.md` for request/response schemas.
