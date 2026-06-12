# mathverse-api

Go/Gin API gateway for MathVerse. Authenticates requests and delegates computation to the Python engine.

## Development

```bash
go run ./cmd/server
```

Requires `MATH_ENGINE_URL` env var (default: `http://localhost:8000`).

## Build

```bash
go build -o server ./cmd/server
```

## Architecture

- **internal/config/** — Environment-based configuration
- **internal/middleware/** — JWT auth, CORS
- **internal/module/** — Feature modules (handler + usecase per feature)
- **internal/pkg/mathclient/** — Shared HTTP client to Python engine
- **internal/router/** — Route wiring

See `../docs/architecture.md` for the full system architecture.
