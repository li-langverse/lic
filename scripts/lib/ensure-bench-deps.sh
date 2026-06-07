#!/usr/bin/env bash
# Ensure native bench toolchain (clang) for Li vs C++ parity gates.
#
# Usage (from any lic checkout):
#   source scripts/lib/ensure-bench-deps.sh   # export CC/CXX if found
#   ensure_bench_deps                       # exit 0 when clang usable
#
# Auto-install (opt-in — needs passwordless sudo or run as root):
#   LI_AGENT_INSTALL_DEPS=1 ensure_bench_deps
#   sudo LI_AGENT_INSTALL_DEPS=1 bash scripts/lib/ensure-bench-deps.sh --install
#
# Do not grant agents unrestricted root. Prefer one-time:
#   sudo bash scripts/setup-li-devbox.sh
set -euo pipefail

_ensure_bench_deps_root() {
  if [[ -n "${LIC_ROOT:-}" && -f "${LIC_ROOT}/scripts/llvm-env.sh" ]]; then
    echo "$(cd "${LIC_ROOT}" && pwd)"
    return
  fi
  local here
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  if [[ -f "$here/scripts/llvm-env.sh" ]]; then
    echo "$here"
    return
  fi
  echo ""
}

_ensure_bench_deps_have_clang() {
  command -v "${CC:-clang}" >/dev/null 2>&1 && return 0
  command -v clang >/dev/null 2>&1 && return 0
  local v
  for v in 22 21 20 18; do
    command -v "clang-${v}" >/dev/null 2>&1 && return 0
  done
  return 1
}

_ensure_bench_deps_source_llvm() {
  local root="$1"
  # shellcheck disable=SC1091
  source "${root}/scripts/llvm-env.sh"
  li_detect_llvm_dir 2>/dev/null || true
  li_detect_compilers 2>/dev/null || true
  if [[ -n "${CC:-}" ]] && command -v "$CC" >/dev/null 2>&1; then
    export CXX="${CXX:-clang++}"
    return 0
  fi
  return 1
}

_ensure_bench_deps_apt_install() {
  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    SUDO=()
  elif [[ "${LI_AGENT_INSTALL_DEPS_SUDO:-1}" == "1" ]] && sudo -n true 2>/dev/null; then
    SUDO=(sudo -n)
  else
    echo "ensure-bench-deps: install needs root or passwordless sudo (see docs/guide/devbox-li-development.md)" >&2
    return 1
  fi
  export DEBIAN_FRONTEND=noninteractive
  local major="${LI_LLVM_MAJOR:-22}"
  echo "ensure-bench-deps: apt install clang-${major} build-essential ..."
  "${SUDO[@]}" apt-get update -qq
  "${SUDO[@]}" apt-get install -y \
    build-essential \
    "clang-${major}" \
    "llvm-${major}-dev" \
    pkg-config \
    || "${SUDO[@]}" apt-get install -y build-essential clang llvm-dev pkg-config
  return 0
}

ensure_bench_deps() {
  local root
  root="$(_ensure_bench_deps_root)"
  if [[ -z "$root" ]]; then
    echo "ensure-bench-deps: cannot find lic root (set LIC_ROOT)" >&2
    return 1
  fi
  export LIC_ROOT="$root"

  if _ensure_bench_deps_source_llvm "$root" || _ensure_bench_deps_have_clang; then
    echo "ensure-bench-deps: using CC=${CC:-clang} CXX=${CXX:-clang++}"
    return 0
  fi

  if [[ "${LI_AGENT_INSTALL_DEPS:-}" != "1" ]]; then
    echo "ensure-bench-deps: no clang in PATH. One-time: sudo bash scripts/setup-li-devbox.sh" >&2
    echo "  Or: LI_AGENT_INSTALL_DEPS=1 (requires passwordless sudo) $0 --install" >&2
    return 1
  fi

  _ensure_bench_deps_apt_install || return 1
  _ensure_bench_deps_source_llvm "$root" || _ensure_bench_deps_have_clang || return 1
  echo "ensure-bench-deps: installed; CC=${CC:-clang}"
  return 0
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "${1:-}" in
    --install) export LI_AGENT_INSTALL_DEPS=1 ;;
    "") ;;
    -h|--help)
      echo "Usage: source scripts/lib/ensure-bench-deps.sh && ensure_bench_deps"
      echo "       LI_AGENT_INSTALL_DEPS=1 $0 --install"
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  ensure_bench_deps
fi
