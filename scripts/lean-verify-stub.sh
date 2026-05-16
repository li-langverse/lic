#!/usr/bin/env bash
# Phase 2f placeholder: real gate runs `lake build` on docs/semantics (G-lean).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SEM="$ROOT/docs/semantics"
if [[ -x "$(command -v lake)" && -f "$SEM/lakefile.lean" ]]; then
  echo "lean: running lake in docs/semantics"
  (cd "$SEM" && lake build) || exit $?
  if [[ "${LI_BUILD_VERIFY_LEAN:-}" == "1" ]]; then
    chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
  fi
  if [[ -f "$ROOT/build/generated/AutoVC.lean" ]] &&
     [[ "${LI_BUILD_VERIFY_LEAN_STRICT:-}" == "1" ]]; then
    "$ROOT/scripts/check-autovc-open-goals.sh"
  fi
  exit 0
fi
echo "lean: skipped (install Lean 4 + lake; see docs/verification/provability-gaps.md G-lean)"
exit 0
