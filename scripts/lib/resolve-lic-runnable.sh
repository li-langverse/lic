#!/usr/bin/env bash
# Pick a lic binary that executes on this host (build-wsl may require newer GLIBC).
set -euo pipefail

lic_runnable() {
  [[ -x "$1" ]] && "$1" --version >/dev/null 2>&1
}

resolve_lic_runnable() {
  local root="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local candidate lic_root
  for candidate in \
    "${LIC:-}" \
    "${LIC_ROOT:+$LIC_ROOT/build/compiler/lic/lic}" \
    "${LIC_ROOT:+$LIC_ROOT/build/compiler/lic/lic.exe}" \
    "${LIC_ROOT:+$LIC_ROOT/build-wsl/compiler/lic/lic}" \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe" \
    "$root/build-wsl/compiler/lic/lic"; do
    [[ -n "$candidate" ]] || continue
    if lic_runnable "$candidate"; then
      echo "$candidate"
      return 0
    fi
  done
  # Sibling lic checkout (agent isolated clone next to /workspace/lic).
  for lic_root in \
    "$root/../lic" \
    "$root/../../lic" \
    "${LI_REPO_ROOT:-}" \
    "${LIC_ROOT:-}"; do
    [[ -n "$lic_root" && -d "$lic_root" ]] || continue
    for candidate in \
      "$lic_root/build/compiler/lic/lic" \
      "$lic_root/build/compiler/lic/lic.exe"; do
      if lic_runnable "$candidate"; then
        echo "$candidate"
        return 0
      fi
    done
  done
  echo "resolve-lic-runnable: no runnable lic under build/ or build-wsl/ (run ./scripts/build.sh)" >&2
  return 1
}
