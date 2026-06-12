# MathVerse

A three-tier symbolic mathematics application: Flutter web frontend, Go/Gin API gateway, and Python/FastAPI engine (SymPy).

## Services

| Service             | Port | Tech Stack               |
|---------------------|------|--------------------------|
| mathverse-flutter   | 3000 | Flutter web, BLoC, Dio  |
| mathverse-api       | 8080 | Go, Gin, JWT             |
| mathverse-engine    | 8000 | Python, FastAPI, SymPy   |

## Quick Start

```bash
# Start all services
docker compose up --build

# Open http://localhost:3000
```

See `docs/architecture.md` for detailed architecture and `docs/api-reference.md` for API docs.

## Project Structure

```
math_app/
├── mathverse-flutter/    # Flutter web app
├── mathverse-api/        # Go API gateway
├── mathverse-engine/     # Python symbolic engine
├── docs/                 # Documentation
└── docker-compose.yml    # Service orchestration
```
