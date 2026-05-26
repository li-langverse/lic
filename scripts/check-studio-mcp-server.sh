#!/usr/bin/env bash
# PH-AGENT-2 — build MCP stdio server + run integration smoke.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 "$ROOT/li-tests/tooling/studio_mcp_server_smoke.py"
