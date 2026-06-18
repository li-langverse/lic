#!/usr/bin/env bash
# Gate: numerics reference pin block must match lic#33 / math-r policy.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKLOG="$ROOT/docs/ecosystem/numerics-reference-backlog.md"
PLAN="$ROOT/docs/superpowers/plans/2026-06-07-eigen-numerics-reference-policy.md"

fail() { echo "check-numerics-reference-pins: $*" >&2; exit 1; }

test -f "$BACKLOG" || fail "missing $BACKLOG"
test -f "$PLAN" || fail "missing $PLAN"

for needle in '3.4.1' '5.0.0' 'C++17' 'OpenBLAS'; do
  grep -q "$needle" "$BACKLOG" || fail "backlog missing pin: $needle"
done

grep -qi 'hand-rolled\|cpp_handrolled' "$BACKLOG" \
  || fail "backlog must document hand-rolled cpp oracle honesty"

echo "OK: numerics reference pins present in $BACKLOG"
