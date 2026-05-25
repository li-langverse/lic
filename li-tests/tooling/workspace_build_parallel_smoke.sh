#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="$("$ROOT/scripts/resolve-lic.sh")"
[[ -x "$LIC" ]] || { echo "workspace_build_parallel_smoke: skip (no lic)" >&2; exit 0; }
fail() { echo "workspace_build_parallel_smoke: $*" >&2; exit 1; }
WS="$(mktemp "${TMPDIR:-/tmp}/li-ws-mini.XXXX.toml")"
printf '%s\n' '[workspace]' 'members = ["li-acme", "li-bytes"]' 'resolver = "path"' >"$WS"
rm -rf "$ROOT/build/li-ws-li-acme" "$ROOT/build/li-ws-li-bytes"
LI_WORKSPACE_JOBS=2 "$ROOT/scripts/lic-workspace-build.sh" -j 2 "$WS" || fail "build failed"
[[ -f "$ROOT/build/li-ws-li-acme/generated/AutoVC.lean" ]] || fail "missing acme AutoVC"
[[ -f "$ROOT/build/li-ws-li-bytes/generated/AutoVC.lean" ]] || fail "missing bytes AutoVC"
rm -f "$WS"
echo "workspace_build_parallel_smoke: ok"
