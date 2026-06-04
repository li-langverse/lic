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

  local sibling_roots=()
  if [[ -n "$lic_root" ]]; then
    sibling_roots+=("$lic_root")
  fi
  for sibling in \
    "/workspace/lic" \
    "$root/../lic" \
    "$root/../../lic" \
    "$root/../../../../../workspace/lic"; do
    if [[ -d "$sibling" ]]; then
      sibling_roots+=("$sibling")
    fi
  done

  local seen="" s
  for s in "${sibling_roots[@]}"; do
    [[ "$seen" == *"|$s|"* ]] && continue
    seen="${seen}|$s|"
    for candidate in \
      "$s/build/compiler/lic/lic" \
      "$s/build/compiler/lic/lic.exe" \
      "$s/build-wsl/compiler/lic/lic"; do
      if lic_is_runnable "$candidate"; then
        echo "$candidate"
        return 0
      fi
    done
  done

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
