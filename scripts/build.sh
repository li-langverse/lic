#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LLVM_DIR="${LLVM_DIR:-}"
if [[ -z "$LLVM_DIR" && -d /opt/homebrew/opt/llvm@18/lib/cmake/llvm ]]; then
  LLVM_DIR=/opt/homebrew/opt/llvm@18/lib/cmake/llvm
fi
if [[ -z "$LLVM_DIR" && -d /usr/lib/llvm-18/lib/cmake/llvm ]]; then
  LLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm
fi
if [[ -z "$LLVM_DIR" && -d "/c/Program Files/LLVM/lib/cmake/llvm" ]]; then
  LLVM_DIR="/c/Program Files/LLVM/lib/cmake/llvm"
fi
if [[ -z "$LLVM_DIR" ]]; then
  echo "Set LLVM_DIR to LLVM 18 CMake package (e.g. \$(brew --prefix llvm@18)/lib/cmake/llvm)" >&2
  exit 1
fi

# Parallel Ninja builds: override with LI_BUILD_JOBS=1 for deterministic logs.
li_build_jobs() {
  if [[ -n "${LI_BUILD_JOBS:-}" ]]; then
    echo "$LI_BUILD_JOBS"
    return
  fi
  if command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.ncpu 2>/dev/null || echo 4
  elif command -v nproc >/dev/null 2>&1; then
    nproc
  else
    echo 4
  fi
}

cmake -B "$ROOT/build" -G Ninja -DLLVM_DIR="$LLVM_DIR" "$@"
cmake --build "$ROOT/build" -j "$(li_build_jobs)" "$@"
