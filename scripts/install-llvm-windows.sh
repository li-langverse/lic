#!/usr/bin/env bash
# Install LLVM Windows SDK (CMake + headers) for lic CI. Chocolatey llvm lacks LLVMConfig.cmake.
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

LLVM_CMAKE="$(find_llvm_cmake || true)"
if [[ -n "$LLVM_CMAKE" ]]; then
  echo "install-llvm-windows: using existing $(dirname "$(dirname "$(dirname "$LLVM_CMAKE")")")"
  if [[ -n "${GITHUB_ENV:-}" ]]; then
    llvm_dir="$(cygpath -w "$(dirname "$(dirname "$LLVM_CMAKE")")")"
    llvm_dir="${llvm_dir//\\//}"
    echo "LLVM_DIR=${llvm_dir}" >>"$GITHUB_ENV"
  fi
  exit 0
fi

TMP="${RUNNER_TEMP:-/tmp}"
EXE="$TMP/LLVM-${VER}-win64.exe"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}/LLVM-${VER}-win64.exe"
echo "install-llvm-windows: downloading LLVM ${VER}"
curl -fsSL -o "$EXE" "$URL"
echo "install-llvm-windows: silent install (may take several minutes)"
EXE_WIN="$(cygpath -w "$EXE")"
powershell.exe -NoProfile -Command "Start-Process -FilePath '$EXE_WIN' -ArgumentList '/S' -Wait"
LLVM_CMAKE="$(find_llvm_cmake || true)"
for _ in $(seq 1 90); do
  [[ -n "$LLVM_CMAKE" ]] && break
  sleep 2
  LLVM_CMAKE="$(find_llvm_cmake || true)"
done
[[ -n "$LLVM_CMAKE" ]] || {
  echo "install-llvm-windows: LLVMConfig.cmake missing after install" >&2
  exit 1
}
if [[ -n "${GITHUB_ENV:-}" ]]; then
  llvm_dir="$(cygpath -w "$(dirname "$(dirname "$LLVM_CMAKE")")")"
  llvm_dir="${llvm_dir//\\//}"
  echo "LLVM_DIR=${llvm_dir}" >>"$GITHUB_ENV"
fi
echo "install-llvm-windows: ok (${VER})"
