#!/usr/bin/env bash
# Fail if any .li file uses bare proc (extern proc and decorator def are allowed).
set -euo pipefail

ROOT="${1:-.}"

if ! command -v rg >/dev/null 2>&1; then
  echo "check-li-def-syntax: ripgrep (rg) required" >&2
  exit 1
fi

shopt -s globstar 2>/dev/null || true

bad=0
while IFS= read -r hit; do
  [[ -z "$hit" ]] && continue
  echo "check-li-def-syntax: $hit"
  bad=1
done < <(rg -n '^[[:space:]]*proc\b' --glob '*.li' "$ROOT" 2>/dev/null || true)

while IFS= read -r hit; do
  [[ -z "$hit" ]] && continue
  echo "check-li-def-syntax: $hit (use async def)"
  bad=1
done < <(rg -n '\basync proc\b' --glob '*.li' "$ROOT" 2>/dev/null || true)

if [[ "$bad" -ne 0 ]]; then
  echo "check-li-def-syntax: use 'def' for Li procedures; only 'extern proc' may use proc" >&2
  exit 1
fi

echo "check-li-def-syntax: ok under $ROOT"
