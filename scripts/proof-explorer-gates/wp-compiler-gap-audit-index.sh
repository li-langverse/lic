#!/usr/bin/env bash
# docs/reports/compiler-audit/ must index BUG-C-01..12.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
AUDIT="$ROOT/docs/reports/compiler-audit"

fail=0
test -f "$AUDIT/README.md" || fail=1
for n in $(seq -w 1 12); do
  id="BUG-C-${n}"
  if [[ ! -f "$AUDIT/${id}.md" ]]; then
    echo "wp-compiler-gap-audit-index: missing $AUDIT/${id}.md" >&2
    fail=1
  fi
done

if ! grep -q 'BUG-C-01' "$AUDIT/README.md"; then
  echo "wp-compiler-gap-audit-index: README missing BUG-C index" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "wp-compiler-gap-audit-index: OK"
exit 0
