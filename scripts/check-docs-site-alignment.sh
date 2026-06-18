#!/usr/bin/env bash
# Verify published docs site metadata no longer points at deprecated li-language.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOCS_ROOT="${LI_DOCS_ROOT:-}"

if [[ -z "$DOCS_ROOT" ]]; then
  for candidate in "$ROOT/../lic-docs" "$ROOT/../../lic-docs"; do
    if [[ -f "$candidate/mkdocs.yml" ]]; then
      DOCS_ROOT="$(cd "$candidate" && pwd)"
      break
    fi
  done
fi

if [[ -n "$DOCS_ROOT" && -f "$DOCS_ROOT/mkdocs.yml" ]]; then
  MKDOCS="$DOCS_ROOT/mkdocs.yml"
else
  TMP="$(mktemp)"
  trap 'rm -f "$TMP"' EXIT
  REMOTE_URL="https://raw.githubusercontent.com/li-langverse/lic-docs/main/mkdocs.yml"
  if curl -sf --max-time 20 "$REMOTE_URL" -o "$TMP"; then
    MKDOCS="$TMP"
  elif command -v gh >/dev/null 2>&1 && gh api "repos/li-langverse/lic-docs/contents/mkdocs.yml" --jq '.content' 2>/dev/null | tr -d '\n' | base64 -d >"$TMP"; then
    MKDOCS="$TMP"
  else
    echo "FAIL: no local lic-docs checkout and could not fetch lic-docs/mkdocs.yml" >&2
    exit 1
  fi
fi

FAIL=0
if grep -qE 'github\.com/li-langverse/li-language|li-langverse/li-language\.git' "$MKDOCS"; then
  echo "FAIL $MKDOCS: must not reference deprecated li-language GitHub repo"
  FAIL=1
fi
if ! grep -q 'li-langverse/lic-docs' "$MKDOCS"; then
  echo "FAIL $MKDOCS: repo_url/repo_name must reference li-langverse/lic-docs"
  FAIL=1
fi

if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
echo "check-docs-site-alignment: ok ($MKDOCS)"
