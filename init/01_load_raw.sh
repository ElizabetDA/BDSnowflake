#!/usr/bin/env bash
set -e

for file in /workspace/data/*.csv; do
  echo "Loading $file"
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
\copy staging.mock_data FROM '$file' WITH (FORMAT csv, HEADER true)
SQL
done
