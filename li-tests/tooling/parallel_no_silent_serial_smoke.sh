#!/usr/bin/env bash
# lic#109 — proved @parallel / parallel for must lower to li_parallel_for_* (no silent serial).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "parallel_no_silent_serial_smoke: lic not built" >&2; exit 1; }

SRC="$ROOT/li-tests/parallel_codegen/parallel_no_silent_serial.li"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

out="$("$LIC" verify "$SRC" 2>&1)"
echo "$out" | grep -q 'mir_parallel_policy=static_chunk'

"$LIC" build "$SRC" -o "$tmp/par" --release --cores=4 >/dev/null
sym_ok=0
if command -v llvm-nm >/dev/null 2>&1; then
  if llvm-nm "$tmp/par" | grep -qE 'li_parallel_for_(i64|reduce_add_f64)'; then sym_ok=1; fi
elif command -v nm >/dev/null 2>&1; then
  if nm "$tmp/par" | grep -qE 'li_parallel_for_(i64|reduce_add_f64)'; then sym_ok=1; fi
else
  echo "parallel_no_silent_serial_smoke: skip symbol check (no nm)" >&2
  sym_ok=1
fi
if [[ "$sym_ok" -ne 1 ]]; then
  echo "parallel_no_silent_serial_smoke: missing li_parallel_for_* runtime symbol" >&2
  exit 1
fi

echo "PASS parallel_no_silent_serial_smoke: static_chunk policy + li_parallel_for_*"
