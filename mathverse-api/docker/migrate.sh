#!/bin/sh
set -e

echo "Running database migrations..."

for f in /app/migrations/*.sql; do
    echo "Applying migration: $f"
    psql "$DB_URL" -f "$f"
done

echo "Migrations complete."
