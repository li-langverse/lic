#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
out="$("$LIC" verify "$ROOT/li-tests/contracts_verify/witnessed_ensures_ident.li" 2>&1)"
echo "$out" | grep -q witnessed_ensures=1
echo "$out" | grep -q mir_return_linked=1
echo discharge_witnessed_ensures_lean: ok
