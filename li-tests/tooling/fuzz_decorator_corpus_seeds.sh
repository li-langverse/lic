#!/usr/bin/env bash
# Phase 7d: committed parser fuzz seeds for decorator stacks + reserved-name parse paths.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CORPUS="$ROOT/compiler/fuzz/corpus"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

fail() {
  echo "fuzz_decorator_corpus_seeds: $*" >&2
  exit 1
}

parse_no_crash() {
  local label="$1"
  shift
  local rc=0
  "$@" >/dev/null 2>&1 || rc=$?
  if (( rc > 128 )); then
    fail "$label (signal exit $rc)"
  fi
}

required=(
  seed_decorators
  seed_decorator_stack
  seed_reserved_typosquat
)

for name in "${required[@]}"; do
  path="$CORPUS/$name"
  [[ -s "$path" ]] || fail "missing or empty corpus seed: $path"
done

[[ -x "$LIC" ]] || fail "lic not built ($LIC)"

for name in "${required[@]}"; do
  parse_no_crash "lic parse $name" "$LIC" parse "$CORPUS/$name"
done

echo "fuzz_decorator_corpus_seeds: ok (${#required[@]} seeds)"
