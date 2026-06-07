#!/usr/bin/env bash
# lis mcp li-engine — stdio MCP entry (WP-AG-03). lis CLI will delegate here.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec python3 "${ROOT}/scripts/lis-mcp-li-engine.py" "$@"
