#!/usr/bin/env bash
# WP-PAR-02 — full lipar-suite prereqs export li-httpd + tier5 langs.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=scripts/lib/lipar-suite-prereqs.sh
source "$ROOT/scripts/lib/lipar-suite-prereqs.sh"
lipar_suite_ensure_prereqs "$ROOT"
[[ -x "$LI_HTTPD_BIN" ]]
[[ "$TIER5_EXPLOIT_LANGS" == "nginx,li" ]]
echo "li_parallel_full_suite_prereqs: ok (LI_HTTPD_BIN=$LI_HTTPD_BIN)"
