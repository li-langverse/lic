#!/bin/sh
# Content-Length accounting: body_left tracks consumed bytes exactly.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)
ORACLE=/tmp/proxy_relay_oracle
if [ ! -x "$ORACLE" ]; then
  LIC=${LIC:-$ROOT/build/lic}
  [ -x "$LIC" ] || LIC=$ROOT/lic
  "$LIC" build "$ROOT/li-tests/httpd/proxy_relay_oracle.li" -o "$ORACLE"
fi
"$ORACLE"
