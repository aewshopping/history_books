#!/usr/bin/env bash
# Build the database and start Datasette inside a GitHub Codespace.
# Usage: bash start-datasette.sh   (or ./start-datasette.sh)
set -euo pipefail

cd "$(dirname "$0")"

echo "Installing Python packages..."
pip install -q -r requirements.txt datasette-codespaces

echo "Building data.db..."
rm -f data.db
bash build-db.sh

echo "Starting Datasette (Codespaces will offer to open the forwarded port)..."
exec datasette data.db -m metadata.json
