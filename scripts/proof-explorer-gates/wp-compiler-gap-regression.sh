#!/usr/bin/env bash
# Run all li-tests/tooling/*_gap.sh; require BUG-C-01 (dot4) pass when lic is built.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

fail=0
open=0
shopt -s nullglob
gaps=(li-tests/tooling/*_gap.sh)
if [[ ${#gaps[@]} -eq 0 ]]; then
  echo "wp-compiler-gap-regression: no *_gap.sh found" >&2
  exit 1
fi

for script in "${gaps[@]}"; do
  name="$(basename "$script")"
  set +e
  bash "$script"
  code=$?
  set -e
  if [[ "$code" -eq 0 ]]; then
    echo "wp-compiler-gap-regression: PASS $name"
  else
    echo "wp-compiler-gap-regression: OPEN $name (exit $code)" >&2
    open=$((open + 1))
    if [[ "$name" == "dot4_loop_ensures_lean_stub_gap.sh" ]]; then
      fail=1
    fi
  fi
done

echo "wp-compiler-gap-regression: ${#gaps[@]} scripts, $open still open"
if [[ "$fail" -ne 0 ]]; then
  echo "wp-compiler-gap-regression: FAIL (dot4 must pass after #696)" >&2
  exit 1
fi
echo "wp-compiler-gap-regression: OK"
exit 0
