#!/usr/bin/env bash
# Build lic-docs with lic/docs sources and fail on raw .md hrefs in HTML output.
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
  echo "check-docs-site-links: clone lic-docs beside lic or set LI_DOCS_ROOT" >&2
  exit 2
fi

BACKUP=""
restore_docs() {
  if [[ -n "$BACKUP" && -d "$DOCS_ROOT/.docs-lic-backup" ]]; then
    rm -rf "$DOCS_ROOT/docs"
    mv "$DOCS_ROOT/.docs-lic-backup" "$DOCS_ROOT/docs"
  fi
}
trap restore_docs EXIT

BACKUP=1
rm -rf "$DOCS_ROOT/.docs-lic-backup"
mv "$DOCS_ROOT/docs" "$DOCS_ROOT/.docs-lic-backup"
cp -a "$ROOT/docs" "$DOCS_ROOT/docs"

python3 "$ROOT/scripts/patch-mkdocs-validation.py" "$DOCS_ROOT/mkdocs.yml"

chmod +x "$DOCS_ROOT/scripts/build-docs.sh" 2>/dev/null || true
STRICT="${DOCS_STRICT:-1}"
if [[ "$STRICT" == "1" ]]; then
  "$DOCS_ROOT/scripts/build-docs.sh" --strict
else
  "$DOCS_ROOT/scripts/build-docs.sh"
fi

python3 "$ROOT/scripts/check-docs-md-hrefs.py" --site "$DOCS_ROOT/site" --repo-root "$ROOT"
