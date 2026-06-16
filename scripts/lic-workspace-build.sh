#!/usr/bin/env bash
# Phase 8a: build smoke entrypoints for [workspace].members in packages/li.toml.
# Phase 8p-b: parallel member builds via li_workspace_jobs / LI_TEST_JOBS pool.
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

buildable=()
for m in "${members[@]}"; do
  case "$m" in
    li-demo) continue ;;
  esac
  entry="$ROOT/packages/$m/src/lib.li"
  smoke="$ROOT/packages/$m/li-tests/smoke/builds.li"
  if [[ -f "$smoke" || -f "$entry" ]]; then
    buildable+=("$m")
  else
    echo "workspace build: skip $m (no entrypoint)" >&2
  fi
done

build_one_member() {
  local m="$1" id="$2"
  local entry smoke build_dir
  entry="$ROOT/packages/$m/src/lib.li"
  smoke="$ROOT/packages/$m/li-tests/smoke/builds.li"
  build_dir="$ROOT/build/li-ws-$id"
  mkdir -p "$build_dir/generated"
  if [[ -f "$smoke" ]]; then
    echo "workspace build: $m (smoke)"
    "$LIC" build --build-dir="$build_dir" --allow-open-vc --no-lean-verify "$smoke" -o "$NULL_OUT"
  else
    echo "workspace build: $m (src/lib.li)"
    "$LIC" build --build-dir="$build_dir" --allow-open-vc --no-lean-verify "$entry" -o "$NULL_OUT"
  fi
}

WORKSPACE_JOBS="$(li_workspace_jobs)"
if ((${#buildable[@]} == 0)); then
  echo "lic-workspace-build: ok (${#members[@]} members, 0 buildable)"
  exit 0
fi

if [[ "$WORKSPACE_JOBS" -le 1 ]]; then
  id=0
  for m in "${buildable[@]}"; do
    build_one_member "$m" "$id"
    id=$((id + 1))
  done
else
  echo "lic-workspace-build: parallel jobs=$WORKSPACE_JOBS (isolated --build-dir per worker)" >&2
  id=0
  pids=""
  for m in "${buildable[@]}"; do
    while [[ "$(jobs -pr | wc -l | tr -d ' ')" -ge "$WORKSPACE_JOBS" ]]; do
      sleep 0.05
    done
    (
      set +e
      build_one_member "$m" "$id"
      echo $? >"$ROOT/build/li-ws-$id.rc"
    ) &
    pids="$pids $!"
    id=$((id + 1))
  done
  for pid in $pids; do
    [[ -n "$pid" ]] || continue
    wait "$pid" 2>/dev/null || true
  done
  fail=0
  i=0
  while [[ "$i" -lt "$id" ]]; do
    if [[ -f "$ROOT/build/li-ws-$i.rc" ]]; then
      case "$(cat "$ROOT/build/li-ws-$i.rc")" in
        0) ;;
        *) fail=$((fail + 1)) ;;
      esac
      rm -f "$ROOT/build/li-ws-$i.rc"
    else
      fail=$((fail + 1))
    fi
    i=$((i + 1))
  done
  if [[ "$fail" -ne 0 ]]; then
    echo "lic-workspace-build: $fail member(s) failed" >&2
    exit 1
  fi
fi
echo "lic-workspace-build: ok (${#members[@]} members, ${#buildable[@]} built, jobs=$WORKSPACE_JOBS)"
