#!/usr/bin/env bash
# Resolve li-langverse/lip and lit checkout paths (sibling dir or in-workspace ecosystem/).
# shellcheck shell=bash
_li_ecosystem_root() {
  local root="$1"
  if [[ -n "${ECOSYSTEM_SIBLINGS_ROOT:-}" ]]; then
    echo "$(cd "${ECOSYSTEM_SIBLINGS_ROOT}" && pwd)"
    return 0
  fi
  if [[ -d "$root/ecosystem/lip/.git" || -d "$root/ecosystem/lip" ]]; then
    echo "$root/ecosystem"
    return 0
  fi
  echo "$(cd "$root/.." && pwd)"
}

_li_ecosystem_lip_dir() {
  local root="$1"
  local base
  base="$(_li_ecosystem_root "$root")"
  if [[ -d "$base/lip" ]]; then
    echo "$base/lip"
    return 0
  fi
  return 1
}

_li_ecosystem_lit_dir() {
  local root="$1"
  local base
  base="$(_li_ecosystem_root "$root")"
  if [[ -d "$base/lit" ]]; then
    echo "$base/lit"
    return 0
  fi
  return 1
}
