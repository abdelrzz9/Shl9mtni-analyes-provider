FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /server ./cmd/server

FROM alpine:3.20 AS migrations
RUN apk --no-cache add postgresql-client
WORKDIR /app
COPY migrations/ ./migrations/
COPY docker/migrate.sh ./migrate.sh
RUN chmod +x ./migrate.sh

FROM alpine:3.20
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /server .
COPY --from=migrations /app/migrations ./migrations
COPY --from=migrations /app/migrate.sh ./migrate.sh
EXPOSE 8080
CMD ["./server"]
