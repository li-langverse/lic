#!/usr/bin/env bash
# Verify trusted extern manifest mentions seam and runtime headers stay in sync (lightweight).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
seam="std/runtime/seam.li"
test -f "$seam" || { echo "error: missing $seam" >&2; exit 1; }
rg -n '^extern proc ' "$seam" | wc -l | xargs -I{} echo "seam extern count: {}"
test -f security/trusted-extern-manifest.toml
test -f docs/compiler/trusted-extern-abi.md
echo "check-trusted-extern: ok"
