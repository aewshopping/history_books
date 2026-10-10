#!/usr/bin/env bash
# Build the database and start Datasette inside a GitHub Codespace.
# Usage: bash start-datasette.sh   (or ./start-datasette.sh)
set -euo pipefail

cd "$(dirname "$0")"

# Install into a local virtual environment so the sqlite-utils and datasette
# commands are guaranteed to be on PATH for the rest of this script.
if [ ! -d .venv ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
fi
source .venv/bin/activate

echo "Installing Python packages..."
pip install -q -r requirements.txt datasette-codespaces

echo "Building data.db..."
rm -f data.db
bash build-db.sh

# The data database requires an API token (see metadata.json). Use a local
# default unless one is already set, e.g. as a Codespaces secret.
export HISTORY_BOOKS_API_TOKEN="${HISTORY_BOOKS_API_TOKEN:-localdev}"
echo "API token for this session: append ?_auth_token=$HISTORY_BOOKS_API_TOKEN to URLs"

echo "Starting Datasette (Codespaces will offer to open the forwarded port)..."
exec datasette data.db -m metadata.json
