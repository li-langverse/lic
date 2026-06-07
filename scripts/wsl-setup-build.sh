#!/usr/bin/env bash
# One-time WSL (Ubuntu) toolchain for ./scripts/build.sh on /mnt/c/.../lic checkouts.
# Usage: wsl bash scripts/wsl-setup-build.sh
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y cmake ninja-build wget gnupg lsb-release \
  zlib1g-dev libzstd-dev libcurl4-openssl-dev libedit-dev
if [[ ! -x /tmp/llvm.sh ]]; then
  wget -q https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh
  chmod +x /tmp/llvm.sh
fi
sudo /tmp/llvm.sh 22
sudo apt-get install -y clang-22 llvm-22-dev
echo "OK: clang-22 $(clang-22 --version | head -1)"
test -f /usr/lib/llvm-22/lib/cmake/llvm/LLVMConfig.cmake
echo "Build with:"
echo "  export CC=clang-22 CXX=clang++-22 LLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm"
echo "  cmake -S . -B build-wsl -G Ninja -DLLVM_DIR=\$LLVM_DIR -DLI_BUILD_TESTS=OFF"
echo "  cmake --build build-wsl -j \$(nproc) --target lic"
echo "Note: use build-wsl/ (not build/) when mixing Windows and WSL cmake caches."
