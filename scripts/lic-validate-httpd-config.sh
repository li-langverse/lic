#!/usr/bin/env bash
# lic validate-httpd-config — prefer built `lic validate-httpd-config`, else Python.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="$ROOT"
export PYTHONPATH="${ROOT}/scripts${PYTHONPATH:+:$PYTHONPATH}"
LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
if [[ -x "$LIC" ]]; then
  exec "$LIC" validate-httpd-config "$@"
fi
exec python3 "${ROOT}/scripts/validate-httpd-config.py" "$@"
