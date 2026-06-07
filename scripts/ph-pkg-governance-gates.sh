#!/usr/bin/env bash
# PH-Pkg governance exit gates — completion gate for goal-directed sprint (#476).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

say() { echo "ph-pkg-governance-gates: $*"; }
fail() { say "FAIL $*"; FAIL=1; }

# Gov-1: org access (skip when LI_GOV_HUMAN_ACK=1)
if [[ "${LI_GOV_HUMAN_ACK:-}" == "1" ]]; then
  say "Gov-1 skipped (LI_GOV_HUMAN_ACK=1)"
elif command -v gh >/dev/null 2>&1 && gh api orgs/li-langverse --jq .login >/dev/null 2>&1; then
  say "Gov-1 ok (gh api orgs/li-langverse)"
else
  fail "Gov-1: run 'gh api orgs/li-langverse' or set LI_GOV_HUMAN_ACK=1 after human ack on #476"
fi

# Gov-2: official-packages PKG- table
OFFICIAL="$ROOT/docs/ecosystem/official-packages.md"
if [[ -f "$OFFICIAL" ]] && grep -qE 'PKG-[a-zA-Z0-9_-]+' "$OFFICIAL" && grep -q 'li-langverse' "$OFFICIAL"; then
  say "Gov-2 ok ($OFFICIAL)"
else
  fail "Gov-2: missing PKG- table in $OFFICIAL"
fi

# Gov-3: no stale li-language repo home in key docs
STALE=$(grep -rl 'li-langverse/li-language' "$ROOT/docs/handbook" "$ROOT/docs/ecosystem/plan-cross-links.md" 2>/dev/null || true)
if [[ -z "$STALE" ]]; then
  say "Gov-3 ok (no stale li-language repo home refs in handbook/plan-cross-links)"
else
  fail "Gov-3: stale li-language refs in: $STALE"
fi
if curl -sf --max-time 15 'https://li-langverse.github.io/lic/' >/dev/null 2>&1; then
  say "Gov-3 ok (lic Pages reachable)"
else
  fail "Gov-3: https://li-langverse.github.io/lic/ not reachable"
fi

# Gov-4: governance.md stub
GOV="$ROOT/docs/ecosystem/governance.md"
if [[ -f "$GOV" ]] && grep -q 'roadmap' "$GOV"; then
  say "Gov-4 ok ($GOV)"
else
  fail "Gov-4: missing or incomplete $GOV"
fi

# Gov-5: templates + traceability script
if [[ -d "$ROOT/scripts/templates/github-repo" ]] && [[ -x "$ROOT/scripts/check-traceability.sh" ]]; then
  if bash "$ROOT/scripts/check-traceability.sh"; then
    say "Gov-5 ok (templates + check-traceability.sh)"
  else
    fail "Gov-5: check-traceability.sh failed"
  fi
else
  fail "Gov-5: missing templates or check-traceability.sh"
fi

# Gov-6: create-li-package skill --official section
SKILL="$ROOT/.cursor/skills/create-li-package/SKILL.md"
if [[ -f "$SKILL" ]] && grep -q '\-\-official' "$SKILL" && grep -q 'official-packages' "$SKILL"; then
  say "Gov-6 ok ($SKILL)"
else
  fail "Gov-6: create-li-package skill missing --official / org checklist"
fi

# Gov-7: example PUBLISH.md traceability block
PUB="$ROOT/packages/li-demo/PUBLISH.md"
if [[ -f "$PUB" ]] && grep -qE 'PKG-[a-zA-Z0-9_-]+' "$PUB" && grep -qi 'traceability' "$PUB"; then
  say "Gov-7 ok ($PUB traceability block)"
else
  fail "Gov-7: add ## Traceability block to $PUB (PH-*, T-*, REQ-*)"
fi

if [[ "$FAIL" -ne 0 ]]; then
  say "one or more gates failed"
  exit 1
fi
say "all governance exit gates passed"
exit 0
