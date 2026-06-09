#!/usr/bin/env bash
# Reconcile logic smoke test for swarm-gap-ingest.py
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$ROOT/scripts/swarm-gap-ingest.py" --self-test
python3 "$ROOT/scripts/swarm-gap-ingest.py" --dry-run >/dev/null
echo "check-swarm-gap-ingest: OK"
