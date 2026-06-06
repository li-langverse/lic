#!/usr/bin/env bash
# WP-PAR-50–55 / DOC-PAR-01–14 — documentation corpus in lic check + mkdocs nav.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel docs gate (DOC-PAR-01–14)"

missing=()
while IFS='|' read -r doc_id relpath; do
  [[ -z "$doc_id" ]] && continue
  path="$ROOT/$relpath"
  if [[ ! -f "$path" ]]; then
    missing+=("$doc_id ($relpath missing)")
    continue
  fi
  if ! grep -q "$doc_id" "$path"; then
    missing+=("$doc_id (marker missing in $relpath)")
  fi
done <<'MANIFEST'
DOC-PAR-01|docs/handbook/li-parallel.md
DOC-PAR-02|docs/superpowers/specs/2026-06-06-li-parallel-design.md
DOC-PAR-03|packages/li-parallel/docs/api-shared-memory.md
DOC-PAR-04|packages/li-parallel/docs/api-distributed.md
DOC-PAR-05|packages/li-parallel/docs/api-kernels-ghost.md
DOC-PAR-06|packages/li-parallel/docs/migrate-openmp.md
DOC-PAR-07|packages/li-parallel/docs/migrate-mpi.md
DOC-PAR-08|packages/li-parallel/docs/examples/README.md
DOC-PAR-09|packages/li-parallel/docs/benchmark-dual-mode.md
DOC-PAR-10|packages/li-parallel/docs/proofs-table.md
DOC-PAR-11|packages/li-parallel/docs/mkdocs-nav.toml
DOC-PAR-12|packages/li-parallel/docs/gap-register.md
DOC-PAR-13|packages/li-parallel/docs/traceability.md
DOC-PAR-14|docs/release-notes/2026-06-06-li-parallel-docs-corpus.md
MANIFEST

if [[ ${#missing[@]} -gt 0 ]]; then
  li_fail "DOC-PAR corpus incomplete: ${missing[*]}"
  exit 1
fi

# mkdocs nav manifest must list all DOC-PAR ids
nav="$ROOT/packages/li-parallel/docs/mkdocs-nav.toml"
for doc_id in DOC-PAR-{01..14}; do
  if ! grep -q "$doc_id" "$nav"; then
    li_fail "mkdocs nav missing $doc_id (DOC-PAR-11)"
    exit 1
  fi
done

li_ok "DOC-PAR-01–14 corpus present (handbook, API ref, migration, examples, nav, gap register)"
