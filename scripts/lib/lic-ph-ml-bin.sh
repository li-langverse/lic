#!/usr/bin/env bash
# Resolve a runnable lic for PH-ML gates/benches (native build before build-wsl).
lic_ph_ml_bin() {
  local root="${1:?}"
  local lic="${LIC:-}"
  if [[ -n "$lic" ]] && [[ -x "$lic" ]] && "$lic" --version &>/dev/null 2>&1; then
    echo "$lic"
    return 0
  fi
  if [[ -x "$root/build/compiler/lic/lic" ]] \
    && "$root/build/compiler/lic/lic" --version &>/dev/null 2>&1; then
    echo "$root/build/compiler/lic/lic"
    return 0
  fi
  if [[ -x "$root/build/compiler/lic/lic.exe" ]]; then
    echo "$root/build/compiler/lic/lic.exe"
    return 0
  fi
  if [[ -n "${WSL_DISTRO_NAME:-}${WSL_INTEROP:-}" ]] \
    && [[ -x "$root/build-wsl/compiler/lic/lic" ]] \
    && "$root/build-wsl/compiler/lic/lic" --version &>/dev/null 2>&1; then
    echo "$root/build-wsl/compiler/lic/lic"
    return 0
  fi
  return 1
}
