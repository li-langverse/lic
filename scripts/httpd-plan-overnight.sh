#!/usr/bin/env bash
# Alias: continuous httpd plan loop.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/scripts/httpd-plan-continuous.sh"
