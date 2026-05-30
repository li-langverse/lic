#!/usr/bin/env bash
# Run world-studio-plan-lic-smokes inside WSL (Windows Git Bash / plan gates).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if ! command -v wsl.exe >/dev/null 2>&1; then
  echo "world-studio-plan-lic-smokes-wsl: wsl.exe not found" >&2
  exit 1
fi
# Do not set MSYS_NO_PATHCONV for wslpath (it doubles /mnt/c/c/...).
smoke_wsl="$(wsl.exe wslpath -u "$ROOT/scripts/world-studio-plan-lic-smokes.sh" 2>/dev/null | tr -d '\r\n')"
[[ -n "$smoke_wsl" ]] || {
  echo "world-studio-plan-lic-smokes-wsl: wslpath failed for smokes script" >&2
  exit 1
}
# Outer single quotes: avoid Git Bash mangling bash -c when MSYS rewrites /mnt/c paths.
MSYS2_ARG_CONV_EXCL='*' MSYS_NO_PATHCONV=1 wsl.exe bash -c 'bash '"$smoke_wsl"
