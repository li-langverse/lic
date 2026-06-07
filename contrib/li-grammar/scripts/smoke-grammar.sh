#!/usr/bin/env bash
# Minimal CI smoke: valid tmLanguage JSON + lexer_parser fixtures exist.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$ROOT/../.." && pwd)"
GRAMMAR="$ROOT/syntaxes/li.tmLanguage.json"

if command -v jq >/dev/null 2>&1; then
  jq empty "$GRAMMAR"
else
  python3 -m json.tool "$GRAMMAR" >/dev/null
fi

FIXTURES=(
  li-tests/lexer_parser/fib.li
  li-tests/lexer_parser/decorators_parse.li
  li-tests/lexer_parser/async_await_parse.li
)

for rel in "${FIXTURES[@]}"; do
  path="$REPO_ROOT/$rel"
  if [[ ! -f "$path" ]]; then
    echo "smoke-grammar: missing fixture $rel" >&2
    exit 1
  fi
done

echo "smoke-grammar: ok ($GRAMMAR + ${#FIXTURES[@]} fixtures)"
