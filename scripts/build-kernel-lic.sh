#!/usr/bin/env bash
# Build lic with freestanding kernel support (out-of-tree recommended on WSL+DrvFS).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="${LI_KERNEL_LIC_BUILD:-${ROOT}/build-kernel}"

if [[ "${LI_KERNEL_LIC_BUILD_IN_TMP:-0}" == "1" ]]; then
  BUILD="/tmp/lic-kernel-build-$$"
  SRC="/tmp/lic-kernel-src-$$"
  rm -rf "${SRC}" "${BUILD}"
  mkdir -p "${SRC}"
  rsync -a --delete \
    --exclude build-wsl --exclude build --exclude build-kernel --exclude .git/objects \
    "${ROOT}/" "${SRC}/"
  ROOT="${SRC}"
fi

mkdir -p "${BUILD}"
cmake -B "${BUILD}" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-22/lib/cmake/llvm}" \
  -DCMAKE_C_COMPILER="${CC:-clang-22}" \
  -DCMAKE_CXX_COMPILER="${CXX:-clang++-22}" \
  "${ROOT}"

ninja -C "${BUILD}" lic

LIC="${BUILD}/compiler/lic/lic"
[[ -x "${LIC}" ]] || { echo "build-kernel-lic: missing ${LIC}" >&2; exit 1; }
echo "build-kernel-lic: ok → ${LIC}"
