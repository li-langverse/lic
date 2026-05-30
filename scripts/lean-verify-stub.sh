#!/usr/bin/env bash
# Phase 2f: `lake build` on docs/semantics + optional AutoVC open-goal check.
# Invoked from lic only; use --check-open-goals (not env) for strict open-VC pass.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEM="$ROOT/docs/semantics"
CHECK_OPEN=0
for arg in "$@"; do
  case "$arg" in
    --check-open-goals) CHECK_OPEN=1 ;;
  esac
done

run_lean_verify_inner() {
  echo "lean: running lake in docs/semantics"
  (cd "$SEM" && lake build) || return $?
  if [[ -f "$ROOT/build/generated/AutoVC.lean" ]]; then
    echo "lean: typechecking generated AutoVC"
    rm -f "$SEM/.lake/build/lib/lean/AutoVC.olean" "$SEM/.lake/build/lib/lean/AutoVC.ilean" 2>/dev/null || true
    (cd "$SEM" && lake build AutoVC Discharge) || return $?
  fi
  if [[ "$CHECK_OPEN" == 1 && -f "$ROOT/build/generated/AutoVC.lean" ]]; then
    chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
    "$ROOT/scripts/check-autovc-open-goals.sh"
  fi
  return 0
}

run_lean_verify() {
  if command -v flock >/dev/null 2>&1; then
    mkdir -p "$ROOT/build/generated"
    (
      flock -w "${LI_AUTOVC_LOCK_TIMEOUT_SEC:-600}" 9 || {
        echo "lean-verify-stub: timeout waiting for AutoVC lock" >&2
        exit 1
      }
      run_lean_verify_inner
    ) 9>"$ROOT/build/generated/.autovc.lock"
  else
    run_lean_verify_inner
  fi
}

if [[ -x "$(command -v lake)" && -f "$SEM/lakefile.lean" ]]; then
  run_lean_verify
  exit 0
fi
echo "lean: skipped (install Lean 4 + lake; see docs/verification/provability-gaps.md G-lean)"
exit 0
