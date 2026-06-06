#!/usr/bin/env bash
# Build handbook via lic-docs MkDocs with lic/docs sources overlaid.
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

if [[ -z "$DOCS_ROOT" || ! -f "$DOCS_ROOT/mkdocs.yml" ]]; then
  echo "docs: published site is built from https://github.com/li-langverse/lic-docs" >&2
  echo "  clone that repo beside lic (../lic-docs) or set LI_DOCS_ROOT=/path/to/lic-docs" >&2
  exit 1
fi

export LI_DOCS_ROOT="$DOCS_ROOT"
if [[ " $* " == *" --strict "* ]]; then
  export DOCS_STRICT=1
else
  export DOCS_STRICT="${DOCS_STRICT:-0}"
fi

exec "$ROOT/scripts/check-docs-site-links.sh"
