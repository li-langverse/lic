#!/usr/bin/env bash
# lillm import — minimal HF→safetensors scaffold (Wave 10 WP-LLM-07).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL_ID="${1:-}"
OUT_DIR="${2:-$ROOT/packages/li-llm/fixtures/imported}"
if [[ -z "$MODEL_ID" ]]; then
  echo "usage: lillm-import.sh <hf-model-id> [out-dir]" >&2
  echo "example: lillm-import.sh meta-llama/Llama-3.2-1B" >&2
  exit 1
fi
mkdir -p "$OUT_DIR"
cat >"$OUT_DIR/manifest.json" <<EOF
{"source":"huggingface","model_id":"$MODEL_ID","format":"safetensors_scaffold","wave":10}
EOF
echo "lillm-import: wrote scaffold manifest to $OUT_DIR (full HF download deferred)"
