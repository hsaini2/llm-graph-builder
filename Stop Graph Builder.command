#!/bin/zsh
# Stops the LLM Graph Builder backend and frontend.
# Neo4j and Docker Desktop are left running (quit Docker from its menu-bar icon if you like).

export PATH="$HOME/.docker/bin:/usr/local/bin:$PATH"

echo "Stopping backend..."
docker stop llm-graph-builder-backend >/dev/null 2>&1 && echo "     stopped" || echo "     was not running"

echo "Stopping frontend..."
pkill -f "vite --host 127.0.0.1 --port 8080" && echo "     stopped" || echo "     was not running"

echo "Done."
