#!/usr/bin/env bash
# Phase 8a/8p-b: build smoke entrypoints for [workspace].members in packages/li.toml.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="${LI_REPO_ROOT:-$ROOT}"
source "$ROOT/scripts/lib/li-jobs.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
WS="${1:-$ROOT/packages/li.toml}"
NULL_OUT="/dev/null"
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;; esac
WORKSPACE_JOBS="$(li_workspace_jobs)"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -j|--jobs) WORKSPACE_JOBS="${2:?}"; shift 2 ;;
    -j*) WORKSPACE_JOBS="${1#-j}"; shift ;;
    -h|--help) echo "usage: $0 [-j N] [li.toml]" >&2; exit 0 ;;
    *) break ;;
  esac
done
[[ -n "${1:-}" ]] && WS="$1"
[[ -f "$WS" ]] || { echo "error: workspace file not found: $WS" >&2; exit 1; }
declare -a members=()
while IFS= read -r name; do [[ -n "$name" ]] && members+=("$name"); done < <(python3 - "$WS" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
m = re.search(r'members\s*=\s*\[(.*?)\]', text, re.S)
if m:
  for part in re.findall(r'"([^"]+)"', m.group(1)):
    print(part)
PY
)
[[ ${#members[@]} -eq 0 ]] && { echo "workspace: no members"; exit 0; }
TASKS_FILE="$(mktemp "${TMPDIR:-/tmp}/li-ws-tasks.XXXX")"
: >"$TASKS_FILE"
for m in "${members[@]}"; do
  [[ "$m" == li-demo ]] && continue
  smoke="$ROOT/packages/$m/li-tests/smoke/builds.li"
  entry="$ROOT/packages/$m/src/lib.li"
  [[ -f "$smoke" ]] && printf '%s\t%s\tsmoke\n' "$m" "$smoke" >>"$TASKS_FILE"
  [[ -f "$entry" && ! -f "$smoke" ]] && printf '%s\t%s\tlib\n' "$m" "$entry" >>"$TASKS_FILE"
done
task_count="$(wc -l <"$TASKS_FILE" | tr -d ' ')"
[[ "$task_count" -eq 0 ]] && { rm -f "$TASKS_FILE"; echo "lic-workspace-build: ok (0 buildable)"; exit 0; }
build_member() {
  local member="$1" path="$2"
  local build_dir="$ROOT/build/li-ws-$member"
  mkdir -p "$build_dir/generated"
  echo "workspace build: $member"
  "$LIC" build --build-dir="$build_dir" "$path" -o "$NULL_OUT"
}
fail=0
if [[ "$WORKSPACE_JOBS" -le 1 ]]; then
  while IFS=$'\t' read -r member path _; do
    [[ -z "$member" ]] && continue
    build_member "$member" "$path" || fail=$((fail + 1))
  done <"$TASKS_FILE"
else
  echo "lic-workspace-build: parallel jobs=$WORKSPACE_JOBS" >&2
  pids=""
  while IFS=$'\t' read -r member path _; do
    [[ -z "$member" ]] && continue
    while [[ "$(jobs -pr | wc -l | tr -d ' ')" -ge "$WORKSPACE_JOBS" ]]; do sleep 0.05; done
    ( build_member "$member" "$path"; echo $? >"$ROOT/build/li-ws-$member.rc" ) &
    pids="$pids $!"
  done <"$TASKS_FILE"
  for pid in $pids; do [[ -n "$pid" ]] && wait "$pid" 2>/dev/null || true; done
  while IFS=$'\t' read -r member _ _; do
    [[ -z "$member" ]] && continue
    [[ -f "$ROOT/build/li-ws-$member.rc" ]] && [[ "$(cat "$ROOT/build/li-ws-$member.rc")" -eq 0 ]] || fail=$((fail + 1))
    rm -f "$ROOT/build/li-ws-$member.rc"
  done <"$TASKS_FILE"
fi
rm -f "$TASKS_FILE"
[[ "$fail" -gt 0 ]] && { echo "lic-workspace-build: fail ($fail)" >&2; exit 1; }
echo "lic-workspace-build: ok (${#members[@]} members, buildable=$task_count, jobs=$WORKSPACE_JOBS)"
