#!/usr/bin/env bash
set -euo pipefail
# WP-K8: deployment manifest exists locally; cluster check optional.
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
test -f "$ROOT/li-cursor-agents/deploy/k8s/engine/deployment-proof-explorer.yaml"
test -f "$ROOT/li-cursor-agents/src/cli/proof-explorer-worker.ts"
echo "wp-k8-deploy: manifests and worker CLI present"
