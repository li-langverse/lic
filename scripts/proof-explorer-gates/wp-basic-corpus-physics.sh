#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/wp-basic-corpus-common.sh" physics "${MIN_PHYSICS:-40}"
