#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "== m4-benchmark-matrix-gate =="
for s in bench_crypto_validity.py bench_tls_validity.py check-tier5-crypto-exploits.sh; do
  if [[ ! -f "$ROOT/scripts/$s" ]]; then
    echo "pending: $s not yet implemented"
    exit 1
  fi
done
bash "$ROOT/scripts/check-tier5-crypto-exploits.sh"
echo "m4-benchmark-matrix-gate: OK"