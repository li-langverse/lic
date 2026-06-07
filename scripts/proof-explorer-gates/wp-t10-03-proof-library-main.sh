#!/usr/bin/env bash
# WP-T10-03: proof-library main has fresh library.json from lic.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=_lib.sh
source "$(dirname "$0")/_lib.sh"

PL="$(pe_resolve_proof_library "$ROOT" || true)"
[[ -n "$PL" && -f "$PL/scripts/build-library.py" ]] || {
  echo "wp-t10-03: proof-library missing (set PROOF_LIBRARY_ROOT or clone ../proof-library)" >&2
  exit 1
}

LIC_MAIN="$(pe_resolve_lic_main_sha "$ROOT")"
export LIC_ROOT="$ROOT"
export LIC_COMMIT="$LIC_MAIN"

LIC_ROOT="$ROOT" LIC_COMMIT="$LIC_MAIN" python3 "$PL/scripts/build-library.py"
bash "$PL/scripts/check-library-quality.sh"
python3 "$PL/scripts/check-no-proc-in-library.py"

SIGNOFF="$ROOT/data/proof-explorer-loop/wp-t10-proof-library-main.signoff"
if [[ -f "$SIGNOFF" ]]; then
  pe_check_library_lic_commit "wp-t10-03" "$PL/data/library.json" "$LIC_MAIN"
  echo "wp-t10-03-proof-library-main: OK (merged sign-off)"
  exit 0
fi

pe_check_library_lic_commit "wp-t10-03" "$PL/data/library.json" "$LIC_MAIN"
echo "wp-t10-03-proof-library-main: OK (library rebuilt; merge PR for Pages)"
