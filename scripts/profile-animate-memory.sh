#!/usr/bin/env bash
# Peak memory for animate_md.py (tracemalloc + optional /usr/bin/time -l).
#
# animate_md.py streams trajectories; matplotlib 3D GIFs remain RAM-heavy.
# Usage: ./scripts/profile-animate-memory.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HARNESS="$ROOT/benchmarks/harness/animate_md.py"
HARNESS_DIR="$ROOT/benchmarks/harness"

echo "==> tracemalloc peak (import animate_md)"
python3 - "$HARNESS_DIR" <<'PY'
import sys
import tracemalloc
from pathlib import Path

sys.path.insert(0, sys.argv[1])
tracemalloc.start()
import animate_md  # noqa: F401
_, peak = tracemalloc.get_traced_memory()
tracemalloc.stop()
print(f"    tracemalloc peak (import): {peak / 1048576:.2f} MiB")
PY

if [[ "$(uname -s)" == "Darwin" ]] && [[ -x /usr/bin/time ]]; then
  echo "==> /usr/bin/time -l (animate_md --skip-export --max-frames 4)"
  if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
    /usr/bin/time -l python3 "$HARNESS" \
      --skip-export --max-frames 4 --lang cpp 2>&1 | awk \
      '/maximum resident set size/ { printf "    peak RSS: %d bytes (%.2f MiB)\n", $1, $1/1048576 }' || true
  else
    echo "    skip run (lic not built)"
  fi
fi

echo "profile-animate-memory: ok"
