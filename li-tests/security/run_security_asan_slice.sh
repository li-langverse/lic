#!/usr/bin/env bash
# ASan smoke on native runtime seams touched by httpd security work (sec-r3).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ "${LI_SECURITY_ASAN:-0}" != "1" ]]; then
  echo "run_security_asan_slice: skip (LI_SECURITY_ASAN!=1)"
  exit 0
fi

cc="${CC:-clang}"
if ! command -v "$cc" >/dev/null 2>&1; then
  echo "run_security_asan_slice: skip (no C compiler)"
  exit 0
fi

out="$ROOT/build/bench/security_asan_slice"
mkdir -p "$(dirname "$out")"
driver="$(mktemp -t li_http_asan.XXXXXX.c)"
trap 'rm -f "$driver"' EXIT

cat >"$driver" <<'EOF'
#include "li_rt.h"
#include <string.h>

int main(void) {
  const char* req = "GET / HTTP/1.1\r\nHost: localhost\r\n\r\n";
  (void)li_rt_http_parse_request_len_tag(req, 8192, 65536);
  const char* bad = "OVERSIZED / HTTP/1.1\r\n\r\n";
  (void)li_rt_http_parse_request_len_tag(bad, 8192, 65536);
  return 0;
}
EOF

"$cc" -fsanitize=address -fno-omit-frame-pointer -g \
  -I"$ROOT/runtime" \
  "$driver" \
  "$ROOT/runtime/li_rt.c" \
  "$ROOT/runtime/li_par_pool.c" \
  -o "$out" -pthread

"$out"
echo "run_security_asan_slice: ok"
