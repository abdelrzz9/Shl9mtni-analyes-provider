FROM golang:1.24-alpine AS backend-builder
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM python:3.14-slim AS math-engine
WORKDIR /app
COPY services/math-engine/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY services/math-engine/ .
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

FROM golang:1.24-alpine AS backend
WORKDIR /app
COPY --from=backend-builder /server .
EXPOSE 8080
CMD ["./server"]
