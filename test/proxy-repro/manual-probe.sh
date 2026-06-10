#!/bin/sh
set -eu
IP=$(docker inspect proxy-repro-proxy-1 --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
echo "proxy_ip=$IP"
curl -sk --resolve "repro.edge.test:8443:${IP}" -o /dev/null -w 'sign=%{http_code}\n' \
  "https://repro.edge.test:8443/users/sign_in"
curl -sk --resolve "repro.edge.test:8443:${IP}" -o /dev/null -w 'css=%{http_code} %{size_download}\n' \
  "https://repro.edge.test:8443/assets/application-deadbeef.css"
curl -sk --resolve "repro.edge.test:8443:${IP}" "https://repro.edge.test:8443/users/sign_in" | head -2
