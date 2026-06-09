#!/usr/bin/env bash
set -euo pipefail
RESOLVE="gitlab.lilangverse.xyz:443:192.168.10.33"
CSS="/assets/application-d9fbd7cb5325059aa5dd859be97da763569721107347c84973f86a22328889df.css"
EXP=835437
pass=0
for i in $(seq 1 10); do
  sign=$(curl -sk --http1.1 --no-keepalive --resolve "$RESOLVE" -o /dev/null -w '%{http_code}' "https://gitlab.lilangverse.xyz/users/sign_in" 2>/dev/null || echo 000)
  css=$(curl -sk --http1.1 --no-keepalive --resolve "$RESOLVE" -o /dev/null -w '%{size_download}' "https://gitlab.lilangverse.xyz${CSS}" 2>/dev/null || echo 0)
  ok=no
  case "$sign" in 200|302) [[ "$css" == "$EXP" ]] && ok=yes && pass=$((pass + 1)) ;; esac
  echo "run $i: sign=$sign css=$css ok=$ok"
  sleep 2
done
echo "RESULT wsl-openssl: ${pass}/10"
