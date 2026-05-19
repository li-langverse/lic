#!/usr/bin/env bash
# PH-MMO-3 — start local MMO dependencies (Redis + Postgres).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
docker compose -f deploy/mmo/compose.yml up -d redis postgres
echo "mmo-dev: redis :6379 postgres :5432 (see deploy/mmo/README.md)"
