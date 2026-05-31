#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
if [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  echo "wp3-export-math: lic binary present; export-math CLI pending"
  exit 0
fi
echo "wp3-export-math: pending (no lic build)"
exit 1
