#!/usr/bin/env bash
# MCP stdio JSON-RPC stub for `lis mcp li-engine` (PH-AGENT-1 scaffold).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DISPATCH="$ROOT/scripts/studio-mcp-lis-dispatch.sh"
export STUDIO_MCP_LIS_ROOT="$ROOT"
exec python3 "$ROOT/scripts/studio-mcp-lis-stub.py" "$DISPATCH"
