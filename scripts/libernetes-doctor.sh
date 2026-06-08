#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -d "$ROOT/docs/libernetes"
test -f "$ROOT/packages/li-libernetes-core/li.toml"
test -f "$ROOT/packages/li-libernetes-scheduler/li.toml"
test -f "$ROOT/packages/li-libernetes-apiserver/src/serve.li"
echo "libernetes doctor: OK (Wave 0–2 scaffolds present)"
