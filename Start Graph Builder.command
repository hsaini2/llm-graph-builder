#!/bin/zsh
# Starts every part of LLM Graph Builder, then opens it in your browser.
# Double-click this file in Finder (or run it in Terminal).

PROJECT="$HOME/llm-graph-builder"
export PATH="$HOME/.docker/bin:/usr/local/bin:$PATH"

echo "1/4  Neo4j database..."
if lsof -iTCP:7687 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "     already running"
else
  brew services start neo4j >/dev/null
  for i in {1..45}; do lsof -iTCP:7687 -sTCP:LISTEN >/dev/null 2>&1 && break; sleep 2; done
  echo "     started"
fi

echo "2/4  Docker Desktop..."
if ! docker info >/dev/null 2>&1; then
  open -a Docker
  for i in {1..90}; do docker info >/dev/null 2>&1 && break; sleep 2; done
fi
docker info >/dev/null 2>&1 && echo "     running" || { echo "     Docker did not start - open Docker from Applications and try again."; exit 1; }

echo "3/4  Backend (in Docker)..."
docker start llm-graph-builder-backend >/dev/null
for i in {1..60}; do curl -s -o /dev/null http://localhost:8000/docs && break; sleep 2; done
echo "     running at http://localhost:8000"

echo "4/4  Frontend..."
if curl -s -o /dev/null http://127.0.0.1:8080; then
  echo "     already running"
else
  cd "$PROJECT/frontend"
  nohup npx vite --host 127.0.0.1 --port 8080 --strictPort > "$PROJECT/frontend-dev.log" 2>&1 &
  disown
  for i in {1..30}; do curl -s -o /dev/null http://127.0.0.1:8080 && break; sleep 1; done
  echo "     started"
fi

echo ""
echo "All set - opening http://localhost:8080"
open "http://localhost:8080"
