#!/usr/bin/env bash
# Shared helpers for Li World Studio macOS / Linux packaging.
# shellcheck disable=SC2034
set -euo pipefail

_li_ws_root() {
  local d
  d="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  echo "$d"
}

LI_WS_ROOT="${LI_WS_ROOT:-$(_li_ws_root)}"
LI_WS_INSTALLER="${LI_WS_ROOT}/installer"
LI_WS_OUT="${LI_WS_INSTALLER}/out"
LI_WS_NATIVE="${LI_WS_ROOT}/deploy/studio-demo/native"
LI_WS_ASSETS="${LI_WS_INSTALLER}/assets"
LI_WS_DEFAULT_PROFILE="${LI_WS_DEFAULT_PROFILE:-game}"

li_ws_info() { echo "$*" >&2; }
li_ws_die() { echo "ERROR: $*" >&2; exit 1; }

li_ws_resolve_lic() {
  local c
  for c in \
    "${LI_WS_ROOT}/build/compiler/lic/lic" \
    "${LI_WS_ROOT}/build-wsl/compiler/lic/lic" \
    "${LI_WS_ROOT}/build/compiler/lic/lic.exe"; do
    if [[ -x "$c" || -f "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  if [[ -x "${LI_WS_ROOT}/scripts/resolve-lic.sh" ]]; then
    "${LI_WS_ROOT}/scripts/resolve-lic.sh" 2>/dev/null && return 0
  fi
  return 1
}

li_ws_ensure_demo() {
  local demo="${LI_WS_ROOT}/build/li-studio-demo"
  local demo_exe="${LI_WS_ROOT}/build/li-studio-demo.exe"
  if [[ -f "$demo" || -f "$demo_exe" ]]; then
    return 0
  fi
  if [[ "${LI_WS_SKIP_DEMO_BUILD:-0}" == "1" ]]; then
    li_ws_die "li-studio-demo missing (set LI_WS_SKIP_DEMO_BUILD=0 to build)"
  fi
  local lic
  lic="$(li_ws_resolve_lic)" || li_ws_die "lic not found; build compiler first (cmake --build build --target lic)"
  li_ws_info "Building li-studio-demo via lic..."
  "$lic" build --allow-open-vc --no-lean-verify \
    "${LI_WS_ROOT}/packages/li-studio/src/main.li" \
    -o "${LI_WS_ROOT}/build/li-studio-demo"
  [[ -f "$demo" || -f "$demo_exe" ]] || li_ws_die "li-studio-demo build failed"
}

li_ws_demo_path() {
  if [[ -f "${LI_WS_ROOT}/build/li-studio-demo" ]]; then
    echo "${LI_WS_ROOT}/build/li-studio-demo"
  elif [[ -f "${LI_WS_ROOT}/build/li-studio-demo.exe" ]]; then
    echo "${LI_WS_ROOT}/build/li-studio-demo.exe"
  else
    return 1
  fi
}

li_ws_build_present_host() {
  local src="${LI_WS_NATIVE}/studio_shell_present_host.c"
  local out="${LI_WS_NATIVE}/studio_shell_present_host"
  [[ -f "$src" ]] || li_ws_die "missing $src"
  if [[ -x "$out" ]]; then
    return 0
  fi
  li_ws_info "Building studio_shell_present_host..."
  bash "${LI_WS_NATIVE}/native-sdl-build.sh" "$src" "$out"
  [[ -x "$out" ]] || li_ws_die "present host build failed"
}

li_ws_ensure_assets() {
  bash "${LI_WS_ROOT}/scripts/ensure-studio-installer-assets.sh"
}

li_ws_icon_png() {
  if [[ -f "${LI_WS_ASSETS}/LiWorldStudio.png" ]]; then
    echo "${LI_WS_ASSETS}/LiWorldStudio.png"
  elif [[ -f "${LI_WS_ASSETS}/app-icon-256.png" ]]; then
    echo "${LI_WS_ASSETS}/app-icon-256.png"
  else
    return 1
  fi
}

li_ws_bundle_elf_libs() {
  local bin="$1"
  local libdir="$2"
  mkdir -p "$libdir"
  while IFS= read -r lib; do
    [[ -n "$lib" && -f "$lib" ]] || continue
    local base
    base="$(basename "$lib")"
    if [[ ! -f "${libdir}/${base}" ]]; then
      cp -L "$lib" "${libdir}/${base}"
    fi
  done < <(ldd "$bin" 2>/dev/null | awk '/=> \// {print $3}' | grep -v '^$' || true)
}

li_ws_write_profile_file() {
  local dest="$1"
  local profile="${2:-$LI_WS_DEFAULT_PROFILE}"
  printf '%s\n' "$profile" >"$dest"
}
