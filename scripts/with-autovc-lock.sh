#!/usr/bin/env bash
# Serialize lic builds that write build/generated/AutoVC.lean (parallel run_all races).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/build/generated"
exec 9>"$ROOT/build/generated/.autovc.lock"
if ! flock -w 600 9; then
  echo "with-autovc-lock: timeout waiting for AutoVC lock" >&2
  exit 1
fi
export LI_AUTOVC_LOCK_HELD=1
"$@"
