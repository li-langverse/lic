#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-scheduler/li.toml"
test -f "$ROOT/packages/li-libernetes-scheduler/src/lib.li"
test -f "$ROOT/packages/li-libernetes-apiserver/src/serve.li"
grep -q 'li-libernetes-scheduler' "$ROOT/scripts/libernetes-doctor.sh"
echo "libernetes control wave2 gate: OK"
