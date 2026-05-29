#!/usr/bin/env bash
# Cursor afterFileEdit — remind agents to update PH-ML tracker when touching ML/GPU paths.
set -euo pipefail
input="$(cat)"
path="$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" 2>/dev/null || true)"
case "$path" in
  packages/li-ml/*|packages/li-ml-rl/*|packages/lig/*|compiler/*)
    echo "PH-ML/GPU edit: update docs/game-dev/PH-ML-GPU-execution-tracker.md (WP id, verify, blocker); no fake GPU/PyTorch claims" >&2
    ;;
esac
exit 0
