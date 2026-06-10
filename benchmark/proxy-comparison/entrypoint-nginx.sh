#!/bin/sh
set -eu
export NGINX_PROXY_BUFFERING="${NGINX_PROXY_BUFFERING:-on}"
envsubst '${NGINX_PROXY_BUFFERING}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf
exec nginx -g 'daemon off;'
