#!/usr/bin/env bash
# Guard parallel li-tests: lake AutoVC typecheck must serialize via .autovc.lock.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if ! command -v flock >/dev/null 2>&1; then
  echo "lean_lake_lock_smoke: skipped (no flock)"
  exit 0
fi
if ! grep -q '\.autovc\.lock' "$ROOT/scripts/lean-verify-stub.sh"; then
  echo "lean_lake_lock_smoke: lean-verify-stub.sh missing .autovc.lock guard" >&2
  exit 1
fi
if ! grep -q 'flock' "$ROOT/scripts/lean-verify-stub.sh"; then
  echo "lean_lake_lock_smoke: lean-verify-stub.sh missing flock guard" >&2
  exit 1
fi
counter="$(mktemp)"
echo 0 >"$counter"
bump() {
  "$ROOT/scripts/with-autovc-lock.sh" bash -c '
    n=$(cat "$1")
    sleep 0.05
    echo $((n + 1)) > "$1"
  ' _ "$counter"
}
for _ in 1 2 3 4; do
  bump &
done
wait
n="$(cat "$counter")"
rm -f "$counter"
if [[ "$n" != 4 ]]; then
  echo "lean_lake_lock_smoke: expected counter=4 got $n" >&2
  exit 1
fi
echo "lean_lake_lock_smoke: ok"
