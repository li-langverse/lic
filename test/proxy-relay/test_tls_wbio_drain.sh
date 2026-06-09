#!/bin/sh
# wbio/defer: relay must stay pending until CL defer drained.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
ORACLE=/tmp/proxy_relay_oracle
if [ ! -x "$ORACLE" ]; then
  LIC=${LIC:-$ROOT/build/lic}
  [ -x "$LIC" ] || LIC=$ROOT/lic
  "$LIC" build "$ROOT/li-tests/httpd/proxy_relay_oracle.li" -o "$ORACLE"
fi
"$ORACLE"
