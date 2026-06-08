#!/usr/bin/env bash
# REQ-par-occupancy-001 — hybrid MPI×threads oversubscription diagnostic (lic#129 Phase 1).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
if [[ ! -x "$LIC" ]]; then
  echo "execution_occupancy/smoke: skip (no lic)" >&2
  exit 0
fi

fail() {
  echo "execution_occupancy/smoke: $*" >&2
  exit 1
}

HOST_CORES="$(sysctl -n hw.logicalcpu 2>/dev/null || nproc 2>/dev/null || echo 1)"
if [[ "$HOST_CORES" -lt 1 ]]; then
  HOST_CORES=1
fi

WORK="$ROOT/build/li-test-execution-occupancy-$$"
trap 'rm -rf "$WORK"' EXIT
mkdir -p "$WORK"

PROBE="$ROOT/li-tests/execution_occupancy/parallel_disjoint_ok.li"
BIN="$WORK/occupancy_probe"

"$LIC" build --release --threads="$HOST_CORES" "$PROBE" -o "$BIN" >/dev/null \
  || fail "build occupancy probe"

warn="$(mktemp)"
nowarn="$(mktemp)"
disabled="$(mktemp)"

OMPI_COMM_WORLD_SIZE=2 "$BIN" >/dev/null 2>"$warn" || fail "run with OMPI_COMM_WORLD_SIZE=2"
grep -q 'exceeds physical cores' "$warn" \
  || fail "expected occupancy warning with OMPI_COMM_WORLD_SIZE=2"

"$BIN" >/dev/null 2>"$nowarn" || fail "run without MPI env"
if grep -q 'exceeds physical cores' "$nowarn"; then
  fail "unexpected occupancy warning without MPI oversubscribe"
fi

LI_EXEC_WARN_OVERSUBSCRIBE=0 OMPI_COMM_WORLD_SIZE=2 "$BIN" >/dev/null 2>"$disabled" \
  || fail "run with warn disabled"
if grep -q 'exceeds physical cores' "$disabled"; then
  fail "occupancy warning should respect LI_EXEC_WARN_OVERSUBSCRIBE=0"
fi

PMI_SIZE=2 "$BIN" >/dev/null 2>"$warn" || fail "run with PMI_SIZE=2"
grep -q 'exceeds physical cores' "$warn" \
  || fail "expected occupancy warning with PMI_SIZE=2"

echo "execution_occupancy/smoke: ok (host_cores=$HOST_CORES)"
