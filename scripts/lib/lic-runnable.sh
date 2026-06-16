#!/usr/bin/env bash
# Back-compat shim — prefer scripts/lib/lic-bin-select.sh.
set -euo pipefail
_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lic-bin-select.sh
source "$_ROOT/lic-bin-select.sh"
