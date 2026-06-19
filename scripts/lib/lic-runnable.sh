#!/usr/bin/env bash
# Resolve a lic binary that actually executes on this host (not merely -x).
# Prefer native build/ over build-wsl when build-wsl was copied from a newer glibc WSL image.
set -euo pipefail

lic_is_runnable() {
  local bin="$1"
  [[ -n "$bin" && -x "$bin" ]] || return 1
  "$bin" --version >/dev/null 2>&1
}

lic_resolve_runnable() {
  local root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local lic_root="${LIC_ROOT:-${LI_REPO_ROOT:-}}"
  local candidate

  if [[ -n "${LIC:-}" ]] && lic_is_runnable "$LIC"; then
    echo "$LIC"
    return 0
  fi

  for candidate in \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe" \
    "$root/build-wsl/compiler/lic/lic"; do
    if lic_is_runnable "$candidate"; then
      echo "$candidate"
      return 0
    fi
  done

  if [[ -n "$lic_root" ]]; then
    for candidate in \
      "$lic_root/build/compiler/lic/lic" \
      "$lic_root/build/compiler/lic/lic.exe" \
      "$lic_root/build-wsl/compiler/lic/lic"; do
      if lic_is_runnable "$candidate"; then
        echo "$candidate"
        return 0
      fi
    done
  fi

  if [[ -x "$root/scripts/resolve-lic.sh" ]]; then
    candidate="$("$root/scripts/resolve-lic.sh" 2>/dev/null)" || true
    if lic_is_runnable "$candidate"; then
      echo "$candidate"
      return 0
    fi
  fi

  echo "lic-runnable: no runnable lic under $root or LIC_ROOT=${lic_root:-<unset>}" >&2
  return 1
}
