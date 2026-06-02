#!/usr/bin/env bash
# Shared lic binary selection for PH-ML gate/bench scripts (native Linux vs WSL).
set -euo pipefail

ph_ml_is_wsl() {
  [[ -n "${WSL_INTEROP:-}" ]] && return 0
  [[ -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qiE '(microsoft|wsl)' /proc/version && return 0
  return 1
}

# Ensure LIC points at a runnable binary; may run ./scripts/build.sh on native Linux.
ph_ml_resolve_lic() {
  local root="${1:?root required}"
  if [[ -n "${LIC:-}" && -x "${LIC}" ]]; then
    echo "$LIC"
    return 0
  fi
  if ! ph_ml_is_wsl \
    && [[ ! -x "$root/build/compiler/lic/lic" && ! -x "$root/build/compiler/lic/lic.exe" ]]; then
    bash "$root/scripts/build.sh"
  fi
  if [[ -x "$root/build/compiler/lic/lic" ]]; then
    echo "./build/compiler/lic/lic"
  elif [[ -x "$root/build/compiler/lic/lic.exe" ]]; then
    echo "$root/build/compiler/lic/lic.exe"
  elif ph_ml_is_wsl && [[ -x "$root/build-wsl/compiler/lic/lic" ]]; then
    echo "./build-wsl/compiler/lic/lic"
  else
    return 1
  fi
}
