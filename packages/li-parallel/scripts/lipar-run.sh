#!/usr/bin/env bash
# Multi-node launcher (zero MPI install) — sets LI_DPAR_* and execs binary.
set -euo pipefail
HOSTS=""
WORLD=""
PORT="${LI_DPAR_PORT:-29500}"
BIN=""

usage() {
  echo "Usage: lipar-run.sh --hosts h1,h2,... [--world N] [--port P] -- ./binary [args...]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hosts) HOSTS="${2:?}"; shift 2 ;;
    --world) WORLD="${2:?}"; shift 2 ;;
    --port) PORT="${2:?}"; shift 2 ;;
    --) shift; BIN="$1"; break ;;
    -h|--help) usage; exit 0 ;;
    *) BIN="$1"; break ;;
  esac
done

if [[ -z "$HOSTS" || -z "$BIN" ]]; then
  usage; exit 1
fi

IFS=',' read -r -a host_arr <<< "$HOSTS"
if [[ -z "$WORLD" ]]; then
  WORLD="${#host_arr[@]}"
fi

rank=0
pids=()
for ((rank=0; rank<WORLD; rank++)); do
  export LI_DPAR_RANK="$rank"
  export LI_DPAR_WORLD_SIZE="$WORLD"
  export LI_DPAR_HOSTS="$HOSTS"
  export LI_DPAR_PORT="$PORT"
  if [[ $rank -eq 0 ]]; then
    "$BIN" "${@:2}" &
    pids+=($!)
  else
    "$BIN" "${@:2}" &
    pids+=($!)
  fi
done
rc=0
for pid in "${pids[@]}"; do
  wait "$pid" || rc=1
done
exit "$rc"
