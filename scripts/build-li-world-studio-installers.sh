#!/usr/bin/env bash
# Build Li World Studio installer for the current OS (or dispatch explicitly).
#   Linux   -> LiWorldStudio-x86_64.AppImage
#   macOS   -> LiWorldStudio.dmg (+ .app in installer/out)
#   Windows -> LiWorldStudio-Setup.exe (Inno Setup; run on Windows)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-auto}"
shift || true

case "$TARGET" in
  auto)
    case "$(uname -s)" in
      Linux) exec bash "${ROOT}/scripts/build-li-world-studio-appimage.sh" "$@" ;;
      Darwin) exec bash "${ROOT}/scripts/build-li-world-studio-installer-macos.sh" "$@" ;;
      MINGW* | MSYS* | CYGWIN* | Windows_NT)
        if command -v pwsh >/dev/null 2>&1; then
          exec pwsh -NoProfile -File "${ROOT}/scripts/build-li-world-studio-installer.ps1" "$@"
        fi
        exec powershell -NoProfile -File "${ROOT}/scripts/build-li-world-studio-installer.ps1" "$@"
        ;;
      *)
        echo "Unsupported OS for auto installer build: $(uname -s)" >&2
        echo "Try: $0 linux|macos|windows" >&2
        exit 1
        ;;
    esac
    ;;
  linux | appimage)
    exec bash "${ROOT}/scripts/build-li-world-studio-appimage.sh" "$@"
    ;;
  macos | dmg | darwin)
    exec bash "${ROOT}/scripts/build-li-world-studio-installer-macos.sh" "$@"
    ;;
  windows | inno)
    if command -v pwsh >/dev/null 2>&1; then
      exec pwsh -NoProfile -File "${ROOT}/scripts/build-li-world-studio-installer.ps1" "$@"
    fi
    exec powershell -NoProfile -File "${ROOT}/scripts/build-li-world-studio-installer.ps1" "$@"
    ;;
  -h | --help)
    cat <<EOF
Usage: $0 [auto|linux|macos|windows] [packager flags]

Examples:
  ./scripts/build-li-world-studio-installers.sh
  ./scripts/build-li-world-studio-installers.sh linux --profile sim_rl
  ./scripts/build-li-world-studio-installers.sh macos --skip-demo-build
EOF
    exit 0
    ;;
  *)
    echo "Unknown target: $TARGET" >&2
    exit 1
    ;;
esac
