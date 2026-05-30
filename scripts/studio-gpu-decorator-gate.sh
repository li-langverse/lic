#!/usr/bin/env bash
# Studio GPU decorator sprint completion gate (Git Bash -> WSL build-wsl, else native build).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

strip_crlf() {
  while IFS= read -r -d '' f; do
    sed -i 's/\r$//' "$f" 2>/dev/null || true
  done < <(find li-tests scripts/lib scripts -maxdepth 2 -name '*.sh' -print0 2>/dev/null)
}

run_gate() {
  local lic="$1"
  test -x "$lic" || { echo "lic not executable: $lic"; return 1; }
  strip_crlf
  export LIC="$lic"
  bash li-tests/run_all.sh decorators decorator_exploits
  echo "studio-gpu-decorator: completion gate OK"
}

LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
if [[ -x "$LIC" ]]; then
  run_gate "$LIC"
  exit 0
fi
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  run_gate "$ROOT/build-wsl/compiler/lic/lic"
  exit 0
fi
if command -v wsl >/dev/null 2>&1 && ! grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
  WSL_LIC="/mnt/c/Users/Julian/Documents/Programming/li/lic/build-wsl/compiler/lic/lic"
  wsl bash -lc "test -x '$WSL_LIC' || { echo 'WSL build missing — cmake -B build-wsl in WSL'; exit 1; }; cd /mnt/c/Users/Julian/Documents/Programming/li/lic && LIC='$WSL_LIC' bash scripts/studio-gpu-decorator-gate.sh"
  exit $?
fi
echo "build lic first: ./scripts/build.sh (or WSL build-wsl)"
exit 1