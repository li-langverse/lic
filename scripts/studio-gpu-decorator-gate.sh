#!/usr/bin/env bash
# Studio GPU decorator sprint completion gate (Git Bash -> WSL build-wsl, else native build).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

strip_crlf() {
  python3 - <<'PY' 2>/dev/null || true
from pathlib import Path
root = Path(".")
for pat in ["li-tests/**/*.sh", "scripts/lib/*.sh", "scripts/*.sh", "li-tests/manifest.toml"]:
    for p in root.glob(pat):
        if p.is_file():
            b = p.read_bytes()
            if b"\r\n" in b:
                p.write_bytes(b.replace(b"\r\n", b"\n"))
PY
}

run_gate() {
  local lic="$1"
  if [[ ! -f "$lic" ]]; then
    echo "lic not found: $lic"
    return 1
  fi
  strip_crlf
  export LIC="$lic"
  bash li-tests/run_all.sh decorators
  bash li-tests/run_all.sh decorator_exploits
  echo "studio-gpu-decorator: completion gate OK"
}

if [[ -f "$ROOT/build/compiler/lic/lic" ]]; then
  run_gate "$ROOT/build/compiler/lic/lic"
  exit 0
fi
if [[ -f "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  run_gate "$ROOT/build-wsl/compiler/lic/lic"
  exit 0
fi
if command -v wsl >/dev/null 2>&1 && ! grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null; then
  WSL_LIC="/mnt/c/Users/Julian/Documents/Programming/li/lic/build-wsl/compiler/lic/lic"
  wsl bash -lc "test -f '$WSL_LIC' || { echo 'WSL build missing — bash scripts/build.sh in WSL'; exit 1; }; cd /mnt/c/Users/Julian/Documents/Programming/li/lic && LIC='$WSL_LIC' bash scripts/studio-gpu-decorator-gate.sh"
  exit $?
fi
echo "build lic first: ./scripts/build.sh (or WSL build-wsl)"
exit 1
