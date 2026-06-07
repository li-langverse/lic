#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/scripts/libernetes-doctor.sh"
bash "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes control completion gate: OK"
