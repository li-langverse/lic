#!/usr/bin/env bash
# WP-CL: claim ledger schema present.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
test -f proof-db/research-claims/schema.toml
test -d proof-db/research-claims
echo "wp-claim-ledger: schema OK"
