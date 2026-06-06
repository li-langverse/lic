#!/usr/bin/env bash
# PH-8p-c (#525): lic build --jobs=N drives parallel LLVM emit Pass 2.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export LI_REPO_ROOT="$ROOT"
LIC="${LIC:-$("$ROOT/scripts/resolve-lic.sh")}"
HTTPD_LIB="$ROOT/packages/li-net-httpd/src/lib.li"
BUILD_DIR="$ROOT/build/li-test-compile-jobs-$$"
trap 'rm -rf "$BUILD_DIR"' EXIT
mkdir -p "$BUILD_DIR/generated"

if [[ ! -f "$HTTPD_LIB" ]]; then
  echo "compile_jobs_httpd_smoke: skip (no $HTTPD_LIB)"
  exit 0
fi

wall_s() {
  local start end
  start="$(date +%s.%N)"
  "$@"
  end="$(date +%s.%N)"
  awk -v s="$start" -v e="$end" 'BEGIN { printf "%.3f", e - s }'
}

BUILD_FLAGS=(--allow-open-vc --no-lean-verify --build-dir="$BUILD_DIR")

"$LIC" build "$HTTPD_LIB" -o /dev/null "${BUILD_FLAGS[@]}" --jobs=1 >/dev/null
"$LIC" build "$HTTPD_LIB" -o /dev/null "${BUILD_FLAGS[@]}" --jobs=4 >/dev/null

cores="$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
if [[ "$cores" -ge 8 || "${LI_COMPILE_JOBS_BENCH:-}" == "1" ]]; then
  t1="$(wall_s "$LIC" build "$HTTPD_LIB" -o /dev/null "${BUILD_FLAGS[@]}" --jobs=1)"
  t4="$(wall_s "$LIC" build "$HTTPD_LIB" -o /dev/null "${BUILD_FLAGS[@]}" --jobs=4)"
  ratio="$(awk -v a="$t4" -v b="$t1" 'BEGIN { if (b <= 0) print 1; else print a / b }')"
  echo "compile_jobs_httpd_smoke: wall_s jobs=1=$t1 jobs=4=$t4 ratio=$ratio cores=$cores"
  if [[ "${LI_COMPILE_JOBS_BENCH:-}" == "1" ]]; then
    awk -v r="$ratio" 'BEGIN { exit (r <= 0.75 ? 0 : 1) }' || {
      echo "compile_jobs_httpd_smoke: expected jobs=4 wall <= 75% of jobs=1 (ratio=$ratio)" >&2
      exit 1
    }
  elif awk -v r="$ratio" 'BEGIN { exit (r <= 0.75 ? 0 : 1) }'; then
    echo "compile_jobs_httpd_smoke: speedup gate ok (ratio=$ratio)"
  else
    echo "compile_jobs_httpd_smoke: note: ratio=$ratio > 0.75 (log only; set LI_COMPILE_JOBS_BENCH=1 to enforce)"
  fi
else
  echo "compile_jobs_httpd_smoke: ok (builds only; bench skipped on cores=$cores)"
fi

echo "compile_jobs_httpd_smoke: ok"
