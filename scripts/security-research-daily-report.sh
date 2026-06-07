#!/usr/bin/env bash
# Daily report for security research loop.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

export TZ="${SECURITY_RESEARCH_TZ:-Europe/Berlin}"
DAY="$(date +%Y-%m-%d)"
OUT="${ROOT}/docs/reports/security-research/daily/${DAY}.md"
mkdir -p "$(dirname "$OUT")"
STATE="${ROOT}/data/security-research-loop/state.json"
GRADE="${ROOT}/data/security-research-loop/grade.json"
BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
SHA="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"

{
  echo "# Security research — daily report ${DAY}"
  echo ""
  echo "_Generated $(date -Iseconds) (${TZ})_"
  echo ""
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Branch | \`${BRANCH}\` |"
  echo "| HEAD | \`${SHA}\` |"
  echo "| Agent | \`${LI_SECURITY_PLAN_AGENT:-security_auditor}\` |"
  echo "| Backlog | \`docs/ecosystem/security-research-backlog.md\` |"
  echo "| Runner | \`data/security-research-loop/runner.log\` |"
  echo ""
  if [[ -f "$STATE" ]]; then
    echo "## State"
    echo '```json'
    head -c 4000 "$STATE"
    echo ""
    echo '```'
  fi
  if [[ -f "$GRADE" ]]; then
    echo ""
    echo "## Last grade"
    echo '```json'
    cat "$GRADE"
    echo '```'
  fi
} >"$OUT"
ln -sf "${DAY}.md" "$(dirname "$OUT")/LATEST.md"
echo "wrote $OUT"
