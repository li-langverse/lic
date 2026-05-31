#!/usr/bin/env bash
set -euo pipefail
# WP-K8: deployment manifest exists locally; cluster check optional.
LIC_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

resolve_agents_root() {
  if [[ -n "${LI_CURSOR_AGENTS_ROOT:-}" && -d "$LI_CURSOR_AGENTS_ROOT" ]]; then
    echo "$LI_CURSOR_AGENTS_ROOT"
    return 0
  fi
  local candidate
  for candidate in \
    "$LIC_ROOT/../li-cursor-agents" \
    "$LIC_ROOT/../../li-cursor-agents" \
    "$(cd "$LIC_ROOT/../.." && pwd)/li-cursor-agents"; do
    if [[ -d "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

AGENTS_ROOT="$(resolve_agents_root || true)"
if [[ -z "${AGENTS_ROOT:-}" ]]; then
  echo "wp-k8-deploy: missing li-cursor-agents (set LI_CURSOR_AGENTS_ROOT)" >&2
  exit 1
fi

test -f "$AGENTS_ROOT/deploy/k8s/engine/deployment-proof-explorer.yaml"
test -f "$AGENTS_ROOT/src/cli/proof-explorer-worker.ts"
echo "wp-k8-deploy: manifests and worker CLI present ($AGENTS_ROOT)"
