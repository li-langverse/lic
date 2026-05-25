#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export LI_REPO_ROOT="${LI_REPO_ROOT:-$ROOT}"
source "$ROOT/scripts/lib/li-jobs.sh"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
WS="$ROOT/packages/li.toml"
WS_JOBS="$(li_workspace_jobs)" MAX_MEMORY_MB=0 JOB_MEMORY_MB=768 BUILD_ROOT="$ROOT/build"
while [[ $# -gt 0 ]]; do
  case "$1" in
    -j|--jobs) WS_JOBS="${2:?}"; shift 2 ;;
    -j*) WS_JOBS="${1#-j}"; shift ;;
    --max-memory=*) MAX_MEMORY_MB="${1#--max-memory=}"; shift ;;
    --job-memory-mb=*) JOB_MEMORY_MB="${1#--job-memory-mb=}"; shift ;;
    --build-root=*) BUILD_ROOT="${1#--build-root=}"; shift ;;
    -*) echo "unknown flag $1" >&2; exit 1 ;;
    *) WS="$1"; shift ;;
  esac
done
WS_JOBS="$(li_effective_jobs "$WS_JOBS" "$MAX_MEMORY_MB" "$JOB_MEMORY_MB")"
members=($(python3 - "$WS" <<'PY'
import re,sys
m=re.search(r'members\s*=\s*\[(.*?)\]',open(sys.argv[1]).read(),re.S)
print('\n'.join(re.findall(r'"([^"]+)"',m.group(1))) if m else '')
PY
))
fail=0; id=0
for m in "${members[@]}"; do
  [[ "$m" == li-demo ]] && continue
  p="$ROOT/packages/$m/src/lib.li"
  [[ -f "$p" ]] || continue
  if [[ "$WS_JOBS" -le 1 ]]; then
    "$LIC" build "$p" -o /dev/null || fail=$((fail+1))
  else
    while [[ $(jobs -pr | wc -l) -ge $WS_JOBS ]]; do sleep 0.05; done
    b="$BUILD_ROOT/li-ws-$id"; mkdir -p "$b/generated"
    ("$LIC" build --build-dir="$b" "$p" -o /dev/null && echo 0 >"$b.rc" || echo 1 >"$b.rc") &
    id=$((id+1))
  fi
done
wait || true
for ((i=0;i<id;i++)); do [[ -f "$BUILD_ROOT/li-ws-$i.rc" && $(cat "$BUILD_ROOT/li-ws-$i.rc") == 0 ]] || fail=$((fail+1)); done
[[ $fail -eq 0 ]] || exit 1
echo "lic-workspace-build: ok (jobs=$WS_JOBS)"
