#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
test -f "$ROOT/packages/li-libernetes-apiserver/li.toml"
test -f "$ROOT/packages/li-libernetes-kubelet/li.toml"
echo "libernetes control packages gate: OK"
