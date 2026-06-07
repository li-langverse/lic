#!/usr/bin/env bash
# Daily report for MD or chem algorithm research loop.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERT="${SIM_RESEARCH_VERTICAL:-}"
if [[ "$VERT" != "md" && "$VERT" != "chem" ]]; then
  echo "sim-algo-research-daily-report: set SIM_RESEARCH_VERTICAL=md|chem" >&2
  exit 1
fi

export TZ="${SIM_RESEARCH_TZ:-Europe/Berlin}"
DAY="$(date +%Y-%m-%d)"
OUT="${ROOT}/docs/reports/sim-${VERT}-research/daily/${DAY}.md"
mkdir -p "$(dirname "$OUT")"
STATE="${ROOT}/data/sim-${VERT}-research-loop/state.json"
GRADE="${ROOT}/data/sim-${VERT}-research-loop/grade.json"
BRANCH="$(git -C "$ROOT" branch --show-current 2>/dev/null || echo unknown)"
SHA="$(git -C "$ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"

{
  echo "# Sim ${VERT} research — daily report ${DAY}"
  echo ""
  echo "_Generated $(date -Iseconds) (${TZ})_"
  echo ""
  echo "| Metric | Value |"
  echo "|--------|-------|"
  echo "| Branch | \`${BRANCH}\` |"
  echo "| HEAD | \`${SHA}\` |"
  echo "| Backlog | \`docs/ecosystem/sim-${VERT}-research-backlog.md\` |"
  echo "| Runner | \`data/sim-${VERT}-research-loop/runner.log\` |"
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
