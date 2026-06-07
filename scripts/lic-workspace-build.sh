#!/usr/bin/env bash
# Phase 8a/8p-b: build smoke entrypoints for [workspace].members in packages/li.toml.
# Some members (e.g. li-demo) are mirrored app/demo packages — they do not gate lic CI.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="${LI_REPO_ROOT:-$ROOT}"
# shellcheck source=lib/li-jobs.sh
source "$ROOT/scripts/lib/li-jobs.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
WS="${1:-$ROOT/packages/li.toml}"
NULL_OUT="/dev/null"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;;
esac

if [[ ! -f "$WS" ]]; then
  echo "error: workspace file not found: $WS" >&2
  exit 1
fi
members=()
while IFS= read -r name; do
  [[ -n "$name" ]] && members+=("$name")
done < <(python3 - "$WS" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
m = re.search(r'members\s*=\s*\[(.*?)\]', text, re.S)
if not m:
    sys.exit(0)
for part in re.findall(r'"([^"]+)"', m.group(1)):
    print(part)
PY
)
if [[ ${#members[@]} -eq 0 ]]; then
  echo "workspace: no members"
  exit 0
fi

tasks_file="$(mktemp "${TMPDIR:-/tmp}/li-ws-tasks.XXXX")"
# shellcheck disable=SC2064
trap 'rm -f "$tasks_file"' EXIT
: >"$tasks_file"

for m in "${members[@]}"; do
  case "$m" in
    li-demo)
      echo "workspace build: skip $m (demo package — own repo CI, not a lic compiler gate)"
      continue
      ;;
  esac
  entry="$ROOT/packages/$m/src/lib.li"
  smoke="$ROOT/packages/$m/li-tests/smoke/builds.li"
  # Prefer smoke: package libs may use extern stubs not yet proof-complete (8a).
  if [[ -f "$smoke" ]]; then
    printf '%s\t%s\tsmoke\n' "$m" "$smoke" >>"$tasks_file"
  elif [[ -f "$entry" ]]; then
    printf '%s\t%s\tlib\n' "$m" "$entry" >>"$tasks_file"
  else
    echo "workspace build: skip $m (no entrypoint)" >&2
  fi
done

task_count="$(wc -l <"$tasks_file" | tr -d ' ')"
if [[ "$task_count" -eq 0 ]]; then
  echo "lic-workspace-build: ok (0 build tasks, ${#members[@]} members)"
  exit 0
fi

WS_JOBS="$(li_workspace_jobs)"
echo "lic-workspace-build: $task_count tasks, jobs=$WS_JOBS (LI_TEST_JOBS/LI_WORKSPACE_JOBS pool)"

fail=0
id=0
pids=""
while IFS=$'\t' read -r member target kind; do
  [[ -z "$member" ]] && continue
  while [[ "$(jobs -pr | wc -l | tr -d ' ')" -ge "$WS_JOBS" ]]; do
    sleep 0.05
  done
  (
    build_dir="$ROOT/build/li-ws-$id"
    mkdir -p "$build_dir/generated"
    echo "workspace build: $member ($kind)"
    if "$LIC" build --build-dir="$build_dir" --allow-open-vc --no-lean-verify "$target" -o "$NULL_OUT"; then
      echo 0 >"$ROOT/build/li-ws-$id.rc"
    else
      echo 1 >"$ROOT/build/li-ws-$id.rc"
    fi
  ) &
  pids="$pids $!"
  id=$((id + 1))
done <"$tasks_file"

for pid in $pids; do
  [[ -n "$pid" ]] || continue
  wait "$pid" 2>/dev/null || true
done

i=0
while [[ "$i" -lt "$id" ]]; do
  if [[ -f "$ROOT/build/li-ws-$i.rc" ]]; then
    if [[ "$(cat "$ROOT/build/li-ws-$i.rc")" != "0" ]]; then
      fail=1
    fi
    rm -f "$ROOT/build/li-ws-$i.rc"
  else
    fail=1
  fi
  i=$((i + 1))
done

if [[ "$fail" -ne 0 ]]; then
  echo "lic-workspace-build: failed" >&2
  exit 1
fi
echo "lic-workspace-build: ok ($task_count tasks, ${#members[@]} members, jobs=$WS_JOBS)"
