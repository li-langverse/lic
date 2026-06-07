#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -d "$ROOT/docs/libernetes"
test -f "$ROOT/packages/li-libernetes-core/li.toml"
echo "libernetes doctor: OK (Wave 0 stubs present)"
