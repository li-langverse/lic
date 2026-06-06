#!/usr/bin/env bash
# WP-PAR-50–55 / DOC-PAR-01–14 — documentation corpus in lic check + mkdocs nav.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
li_phase "li-parallel docs gate (DOC-PAR-01–14)"
li_fail "DOC-PAR-01–14 pending — add handbook, API ref, migration guide, mkdocs nav, gap register"
exit 1
