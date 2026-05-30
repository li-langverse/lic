#!/usr/bin/env bash
# G-net / G-trust: httpd_li_proxy_* seam omits raises Net while C handlers do recv/send.
# tcp_listen control (seam_missing_net.li) correctly rejects missing Net on caller.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
GAP="$ROOT/li-tests/net_trusted/seam_proxy_epoll_missing_net.li"
CONTROL="$ROOT/li-tests/net_trusted/seam_missing_net.li"

if ! "$LIC" check "$GAP" >/dev/null 2>&1; then
  echo "seam_proxy_net_effect_gap: proxy specimen must pass lic check while gap open"
  exit 1
fi

if "$LIC" check "$CONTROL" >/dev/null 2>&1; then
  echo "seam_proxy_net_effect_gap: seam_missing_net must fail (tcp_listen Net propagation)"
  exit 1
fi

echo "seam_proxy_net_effect_gap: ok (documented G-net trusted-seam effect omission)"
