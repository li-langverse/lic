#!/usr/bin/env bash
set -euo pipefail
"$(cd "$(dirname "$0")" && pwd)/sync-agent-kit.sh" --check
