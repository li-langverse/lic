#!/usr/bin/env bash
# M1.5 TLS auto: validate-config, setup-tls, flatten gates (Python).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"

echo "== tls good configs =="
python3 "$ROOT/scripts/httpd_config.py" "$ROOT/li-tests/config_desugar/good/tls_self_signed_dev.toml"
python3 "$ROOT/scripts/httpd_config.py" "$ROOT/li-tests/config_desugar/good/tls_lets_encrypt_staging.toml"

echo "== tls reject configs =="
for rej in \
  "$ROOT/li-tests/config_desugar/reject/tls_public_self_signed.toml" \
  "$ROOT/li-tests/config_desugar/reject/tls_public_no_tls.toml" \
  "$ROOT/li-tests/config_desugar/reject/tls_le_missing_email.toml"; do
  name="$(basename "$rej")"
  if python3 "$ROOT/scripts/httpd_config.py" "$rej" 2>/dev/null; then
    echo "expected reject: $name" >&2
    exit 1
  fi
  echo "$name: rejected OK"
done

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

echo "== setup-tls self_signed =="
python3 "$ROOT/scripts/setup-tls-httpd.py" \
  "$ROOT/li-tests/config_desugar/good/tls_self_signed_dev.toml" \
  -o "$work/certs-dev"
test -f "$work/certs-dev/fullchain.pem"
test -f "$work/certs-dev/privkey.pem"

echo "== setup-tls lets_encrypt staging (dry-run) =="
python3 "$ROOT/scripts/setup-tls-httpd.py" \
  "$ROOT/li-tests/config_desugar/good/tls_lets_encrypt_staging.toml" \
  -o "$work/certs-staging" \
  --dry-run
test -f "$work/certs-staging/acme-renewal.json"
test -f "$work/certs-staging/fullchain.pem"

echo "== setup-tls renew =="
python3 "$ROOT/scripts/setup-tls-httpd.py" \
  "$ROOT/li-tests/config_desugar/good/tls_lets_encrypt_staging.toml" \
  -o "$work/certs-staging" \
  --renew --dry-run

echo "== flatten tls_lets_encrypt_staging =="
tmp="$(mktemp)"
python3 "$ROOT/scripts/flatten-httpd-config.py" \
  "$ROOT/li-tests/config_desugar/good/tls_lets_encrypt_staging.toml" -o "$tmp"
grep -q 'tls_enabled=1' "$tmp"
grep -q 'tls_mode=lets_encrypt' "$tmp"
grep -q 'tls_le_email=ops@staging.example.com' "$tmp"
grep -q 'tls_acme_reserved_path=/.well-known/acme-challenge/' "$tmp"
rm -f "$tmp"

echo "== li-tests/tls_setup smoke =="
"$ROOT/li-tests/tls_setup/run_setup_tls.sh" "$work"


echo "== live curl smoke (self_signed Ed25519, legacy OpenSSL terminate) =="
if [[ "$(uname -s)" == "Linux" ]]; then
  [[ -x "$ROOT/build/li-httpd" ]] || "$ROOT/scripts/build-li-httpd.sh"
  if [[ -x "$ROOT/build/li-httpd" ]]; then
  curl_port="$(python3 - <<'PY'
import socket
s = socket.socket()
s.bind(("127.0.0.1", 0))
print(s.getsockname()[1])
s.close()
PY
)"
  curl_work="$(mktemp -d)"
  curl_cert="$curl_work/certs"
  curl_pub="$curl_work/public"
  curl_conf="$curl_work/runtime.conf"
  curl_log="$curl_work/httpd.log"
  mkdir -p "$curl_cert" "$curl_pub"
  echo ok > "$curl_pub/health"
  python3 "$ROOT/scripts/setup-tls-httpd.py" \
    "$ROOT/packages/li-net-httpd/examples/tls_h2.toml" \
    --cert-dir "$curl_cert"
  python3 "$ROOT/scripts/flatten-httpd-config.py" \
    "$ROOT/packages/li-net-httpd/examples/tls_h2.toml" -o "$curl_conf"
  sed -i "s|^tls_cert_dir=.*|tls_cert_dir=${curl_cert}|" "$curl_conf"
  sed -i "s|^document_root=.*|document_root=${curl_pub}|" "$curl_conf"
  sed -i "s|^listen_port=.*|listen_port=${curl_port}|" "$curl_conf"
  LI_HTTPD_WORKERS=1 LI_HTTPD_TLS_LEGACY_OPENSSL=1 "$ROOT/build/li-httpd" "$curl_conf" >"$curl_log" 2>&1 &
  curl_pid=$!
  sleep 1.5
  if ! kill -0 "$curl_pid" 2>/dev/null; then
    echo "li-httpd failed to start (pid exited early)" >&2
    tail -n 120 "$curl_log" 2>/dev/null || true
    wait "$curl_pid" 2>/dev/null || true
    exit 1
  fi
  ok=0
  for _ in $(seq 1 20); do
    if curl -kfsS --http2 --max-time 3 "https://127.0.0.1:${curl_port}/health" 2>/dev/null | grep -q ok; then
      ok=1
      break
    fi
    if ! kill -0 "$curl_pid" 2>/dev/null; then
      echo "li-httpd exited during curl smoke" >&2
      tail -n 120 "$curl_log" 2>/dev/null || true
      break
    fi
    sleep 0.35
    if ! kill -0 "$curl_pid" 2>/dev/null; then
      break
    fi
  done
  if [[ "$ok" != "1" ]]; then
    echo "live curl smoke failed" >&2
    tail -n 120 "$curl_log" 2>/dev/null || true
    kill "$curl_pid" 2>/dev/null || true
    wait "$curl_pid" 2>/dev/null || true
    exit 1
  fi
  kill "$curl_pid" 2>/dev/null || true
  wait "$curl_pid" 2>/dev/null || true
  rm -rf "$curl_work"
  fi
fi

echo "check-httpd-tls-auto: OK"
