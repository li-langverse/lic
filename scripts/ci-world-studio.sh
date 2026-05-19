#!/usr/bin/env bash
# World Studio / Li Engine CI gate (composable + vertical demos + spin-up + studio binary).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
export LI_REPO_ROOT="$ROOT"
export LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"

li_phase "World Studio composable gates"
"$ROOT/li-tests/run_all.sh" composable

li_phase "World Studio game_dev smokes"
"$ROOT/li-tests/run_all.sh" game_dev

li_phase "World Studio vertical demo builds"
"$ROOT/li-tests/run_all.sh" vertical_demos

li_phase "World Studio spin-up templates"
"$ROOT/li-tests/run_all.sh" spinup_templates

li_phase "World Studio studio binary"
chmod +x "$ROOT/scripts/build-studio-binary.sh"
"$ROOT/scripts/build-studio-binary.sh"

li_phase "World Studio demo status.json"
chmod +x "$ROOT/scripts/gen-studio-demo-status.sh"
"$ROOT/scripts/gen-studio-demo-status.sh"

li_gate_ok "world studio"
