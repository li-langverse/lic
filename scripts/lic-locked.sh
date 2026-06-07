#!/usr/bin/env bash
# Run built lic under the AutoVC file lock (see with-autovc-lock.sh).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
exec "$ROOT/scripts/with-autovc-lock.sh" "$("$ROOT/scripts/resolve-lic.sh")" "$@"
