#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).

li_is_wsl() {
  [[ -n "${WSL_INTEROP:-}" || -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qiE '(microsoft|wsl)' /proc/version
}

li_lic_runnable() {
  local bin="$1"
  [[ -n "$bin" && ( -x "$bin" || -f "$bin" ) ]] || return 1
  "$bin" --version >/dev/null 2>&1
}

li_pick_lic_bin() {
  local root="${1:?root required}"
  local cand rel
  for cand in \
    "$root/build/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe"; do
    if li_lic_runnable "$cand"; then
      case "$cand" in
        "$root/build/compiler/lic/lic") rel="./build/compiler/lic/lic" ;;
        *) rel="$cand" ;;
      esac
      echo "$rel"
      return 0
    fi
  done
  cand="$root/build-wsl/compiler/lic/lic"
  if [[ -x "$cand" ]] && { li_is_wsl || li_lic_runnable "$cand"; }; then
    echo "./build-wsl/compiler/lic/lic"
    return 0
  fi
  for cand in "${LIC_ROOT:-}" "${LI_REPO_ROOT:-}" "/workspace/lic"; do
    [[ -n "$cand" ]] || continue
    if li_lic_runnable "$cand/build/compiler/lic/lic"; then
      echo "$cand/build/compiler/lic/lic"
      return 0
    fi
  done
  return 1
}

# Export LIC to a compiler that runs on this host (skips build-wsl when glibc mismatches).
li_export_lic() {
  local root="${1:?root required}"
  if [[ -n "${LIC:-}" ]] && li_lic_runnable "$LIC"; then
    export LIC
    return 0
  fi
  local lic_rel
  lic_rel="$(li_pick_lic_bin "$root")" || return 1
  case "$lic_rel" in
    ./*) export LIC="$root/${lic_rel#./}" ;;
    *) export LIC="$lic_rel" ;;
  esac
}

# True when stage8 inference SSE sources are newer than the on-disk lic binary.
li_lic_needs_rebuild() {
  local root="${1:?root required}"
  local lic_bin=""
  if lic_rel="$(li_pick_lic_bin "$root" 2>/dev/null)"; then
    case "$lic_rel" in
      ./*) lic_bin="$root/${lic_rel#./}" ;;
      *) lic_bin="$lic_rel" ;;
    esac
  fi
  [[ -x "$lic_bin" ]] || return 0
  local marker="$root/runtime/li_rt_inference_sse.c"
  [[ -f "$marker" ]] || return 1
  local src
  for src in \
    "$root/compiler/codegen/compile.cpp" \
    "$root/compiler/mir/mir_runtime_link.cpp" \
    "$root/compiler/verify/vc_emit_lean.cpp" \
    "$root/compiler/verify/vc_witness.cpp" \
    "$root/compiler/verify/vc_emit.cpp" \
    "$marker"; do
    if [[ -f "$src" ]] && [[ "$src" -nt "$lic_bin" ]]; then
      return 0
    fi
  done
  return 1
}

li_ensure_native_lic() {
  local root="${1:?root required}"
  if li_lic_runnable "$root/build/compiler/lic/lic" \
    || li_lic_runnable "$root/build/compiler/lic/lic.exe"; then
    return 0
  fi
  if li_is_wsl; then
    return 1
  fi
  if [[ -x "$root/scripts/build.sh" ]]; then
    bash "$root/scripts/build.sh" --target lic
    li_lic_runnable "$root/build/compiler/lic/lic"
  else
    return 1
  fi
}

li_ensure_lic() {
  local root="${1:?root required}"
  local msg="${2:-build lic (./scripts/build.sh)}"
  if [[ -n "${LIC:-}" ]] && li_lic_runnable "$LIC" && ! li_lic_needs_rebuild "$root"; then
    return 0
  fi
  # shellcheck disable=SC1091
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-bin-select.sh"
  if li_lic_needs_rebuild "$root"; then
    echo "lic-bin-select: stale compiler (inference SSE link); rebuilding"
    (cd "$root" && bash scripts/build.sh) || { echo "$msg"; return 1; }
  fi
  if ! li_is_wsl; then
    li_ensure_native_lic "$root" || true
  fi
  LIC="$(li_pick_lic_bin "$root")" || { echo "$msg"; return 1; }
  export LIC
}
