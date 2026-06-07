#!/usr/bin/env bash
# m15-inference-live: OpenAI /v1 routes on live li-httpd — rate limits, OTel traceparent, cancel-on-disconnect.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HTTPD="${LI_HTTPD_BIN:-$ROOT/build/li-httpd}"
CFG="${INFERENCE_LIVE_CFG:-$ROOT/packages/li-net-httpd/examples/inference_live.toml}"
CONF="/tmp/httpd-inference-live.conf"
PUBLIC="$(cd "$ROOT/packages/li-net-httpd/examples" && mkdir -p public && pwd)/public"
BE_PORT=18131
FRONT_PORT=18130
CANCEL_MARK="/tmp/httpd-m15-inference-cancel.ok"

curl_http_code() {
  local out
  out=$(curl -s "$@" -o /dev/null -w "%{http_code}" || true)
  if [[ -z "$out" ]]; then
    echo "000"
  else
    echo "$out"
  fi
}

if [[ ! -x "$HTTPD" ]]; then
  echo "test-m15-inference-live: build li-httpd first (./scripts/build-li-httpd.sh)" >&2
  exit 1
fi

mkdir -p "$PUBLIC"
echo ok > "$PUBLIC/index.html"
rm -f "$CANCEL_MARK"

python3 "$ROOT/scripts/validate-httpd-config.py" "$CFG"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$CFG" -o "$CONF"
grep -q '^listen_port=18130' "$CONF"
grep -q '^upstream_peer=18131' "$CONF"
grep -q 'route_require=POST|/v1/chat/completions|traceparent' "$CONF"

INFERENCE_BACKEND="${INFERENCE_NATIVE_BACKEND:-$ROOT/build/inference-native-backend}"
if [[ ! -x "$INFERENCE_BACKEND" ]]; then
  bash "$ROOT/scripts/build-inference-native-backend.sh"
fi
[[ -x "$INFERENCE_BACKEND" ]] || { echo "test-m15-inference-live: build inference-native-backend first" >&2; exit 1; }
python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"

fuser -k "${BE_PORT}/tcp" "${FRONT_PORT}/tcp" 2>/dev/null || true
pkill -f 'httpd-inference-live' 2>/dev/null || true
pkill -f '[/]li-httpd.*httpd-inference-live' 2>/dev/null || true
pkill -f 'inference-native-backend' 2>/dev/null || true
sleep 0.5

( cd "$ROOT" && "$INFERENCE_BACKEND" "$BE_PORT" "$CANCEL_MARK" ) >/dev/null 2>&1 &
BE_PID=$!
for _ in $(seq 1 20); do
  if curl_http_code -m 1 -X POST "http://127.0.0.1:${BE_PORT}/v1/chat/completions" \
    -H "Content-Type: application/json" -d '{}' | grep -q '^200$'; then
    break
  fi
  sleep 0.1
done

LI_HTTPD_WORKERS=1 "$HTTPD" "$CONF" >/dev/null 2>&1 &
FE_PID=$!
sleep 2.0

# Cancel-on-disconnect first (rate bucket still full).
rm -f "$CANCEL_MARK" "${CANCEL_MARK}.started"
cancel_code=$(curl_http_code -N -m 0.6 \
  -X POST "http://127.0.0.1:${FRONT_PORT}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -H "traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01" \
  -d '{}')
sleep 2.0
cancel_ok=0
if [[ -f "${CANCEL_MARK}.started" && -f "$CANCEL_MARK" ]]; then
  cancel_ok=1
fi

# Li-native path: restart edge + upstream after SSE cancel-on-disconnect probe.
kill "$FE_PID" "$BE_PID" 2>/dev/null || true
pkill -f 'inference-native-backend' 2>/dev/null || true
sleep 0.3
( cd "$ROOT" && "$INFERENCE_BACKEND" "$BE_PORT" "$CANCEL_MARK" ) >/dev/null 2>&1 &
BE_PID=$!
for _ in $(seq 1 20); do
  if curl_http_code -m 1 -X POST "http://127.0.0.1:${BE_PORT}/v1/chat/completions" \
    -H "Content-Type: application/json" -d '{}' | grep -q '^200$'; then
    break
  fi
  sleep 0.1
done
LI_HTTPD_WORKERS=1 "$HTTPD" "$CONF" >/dev/null 2>&1 &
FE_PID=$!
sleep 1.5

code_no_tp=$(curl_http_code -m 3 \
  -X POST "http://127.0.0.1:${FRONT_PORT}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4","messages":[]}')

code_ok=$(curl_http_code -m 3 \
  -X POST "http://127.0.0.1:${FRONT_PORT}/v1/chat/completions" \
  -H "Content-Type: application/json" \
  -H "traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01" \
  -d '{"model":"gpt-4","messages":[]}')

got_429=0
for _ in $(seq 1 24); do
  c=$(curl_http_code -m 2 \
    -X POST "http://127.0.0.1:${FRONT_PORT}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "traceparent: 00-4bf92f3577b34da6a3ce929d0e0e4736-00f067aa0ba902b7-01" \
    -d '{"model":"gpt-4","messages":[]}')
  if [[ "$c" == "429" ]]; then
    got_429=1
    break
  fi
done

kill "$FE_PID" "$BE_PID" 2>/dev/null || true
pkill -f 'inference-native-backend' 2>/dev/null || true
pkill -f 'httpd-inference-live' 2>/dev/null || true
wait "$FE_PID" 2>/dev/null || true
wait "$BE_PID" 2>/dev/null || true

fail=0
if [[ "$code_no_tp" != "400" ]]; then
  echo "test-m15-inference-live: FAIL missing traceparent expected 400 got $code_no_tp" >&2
  fail=1
fi
if [[ "$code_ok" != "200" ]]; then
  echo "test-m15-inference-live: FAIL with traceparent expected 200 got $code_ok" >&2
  fail=1
fi
if [[ "$got_429" -ne 1 ]]; then
  echo "test-m15-inference-live: FAIL expected 429 from rate limit" >&2
  fail=1
fi
if [[ "$cancel_ok" -ne 1 ]]; then
  echo "test-m15-inference-live: FAIL client disconnect did not cancel upstream SSE (curl=$cancel_code)" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi
echo "test-m15-inference-live: ok (Li-native backend, OTel 400/200, rate limit 429, cancel-on-disconnect)"
