#!/usr/bin/env bash
# Build freestanding hello_kern.elf for LiOS M1 (x86_64-unknown-none).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export LI_REPO_ROOT="${ROOT}"

LIC="${LIC:-}"
if [[ -z "${LIC}" ]]; then
  for candidate in \
    "${ROOT}/build-kernel/compiler/lic/lic" \
    "${ROOT}/build-wsl/compiler/lic/lic" \
    "${ROOT}/build/compiler/lic/lic"; do
    if [[ -x "${candidate}" ]]; then
      LIC="${candidate}"
      break
    fi
  done
fi
if [[ -z "${LIC}" ]]; then
  LIC="$(command -v lic || true)"
fi
[[ -n "${LIC}" && -x "${LIC}" ]] || {
  echo "build-hello-kern: lic not found (build compiler or set LIC=)" >&2
  exit 1
}

OUT="${LIOS_KERNEL_ELF:-}"
if [[ -z "${OUT}" ]]; then
  if [[ -d "${ROOT}/../build" ]]; then
    OUT="${ROOT}/../build/hello_kern.elf"
  else
    OUT="${ROOT}/build/hello_kern.elf"
  fi
fi
mkdir -p "$(dirname "${OUT}")"

echo "build-hello-kern: lic=${LIC} out=${OUT}"
"${LIC}" build --target i686-unknown-none --allow-open-vc --no-lean-verify \
  -o "${OUT}" "${ROOT}/kernel/hello_kern.li"
echo "build-hello-kern: ok → ${OUT}"
