#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
[[ -x "$LIC" ]] || { echo "check-mir-cpu-decorator: lic not built" >&2; exit 1; }
out="$("$LIC" verify "$ROOT/li-tests/decorators/cpu_only_ok.li" 2>&1)"
echo "$out" | grep -q 'mir_cpu_def=1'
"$ROOT/li-tests/run_all.sh" decorators >/dev/null
echo check-mir-cpu-decorator: ok
