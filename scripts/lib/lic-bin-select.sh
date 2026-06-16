#!/usr/bin/env bash
# Pick the first lic binary that executes on this host (build-wsl may exist but need newer glibc).

li_lic_is_runnable() {
  local bin="$1"
  [[ -n "$bin" && -x "$bin" ]] && "$bin" --version &>/dev/null
}

li_has_runnable_lic() {
  local root="${1:?root required}"
  if [[ -n "${LIC:-}" ]] && li_lic_is_runnable "$LIC"; then
    return 0
  fi
  li_pick_lic_bin "$root" >/dev/null
}

li_pick_lic_bin() {
  local root="${1:?root required}"
  local cand rel
  for cand in \
    "$root/build/compiler/lic/lic" \
    "$root/build-wsl/compiler/lic/lic" \
    "$root/build/compiler/lic/lic.exe"; do
    if [[ -x "$cand" ]] && "$cand" --version &>/dev/null; then
      case "$cand" in
        "$root/build/compiler/lic/lic") rel="./build/compiler/lic/lic" ;;
        "$root/build-wsl/compiler/lic/lic") rel="./build-wsl/compiler/lic/lic" ;;
        *) rel="$cand" ;;
      esac
      echo "$rel"
      return 0
    fi
  done
  return 1
}

# True when $LIC lives under this checkout (not a stale agent-runner export).
li_lic_env_matches_root() {
  local root="${1:?root required}"
  local root_real lic_dir
  [[ -n "${LIC:-}" ]] || return 1
  root_real="$(cd "$root" && pwd -P)"
  lic_dir="$(cd "$(dirname "$LIC")" && pwd -P 2>/dev/null)" || return 1
  [[ "$lic_dir" == "$root_real/build/compiler/lic" ]] && return 0
  [[ "$lic_dir" == "$root_real/build-wsl/compiler/lic" ]] && return 0
  return 1
}

# Export LIC to a compiler that runs on this host (skips build-wsl when glibc mismatches).
# Agent runners often export stale LIC=/workspace/lic/... — always prefer this checkout.
li_export_lic() {
  local root="${1:?root required}"
  local lic_rel
  if lic_rel="$(li_pick_lic_bin "$root" 2>/dev/null)"; then
    case "$lic_rel" in
      ./*) export LIC="$root/${lic_rel#./}" ;;
      *) export LIC="$lic_rel" ;;
    esac
    return 0
  fi
  if [[ -n "${LIC:-}" ]] && "$LIC" --version &>/dev/null; then
    export LIC
    return 0
  fi
  return 1
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

li_ensure_lic() {
  local root="${1:?root required}"
  local msg="${2:-build lic (./scripts/build.sh)}"
  # shellcheck disable=SC1091
  source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lic-bin-select.sh"
  if li_lic_env_matches_root "$root" && "$LIC" --version &>/dev/null && ! li_lic_needs_rebuild "$root"; then
    return 0
  fi
  if li_lic_needs_rebuild "$root"; then
    echo "lic-bin-select: stale compiler (inference SSE link); rebuilding"
    (cd "$root" && bash scripts/build.sh) || { echo "$msg"; return 1; }
  fi
  if ! li_export_lic "$root"; then
    echo "$msg"
    return 1
  fi
}
