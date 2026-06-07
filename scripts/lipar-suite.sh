#!/usr/bin/env bash
exec "$(cd "$(dirname "$0")/.." && pwd)/packages/li-parallel/scripts/lipar-suite.sh" "$@"
