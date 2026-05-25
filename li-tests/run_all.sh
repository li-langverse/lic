#!/usr/bin/env bash
# Run all li-tests suites or one suite by name.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
export LI_REPO_ROOT="${LI_REPO_ROOT:-$REPO}"
# shellcheck source=../scripts/lib/li-ui.sh
source "$REPO/scripts/lib/li-ui.sh"
# shellcheck source=../scripts/lib/li-jobs.sh
source "$REPO/scripts/lib/li-jobs.sh"
if [[ -z "${LIC:-}" ]]; then
  LIC="$("$REPO/scripts/resolve-lic.sh")"
fi
NULL_OUT="/dev/null"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;;
esac
FILTER="${1:-all}"
CI="${CI:-false}"
TEST_JOBS="$(li_test_jobs)"

usage_run_all() {
  echo "usage: $0 [--ci] [-j N] [suite|all]" >&2
  echo "  LI_TEST_JOBS — parallel manifest workers (default 1; host cores when CI=true)" >&2
  echo "  Each worker uses isolated LI_BUILD_DIR under build/li-test-<id>/" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -j|--jobs)
      TEST_JOBS="${2:?-j requires a job count}"
      shift 2
      ;;
    -j*)
      TEST_JOBS="${1#-j}"
      shift
      ;;
    --ci)
      CI=true
      FILTER="all"
      shift
      ;;
    -h|--help)
      usage_run_all
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ "${1:-}" == "--ci" ]]; then
  CI=true
  FILTER="all"
  shift || true
fi
if [[ -n "${1:-}" ]]; then
  FILTER="$1"
fi

if [[ "$FILTER" == "hpc_competitive" ]]; then
  chmod +x "$REPO/li-tests/tooling/hpc_competitive_registry.sh"
  "$REPO/li-tests/tooling/hpc_competitive_registry.sh"
  exit $?
fi

if [[ ! -x "$LIC" ]]; then
  echo "li-tests: skip (lic not executable at $LIC)"
  exit 0
fi

if command -v lake >/dev/null 2>&1 && [[ -z "${LI_PROVE_LEAN_LAKE_OK:-}" ]]; then
  if (cd "$REPO/docs/semantics" && lake build AutoVC >/dev/null 2>&1); then
    export LI_PROVE_LEAN_LAKE_OK=1
  fi
fi

pass=0
fail=0
skip=0

li_autovc_path() {
  if [[ -n "${LI_BUILD_DIR:-}" ]]; then
    echo "${LI_BUILD_DIR}/generated/AutoVC.lean"
  else
    echo "$REPO/build/generated/AutoVC.lean"
  fi
}

run_one() {
  local suite="$1" file="$2" outcome="$3" substr="${4:-}"

  local path="$ROOT/$file"
  if [[ ! -f "$path" ]]; then
    li_test_skip "missing $file"
    return 2
  fi

  local exp_file="${path%.li}.exp"
  if [[ -f "$exp_file" ]]; then
    substr="$(head -1 "$exp_file")"
  fi

  case "$outcome" in
    parse_ok)
      if "$LIC" parse "$path" >/dev/null 2>&1; then
        li_test_pass "parse_ok $file"
        return 0
      fi
      li_test_fail "parse_ok $file"
      return 1
      ;;
    parse_fail)
      if "$LIC" parse "$path" >/dev/null 2>&1; then
        li_test_fail "parse_fail $file (should reject)"
        return 1
      fi
      li_test_pass "parse_fail $file"
      return 0
      ;;
    compile_ok|verify_ok)
      if "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "$outcome $file"
        return 0
      fi
      li_test_fail "$outcome $file"
      return 1
      ;;
    prove_lean_ok)
      local autovc
      autovc="$(li_autovc_path)"
      if ! "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_fail "prove_lean_ok $file (lic build)"
        return 1
      fi
      chmod +x "$REPO/scripts/check-autovc-open-goals.sh"
      if ! "$REPO/scripts/check-autovc-open-goals.sh" "$autovc" 2>/dev/null; then
        li_test_fail "prove_lean_ok $file (open AutoVC goals)"
        return 1
      fi
      if command -v lake >/dev/null 2>&1; then
        if [[ -n "${LI_PROVE_LEAN_LAKE_OK:-}" ]]; then
          li_test_pass "prove_lean_ok $file"
          return 0
        fi
        li_test_fail "prove_lean_ok $file (lake build AutoVC)"
        return 1
      fi
      li_test_skip "prove_lean_ok $file (lake not installed)"
      return 2
      ;;
    prove_lean_ok)
      # G-test-verify: strict lic build + zero open AutoVC goals + lake AutoVC when installed.
      local autovc="$REPO/build/generated/AutoVC.lean"
      if ! "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_fail "prove_lean_ok $file (lic build)"
        fail=$((fail + 1))
        return
      fi
      chmod +x "$REPO/scripts/check-autovc-open-goals.sh"
      if ! "$REPO/scripts/check-autovc-open-goals.sh" "$autovc" 2>/dev/null; then
        li_test_fail "prove_lean_ok $file (open AutoVC goals)"
        fail=$((fail + 1))
        return
      fi
      if command -v lake >/dev/null 2>&1; then
        if [[ -z "${LI_PROVE_LEAN_LAKE_OK:-}" ]]; then
          if (cd "$REPO/docs/semantics" && lake build AutoVC >/dev/null 2>&1); then
            export LI_PROVE_LEAN_LAKE_OK=1
          else
            li_test_fail "prove_lean_ok $file (lake build AutoVC)"
            fail=$((fail + 1))
            return
          fi
        fi
        li_test_pass "prove_lean_ok $file"
        pass=$((pass + 1))
      else
        li_test_skip "prove_lean_ok $file (lake not installed)"
        skip=$((skip + 1))
      fi
      ;;
    compile_open_ok)
      if "$LIC" build --allow-open-vc "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "compile_open_ok $file"
        return 0
      fi
      li_test_fail "compile_open_ok $file"
      return 1
      ;;
    verify_open_ok)
      local open_flags=(--allow-open-vc)
      case "$file" in
        httpd/*|composable/import_httpd_lib.li|routing/*)
          open_flags+=(--no-lean-verify)
          ;;
      esac
      if "$LIC" build "${open_flags[@]}" "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "verify_open_ok $file"
        return 0
      fi
      li_test_fail "verify_open_ok $file"
      return 1
      ;;
    compile_fail|verify_fail)
      local err
      err="$("$LIC" build "$path" -o "$NULL_OUT" 2>&1)" || true
      if "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_fail "$outcome $file (should reject)"
        return 1
      fi
      if [[ -n "$substr" ]] && ! echo "$err" | grep -qi "$substr"; then
        li_test_fail "$outcome $file (missing expected substring: $substr)"
        return 1
      fi
      li_test_pass "$outcome $file"
      return 0
      ;;
    *)
      echo "unknown outcome $outcome for $file"
      return 1
      ;;
  esac
}

run_one_worker() {
  local id="$1" suite="$2" file="$3" outcome="$4" substr="${5:-}"
  export LI_BUILD_DIR="$REPO/build/li-test-$id"
  mkdir -p "$LI_BUILD_DIR/generated"
  local log
  log="$(mktemp "${TMPDIR:-/tmp}/li-test-${id}.XXXX")"
  set +e
  run_one "$suite" "$file" "$outcome" "$substr" >"$log" 2>&1
  local rc=$?
  set -e
  cat "$log"
  rm -f "$log"
  return "$rc"
}

collect_manifest_rows() {
  local rows_file="$1"
  : >"$rows_file"
  local cur_suite="" cur_file="" cur_outcome="" cur_substr=""
  while IFS= read -r line; do
    if [[ "$line" == "[[tests]]" ]]; then
      if [[ -n "${cur_file:-}" && -n "${cur_outcome:-}" ]]; then
        if [[ "$FILTER" == "all" || "$FILTER" == "$cur_suite" ]]; then
          printf '%s\t%s\t%s\t%s\n' "$cur_suite" "$cur_file" "$cur_outcome" "${cur_substr:-}" >>"$rows_file"
        fi
      fi
      cur_suite="" cur_file="" cur_outcome="" cur_substr=""
      continue
    fi
    [[ "$line" =~ ^suite\ =\ \"(.*)\"$ ]] && cur_suite="${BASH_REMATCH[1]}" && continue
    [[ "$line" =~ ^file\ =\ \"(.*)\"$ ]] && cur_file="${BASH_REMATCH[1]}" && continue
    [[ "$line" =~ ^outcome\ =\ \"(.*)\"$ ]] && cur_outcome="${BASH_REMATCH[1]}" && continue
    [[ "$line" =~ ^expected_substr\ =\ \"(.*)\"$ ]] && cur_substr="${BASH_REMATCH[1]}" && continue
  done <"$ROOT/manifest.toml"
  if [[ -n "${cur_file:-}" && -n "${cur_outcome:-}" ]]; then
    if [[ "$FILTER" == "all" || "$FILTER" == "$cur_suite" ]]; then
      printf '%s\t%s\t%s\t%s\n' "$cur_suite" "$cur_file" "$cur_outcome" "${cur_substr:-}" >>"$rows_file"
    fi
  fi
}

run_sequential() {
  local rows_file="$1"
  while IFS=$'\t' read -r suite file outcome substr; do
    [[ -z "$suite" ]] && continue
    set +e
    run_one "$suite" "$file" "$outcome" "$substr"
    local rc=$?
    set -e
    case "$rc" in
      0) pass=$((pass + 1)) ;;
      2) skip=$((skip + 1)) ;;
      *) fail=$((fail + 1)) ;;
    esac
  done <"$rows_file"
}

run_parallel() {
  local rows_file="$1" jobs="$2"
  local id=0
  while IFS=$'\t' read -r suite file outcome substr; do
    [[ -z "$suite" ]] && continue
    while [[ "$(jobs -pr | wc -l | tr -d ' ')" -ge "$jobs" ]]; do
      sleep 0.05
    done
    (
      run_one_worker "$id" "$suite" "$file" "$outcome" "$substr"
      echo $? >"$REPO/build/li-test-$id.rc"
    ) &
    id=$((id + 1))
  done <"$rows_file"
  wait || true
  local i=0
  while [[ "$i" -lt "$id" ]]; do
    if [[ -f "$REPO/build/li-test-$i.rc" ]]; then
      case "$(cat "$REPO/build/li-test-$i.rc")" in
        0) pass=$((pass + 1)) ;;
        2) skip=$((skip + 1)) ;;
        *) fail=$((fail + 1)) ;;
      esac
      rm -f "$REPO/build/li-test-$i.rc"
    else
      fail=$((fail + 1))
    fi
    i=$((i + 1))
  done
}

ROWS="$(mktemp "${TMPDIR:-/tmp}/li-manifest-rows.XXXX")"
collect_manifest_rows "$ROWS"
if [[ "$TEST_JOBS" -le 1 ]]; then
  unset LI_BUILD_DIR
  run_sequential "$ROWS"
else
  echo "li-tests: parallel jobs=$TEST_JOBS (isolated LI_BUILD_DIR per worker)" >&2
  run_parallel "$ROWS" "$TEST_JOBS"
fi
rm -f "$ROWS"

echo "--- li-tests: pass=$pass fail=$fail skip=$skip jobs=$TEST_JOBS"
li_tests_footer "$pass" "$fail" "$skip"
[[ "$fail" -eq 0 ]]
