#!/usr/bin/env bash
# Install LLVM Windows SDK (CMake + headers) for lic CI. Chocolatey llvm lacks LLVMConfig.cmake.
set -euo pipefail
VER="${LLVM_WINDOWS_VERSION:-18.1.8}"
LLVM_CMAKE="/c/Program Files/LLVM/lib/cmake/llvm/LLVMConfig.cmake"
if [[ -f "$LLVM_CMAKE" ]]; then
  echo "install-llvm-windows: already installed at /c/Program Files/LLVM"
  exit 0
fi
TMP="${RUNNER_TEMP:-/tmp}"
EXE="$TMP/LLVM-${VER}-win64.exe"
URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${VER}/LLVM-${VER}-win64.exe"
echo "install-llvm-windows: downloading LLVM ${VER}"
curl -fsSL -o "$EXE" "$URL"
echo "install-llvm-windows: silent install"
cmd.exe //c "\"$(cygpath -w "$EXE")\" /S"
for _ in $(seq 1 30); do
  [[ -f "$LLVM_CMAKE" ]] && break
  sleep 2
done
[[ -f "$LLVM_CMAKE" ]] || {
  echo "install-llvm-windows: LLVMConfig.cmake missing after install" >&2
  exit 1
}
echo "install-llvm-windows: ok (${VER})"
