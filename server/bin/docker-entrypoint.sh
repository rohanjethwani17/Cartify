#!/bin/bash
set -e

# Remove stale PID file
rm -f /app/tmp/pids/server.pid

# Wait for PostgreSQL
until pg_isready -h postgres -U cartify; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done

# Run migrations
echo "Running database migrations..."
./bin/rails db:prepare

# Start the server
echo "Starting Rails server..."
exec ./bin/rails server -b 0.0.0.0 -p 3000

