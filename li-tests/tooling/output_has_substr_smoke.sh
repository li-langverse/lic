#!/usr/bin/env bash
# Guard li_output_has_substr (run_all.sh) on bash 3.2 — macOS CI default shell.
set -euo pipefail

li_output_has_substr() {
  local haystack="$1" needle="$2"
  [[ -z "$needle" ]] && return 0
  local had_nocasematch=0
  shopt -q nocasematch && had_nocasematch=1
  shopt -s nocasematch
  [[ "$haystack" == *"$needle"* ]]
  local rc=$?
  if [[ "$had_nocasematch" -eq 0 ]]; then
    shopt -u nocasematch
  fi
  return "$rc"
}

li_output_has_substr "stdlib_symbol_shadow: echo" "stdlib_symbol_shadow"
li_output_has_substr "Error STDlib_symbol_SHADOW" "stdlib_symbol_shadow"
if li_output_has_substr "no match here" "missing"; then
  echo "output_has_substr_smoke: should reject absent needle" >&2
  exit 1
fi
echo "output_has_substr_smoke: ok"
