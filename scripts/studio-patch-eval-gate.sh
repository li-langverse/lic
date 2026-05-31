#!/usr/bin/env bash
# WP-AG-06 — patch eval harness ≥70% fix-rate on curated lic-check prompts.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LI_REPO_ROOT="$ROOT"

fail() { li_gate_fail "$*"; exit 1; }

li_phase "patch-eval fixtures"
[[ -f "$ROOT/packages/li-studio-ai/fixtures/patch-eval/manifest.toml" ]] || fail "missing patch-eval manifest"

li_phase "patch-eval smoke"
[[ -f "$ROOT/packages/li-studio-ai/li-tests/smoke/studio_ai_patch_eval.li" ]] || fail "missing studio_ai_patch_eval.li"

LIC="${LIC:-}"
if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/scripts/resolve-lic.sh" ]]; then
  LIC="$("$ROOT/scripts/resolve-lic.sh" 2>/dev/null)" || true
fi

if [[ -n "$LIC" && -x "$LIC" ]]; then
  li_phase "lic check patch eval"
  "$LIC" check "$ROOT/packages/li-studio-ai/li-tests/smoke/studio_ai_patch_eval.li" \
    || fail "lic check studio_ai_patch_eval.li"
else
  li_warn "lic not built — smoke path verified only"
fi

li_ok "studio-patch-eval-gate"
