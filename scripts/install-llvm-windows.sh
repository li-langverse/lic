#!/usr/bin/env bash
# Install LLVM Windows SDK (CMake + headers) for lic CI.
set -euo pipefail
VER="${LLVM_WINDOWS_VERSION:-18.1.8}"

find_llvm_cmake() {
  local f
  for f in \
    "/c/Program Files/LLVM/lib/cmake/llvm/LLVMConfig.cmake" \
    "/c/Program Files (x86)/LLVM/lib/cmake/llvm/LLVMConfig.cmake"; do
    if [[ -f "$f" ]]; then
      echo "$f"
      return 0
    fi
  done
  if command -v find >/dev/null 2>&1; then
    find "/c/Program Files" "/c/Program Files (x86)" -name LLVMConfig.cmake 2>/dev/null | head -1
  fi
}

emit_llvm_env() {
  local cmake_file="$1"
  local llvm_root
  llvm_root="$(cd "$(dirname "$(dirname "$(dirname "$cmake_file")")")" && pwd)"
  if [[ -n "${GITHUB_ENV:-}" ]]; then
    local llvm_dir
    llvm_dir="$(cygpath -w "${llvm_root}/lib/cmake/llvm")"
    llvm_dir="${llvm_dir//\\//}"
    echo "LLVM_DIR=${llvm_dir}" >>"$GITHUB_ENV"
    echo "C:/Program Files/LLVM/bin" >>"$GITHUB_PATH" 2>/dev/null || true
    local bin_win
    bin_win="$(cygpath -w "${llvm_root}/bin")"
    echo "${bin_win//\\//}" >>"$GITHUB_PATH"
  fi
}

LLVM_CMAKE="$(find_llvm_cmake || true)"
if [[ -n "$LLVM_CMAKE" ]]; then
  echo "install-llvm-windows: using existing LLVM at $(dirname "$(dirname "$(dirname "$LLVM_CMAKE")")")"
  emit_llvm_env "$LLVM_CMAKE"
  exit 0
fi

TMP="${RUNNER_TEMP:-/tmp}"
ARCHIVE="$TMP/clang+llvm-${VER}-x86_64-pc-windows-msvc.tar.xz"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}/clang+llvm-${VER}-x86_64-pc-windows-msvc.tar.xz"
DEST="/c/LLVM-${VER}"
echo "install-llvm-windows: downloading LLVM ${VER} prebuilt archive"
curl -fsSL -o "$ARCHIVE" "$URL"
rm -rf "$DEST"
mkdir -p "$DEST"
tar -xJf "$ARCHIVE" -C "$DEST" --strip-components=1
LLVM_CMAKE="$DEST/lib/cmake/llvm/LLVMConfig.cmake"
[[ -f "$LLVM_CMAKE" ]] || {
  echo "install-llvm-windows: LLVMConfig.cmake missing in archive" >&2
  exit 1
}
emit_llvm_env "$LLVM_CMAKE"
echo "install-llvm-windows: ok (${VER} at ${DEST})"
