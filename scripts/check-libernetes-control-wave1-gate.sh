#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/scripts/libernetes-init.sh"
test -f "$ROOT/scripts/libernetes-worker-join.sh"
test -f "$ROOT/docs/libernetes/join-flow.md"
bash "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes control wave1 gate: OK"
