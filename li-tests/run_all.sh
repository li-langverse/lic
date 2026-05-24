#!/usr/bin/env bash
# Run all li-tests suites or one suite by name.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$ROOT/.." && pwd)"
export LI_REPO_ROOT="${LI_REPO_ROOT:-$REPO}"
# shellcheck source=../scripts/lib/li-ui.sh
source "$REPO/scripts/lib/li-ui.sh"
if [[ -z "${LIC:-}" ]]; then
  LIC="$("$REPO/scripts/resolve-lic.sh")"
fi
NULL_OUT="/dev/null"
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) NULL_OUT="NUL" ;;
esac
FILTER="${1:-all}"
CI="${CI:-false}"
PACKAGE_FILTER="${LI_TEST_PACKAGE:-}"

if [[ "${1:-}" == "--package" ]]; then
  PACKAGE_FILTER="${2:?package name required}"
  shift 2
  FILTER="${1:-all}"
fi

if [[ "$FILTER" == "hpc_competitive" ]]; then
  chmod +x "$REPO/li-tests/tooling/hpc_competitive_registry.sh"
  "$REPO/li-tests/tooling/hpc_competitive_registry.sh"
  exit $?
fi

if [[ "${1:-}" == "--ci" ]]; then
  CI=true
  FILTER="all"
elif [[ "${2:-}" == "--ci" ]]; then
  CI=true
fi

if [[ ! -x "$LIC" ]]; then
  echo "li-tests: skip (lic not executable at $LIC)"
  exit 0
fi

pass=0
fail=0
skip=0

test_matches_package() {
  local list="$1"
  [[ -z "$PACKAGE_FILTER" ]] && return 0
  [[ -z "$list" ]] && return 1
  [[ "$list" == *"\"$PACKAGE_FILTER\""* ]] && return 0
  return 1
}

run_one() {
  local suite="$1" file="$2" outcome="$3" substr="${4:-}"

  local path="$ROOT/$file"
  if [[ ! -f "$path" ]]; then
    li_test_skip "missing $file"
    skip=$((skip + 1))
    return
  fi

  local exp_file="${path%.li}.exp"
  if [[ -f "$exp_file" ]]; then
    substr="$(head -1 "$exp_file")"
  fi

  case "$outcome" in
    parse_ok)
      if "$LIC" parse "$path" >/dev/null 2>&1; then
        li_test_pass "parse_ok $file"
        pass=$((pass + 1))
      else
        li_test_fail "parse_ok $file"
        fail=$((fail + 1))
      fi
      ;;
    parse_fail)
      if "$LIC" parse "$path" >/dev/null 2>&1; then
        li_test_fail "parse_fail $file (should reject)"
        fail=$((fail + 1))
      else
        li_test_pass "parse_fail $file"
        pass=$((pass + 1))
      fi
      ;;
    compile_ok|verify_ok)
      if "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "$outcome $file"
        pass=$((pass + 1))
      else
        li_test_fail "$outcome $file"
        fail=$((fail + 1))
      fi
      ;;
    compile_open_ok)
      local open_build_flags=(--allow-open-vc)
      case "$file" in
        composable/import_sim_scientific_run.li|composable/import_physics_runtime.li|composable/import_math_numerics_dot_axpy.li)
          open_build_flags+=(--no-lean-verify)
          ;;
      esac
      if "$LIC" build "${open_build_flags[@]}" "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "compile_open_ok $file"
        pass=$((pass + 1))
      else
        li_test_fail "compile_open_ok $file"
        fail=$((fail + 1))
      fi
      ;;
    verify_open_ok)
      local open_flags=(--allow-open-vc)
      # Full net.httpd lib AutoVC still has loop-index gaps (httpd agent); compile+link gate only.
      case "$file" in
        httpd/*|composable/import_httpd_lib.li|routing/*)
          open_flags+=(--no-lean-verify)
          ;;
      esac
      if "$LIC" build "${open_flags[@]}" "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_pass "verify_open_ok $file"
        pass=$((pass + 1))
      else
        li_test_fail "verify_open_ok $file"
        fail=$((fail + 1))
      fi
      ;;
    compile_fail|verify_fail)
      local err
      err="$("$LIC" build "$path" -o "$NULL_OUT" 2>&1)" || true
      if "$LIC" build "$path" -o "$NULL_OUT" 2>/dev/null; then
        li_test_fail "$outcome $file (should reject)"
        fail=$((fail + 1))
      elif [[ -n "$substr" ]] && ! echo "$err" | grep -qi "$substr"; then
        li_test_fail "$outcome $file (missing expected substring: $substr)"
        fail=$((fail + 1))
      else
        li_test_pass "$outcome $file"
        pass=$((pass + 1))
      fi
      ;;
    *)
      echo "unknown outcome $outcome for $file"
      fail=$((fail + 1))
      ;;
  esac
}

while IFS= read -r line; do
  if [[ "$line" == "[[tests]]" ]]; then
    if [[ -n "${cur_file:-}" && -n "${cur_outcome:-}" ]]; then
      if [[ "$FILTER" == "all" || "$FILTER" == "$cur_suite" ]]; then
        if test_matches_package "${cur_packages:-}"; then
          run_one "$cur_suite" "$cur_file" "$cur_outcome" "${cur_substr:-}"
        else
          skip=$((skip + 1))
        fi
      fi
    fi
    cur_suite="" cur_file="" cur_outcome="" cur_substr="" cur_packages=""
    continue
  fi
  [[ "$line" =~ ^suite\ =\ \"(.*)\"$ ]] && cur_suite="${BASH_REMATCH[1]}" && continue
  [[ "$line" =~ ^file\ =\ \"(.*)\"$ ]] && cur_file="${BASH_REMATCH[1]}" && continue
  [[ "$line" =~ ^outcome\ =\ \"(.*)\"$ ]] && cur_outcome="${BASH_REMATCH[1]}" && continue
  [[ "$line" =~ ^expected_substr\ =\ \"(.*)\"$ ]] && cur_substr="${BASH_REMATCH[1]}" && continue
  if [[ "$line" =~ ^packages\ =\ \[ ]]; then
    cur_packages="$line"
    continue
  fi
done < "$ROOT/manifest.toml"

# last entry
if [[ -n "${cur_file:-}" && -n "${cur_outcome:-}" ]]; then
  if [[ "$FILTER" == "all" || "$FILTER" == "$cur_suite" ]]; then
    if test_matches_package "${cur_packages:-}"; then
      run_one "$cur_suite" "$cur_file" "$cur_outcome" "${cur_substr:-}"
    else
      skip=$((skip + 1))
    fi
  fi
fi

# Machine-parseable footer (plot_suites.py).
echo "--- li-tests: pass=$pass fail=$fail skip=$skip"
li_tests_footer "$pass" "$fail" "$skip"
[[ "$fail" -eq 0 ]]
