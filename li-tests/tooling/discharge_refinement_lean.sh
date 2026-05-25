#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
chmod +x "$ROOT/scripts/check-autovc-open-goals.sh"
check_sample() {
  local sample="$1" extra_grep="${2:-}"
  local AUTOVC="$ROOT/build/generated/AutoVC.lean"
  rm -f "$AUTOVC"
  "$LIC" build "$sample" -o /dev/null
  "$ROOT/scripts/check-autovc-open-goals.sh" "$AUTOVC"
  grep -q 'Li.Discharge.refinement_nonneg_spec' "$AUTOVC"
  grep -q 'P-refine folded' "$AUTOVC"
  [[ -z "$extra_grep" ]] || grep -q "$extra_grep" "$AUTOVC"
}
check_sample "$ROOT/li-tests/contracts_verify/refinement_call_ok.li" refinement_nonneg_lit_proved
check_sample "$ROOT/li-tests/contracts_verify/refinement_inline_ok.li" refinement_nonneg_lit_proved
check_sample "$ROOT/li-tests/contracts_verify/refinement_local_ok.li" refinement_nonneg_lit_proved
check_sample "$ROOT/li-tests/contracts_verify/refinement_guard_ok.li" refinement_nonneg_lit_proved
command -v lake >/dev/null && (cd "$ROOT/docs/semantics" && lake build) || true
echo "discharge_refinement_lean: ok"
