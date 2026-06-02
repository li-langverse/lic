#!/usr/bin/env bash
# Shared lic resolution for PH-ML gate scripts (native Linux CI vs WSL dev).
set -euo pipefail

ph_ml_is_wsl() {
  [[ -n "${WSL_INTEROP:-}" ]] && return 0
  [[ -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qiE '(microsoft|wsl)' /proc/version && return 0
  return 1
}

# Print path to lic for PH-ML gates. On native Linux, never execute build-wsl binaries.
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
