#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for f in architecture.md easy-setup.md heterogeneous-workers.md package-gap-register.md master-plan.md; do
  test -f "$ROOT/docs/libernetes/$f" || { echo "missing docs/libernetes/$f" >&2; exit 1; }
done
echo "libernetes platform docs gate: OK"
