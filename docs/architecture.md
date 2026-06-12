# MathVerse Architecture

## Overview

MathVerse is a three-tier symbolic mathematics application:

```
Flutter Web App          Go/Gin API              Python/FastAPI Engine
(mathverse-flutter) --> (mathverse-api) -------> (mathverse-engine)
   Port 3000               Port 8080                 Port 8000
                     Auth + Validation          SymPy / NumPy
```

Each service runs in its own Docker container on a shared bridge network (`mathverse-network`).

## Data Flow

1. User interacts with the Flutter web UI
2. Flutter BLoCs call repositories that send HTTP requests to the Go API via Dio
3. Go API authenticates (JWT), validates input, then delegates computation to the Python engine via `mathclient.Client`
4. Python engine performs symbolic math with SymPy (or NumPy for statistics) and returns results as JSON
5. Response flows back: Python -> Go -> Flutter -> BLoC state -> UI

## Services

### mathverse-flutter

- **Framework**: Flutter web
- **State management**: BLoC
- **Architecture**: Clean Architecture (data/repository -> domain/usecase -> presentation/bloc/page)
- **DI**: GetIt service locator
- **HTTP**: Dio client configured via `AppConfig.apiBaseUrl`
- **Routing**: go_router with 14 routes
- **Port**: 3000 (served via nginx)

### mathverse-api

- **Framework**: Go with Gin
- **Architecture**: Handler -> Usecase -> MathClient
- **Auth**: JWT Bearer token middleware
- **CORS**: Enabled for all origins
- **Port**: 8080

All computation usecases forward requests to the Python engine via `mathclient.Client.Post()`. The history module is the only exception — it uses an in-memory store locally.

### mathverse-engine

- **Framework**: Python with FastAPI
- **Libraries**: SymPy (symbolic math), NumPy (statistics), SciPy
- **Port**: 8000

Performs all mathematical computation. Each operation returns `result`, `simplified_result`, `steps`, and `latex_output`.

## Project Structure

```
math_app/
├── mathverse-flutter/       # Flutter web app (BLoC, Clean Architecture)
│   ├── lib/
│   │   ├── core/            # Network, routing, theme, DI
│   │   ├── features/        # Feature modules (BLoC pattern)
│   │   │   └── {feature}/
│   │   │       ├── data/    # Repository implementations (ApiClient calls)
│   │   │       ├── domain/  # Entities, repositories (abstract), usecases
│   │   │       └── presentation/  # BLoCs, pages
│   │   └── di/              # GetIt injection container
│   ├── Dockerfile
│   ├── nginx.conf
│   └── test/
├── mathverse-api/           # Go/Gin API gateway
│   ├── cmd/server/          # Entry point
│   ├── internal/
│   │   ├── config/          # Environment config
│   │   ├── middleware/      # Auth, CORS
│   │   ├── module/          # Feature modules
│   │   │   └── {module}/
│   │   │       ├── handler/ # HTTP handlers
│   │   │       └── usecase/ # Business logic -> MathClient calls
│   │   ├── pkg/mathclient/  # Shared HTTP client to Python engine
│   │   └── router/          # Route setup
│   └── Dockerfile
├── mathverse-engine/        # Python/FastAPI symbolic engine
│   └── engine/
│       ├── main.py          # FastAPI app
│       ├── routers/         # API route handlers
│       ├── sympy_engine.py  # SymPy computation functions
│       └── schemas.py       # Pydantic request/response models
├── docker-compose.yml
└── docs/
    ├── architecture.md
    └── api-reference.md
```

## Key Conventions

- **No local computation** — Flutter calls Go API; Go API calls Python engine.
- **Feature-first** — Each feature (calculator, derivatives, etc.) is a self-contained module in all 3 services.
- **Dependency injection** — Repositories receive `ApiClient` via constructor; GetIt provides defaults.
- **JWT auth** — Enforced on all endpoints except `/health` and calculator routes.
