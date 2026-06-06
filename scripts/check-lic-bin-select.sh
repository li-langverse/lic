#!/usr/bin/env bash
# Regression: isolated agent clones must not inherit sibling LIC= paths.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/lic-bin-select.sh
source "$ROOT/scripts/lib/lic-bin-select.sh"

li_lic_under_root "$ROOT" "$ROOT/build/compiler/lic/lic" \
  || { echo "check-lic-bin-select: expected local lic under root"; exit 1; }

li_lic_under_root "$ROOT" "/workspace/lic/build/compiler/lic/lic" \
  && { echo "check-lic-bin-select: sibling LIC= must be rejected"; exit 1; }

echo "check-lic-bin-select: ok"
