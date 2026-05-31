#!/usr/bin/env bash
# lillm import — HF→safetensors path (Wave 11 WP-LLM-07).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL_ID="${1:-}"
OUT_DIR="${2:-$ROOT/packages/li-llm/fixtures/imported}"
OFFLINE_ONLY="${LILLM_IMPORT_OFFLINE:-0}"
if [[ -z "$MODEL_ID" ]]; then
  echo "usage: lillm-import.sh <hf-model-id> [out-dir]" >&2
  echo "  LILLM_IMPORT_OFFLINE=1  skip network; write offline manifest only" >&2
  exit 1
fi
mkdir -p "$OUT_DIR"
MANIFEST="$OUT_DIR/manifest.json"
DOWNLOADED=0
if [[ "$OFFLINE_ONLY" == "1" ]]; then
  cat >"$MANIFEST" <<EOF
{"source":"offline","model_id":"$MODEL_ID","format":"safetensors_scaffold","wave":11,"download":"skipped"}
EOF
  echo "lillm-import: offline manifest at $MANIFEST"
  exit 0
fi
if command -v huggingface-cli >/dev/null 2>&1; then
  if huggingface-cli download "$MODEL_ID" --local-dir "$OUT_DIR/hf" --include "*.safetensors" 2>/dev/null; then
    DOWNLOADED=1
  fi
elif command -v hf >/dev/null 2>&1; then
  if hf download "$MODEL_ID" --local-dir "$OUT_DIR/hf" --include "*.safetensors" 2>/dev/null; then
    DOWNLOADED=1
  fi
fi
if [[ "$DOWNLOADED" == "1" ]]; then
  cat >"$MANIFEST" <<EOF
{"source":"huggingface","model_id":"$MODEL_ID","format":"safetensors","wave":11,"download":"ok","path":"$OUT_DIR/hf"}
EOF
  echo "lillm-import: downloaded weights under $OUT_DIR/hf"
else
  cat >"$MANIFEST" <<EOF
{"source":"huggingface","model_id":"$MODEL_ID","format":"safetensors_scaffold","wave":11,"download":"deferred"}
EOF
  echo "lillm-import: scaffold manifest at $OUT_DIR (HF CLI unavailable)"
fi
