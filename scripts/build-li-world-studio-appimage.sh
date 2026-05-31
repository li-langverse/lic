#!/usr/bin/env bash
# Build LiWorldStudio-x86_64.AppImage (Linux x86_64).
# Requires: bash, ldd, optional appimagetool OR linuxdeploy AppImage.
# Usage: ./scripts/build-li-world-studio-appimage.sh [--skip-demo-build] [--profile game]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=/dev/null
source "${ROOT}/scripts/_li-world-studio-packaging-common.sh"
LI_WS_ROOT="$ROOT"

SKIP_DEMO=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-demo-build) SKIP_DEMO=1; LI_WS_SKIP_DEMO_BUILD=1 ;;
    --profile) LI_WS_DEFAULT_PROFILE="${2:?}"; shift ;;
    -h|--help)
      echo "Usage: $0 [--skip-demo-build] [--profile game]"
      exit 0
      ;;
    *) li_ws_die "unknown arg: $1" ;;
  esac
  shift
done

[[ "$(uname -s)" == "Linux" ]] || li_ws_die "AppImage build requires Linux (use WSL: wsl bash scripts/build-li-world-studio-appimage.sh)"

mkdir -p "$LI_WS_OUT"
li_ws_ensure_assets

[[ "$SKIP_DEMO" -eq 1 ]] && export LI_WS_SKIP_DEMO_BUILD=1
li_ws_ensure_demo
li_ws_build_present_host

DEMO="$(li_ws_demo_path)"
HOST="${LI_WS_NATIVE}/studio_shell_present_host"
ICON="$(li_ws_icon_png)" || li_ws_die "icon PNG missing; run scripts/ensure-studio-installer-assets.sh"

APPDIR="${LI_WS_OUT}/LiWorldStudio.AppDir"
rm -rf "$APPDIR"
mkdir -p "${APPDIR}/usr/bin"

cp -f "$DEMO" "${APPDIR}/usr/bin/li-studio-demo"
chmod +x "${APPDIR}/usr/bin/li-studio-demo"
cp -f "$HOST" "${APPDIR}/usr/bin/studio_shell_present_host"
chmod +x "${APPDIR}/usr/bin/studio_shell_present_host"

li_ws_bundle_elf_libs "${APPDIR}/usr/bin/li-studio-demo" "${APPDIR}/usr/lib"
li_ws_bundle_elf_libs "${APPDIR}/usr/bin/studio_shell_present_host" "${APPDIR}/usr/lib"

li_ws_write_profile_file "${APPDIR}/studio-profile.txt" "$LI_WS_DEFAULT_PROFILE"

cp -f "$ICON" "${APPDIR}/li-world-studio.png"
cp -f "${APPDIR}/li-world-studio.png" "${APPDIR}/.DirIcon"
mkdir -p "${APPDIR}/usr/share/icons/hicolor/256x256/apps"
cp -f "$ICON" "${APPDIR}/usr/share/icons/hicolor/256x256/apps/li-world-studio.png"
cat >"${APPDIR}/li-world-studio.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Li World Studio
Comment=Li World Studio demo shell (li-studio-demo)
Exec=li-studio-demo
Icon=li-world-studio
Categories=Development;IDE;
Terminal=false
DESKTOP

cat >"${APPDIR}/usr/bin/launch-li-world-studio.sh" <<'LAUNCH'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROFILE="${1:-}"
if [[ -z "$PROFILE" && -f "$HERE/studio-profile.txt" ]]; then
  PROFILE="$(tr -d '\r\n' <"$HERE/studio-profile.txt")"
fi
export STUDIO_DEMO_PROFILE="${PROFILE:-game}"
export STUDIO_DEMO_FRAMES="${STUDIO_DEMO_FRAMES:-3}"
PRESENT=0
for a in "$@"; do
  [[ "$a" == "present" ]] && PRESENT=1
done
if [[ "$PRESENT" -eq 1 ]]; then
  export LIG_HOST_PRESENT=1
  export STUDIO_SHELL_PRESENT_HOST_BIN="${HERE}/usr/bin/studio_shell_present_host"
else
  unset LIG_HOST_PRESENT STUDIO_SHELL_PRESENT_HOST_BIN 2>/dev/null || true
fi
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH:-}"
exec "${HERE}/usr/bin/li-studio-demo"
LAUNCH
chmod +x "${APPDIR}/usr/bin/launch-li-world-studio.sh"

cat >"${APPDIR}/AppRun" <<'APPRUN'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH:-}"
exec "${HERE}/usr/bin/launch-li-world-studio.sh" "$@"
APPRUN
chmod +x "${APPDIR}/AppRun"

OUT="${LI_WS_OUT}/LiWorldStudio-x86_64.AppImage"
rm -f "$OUT"

fetch_tool() {
  local url="$1"
  local dest="$2"
  if [[ -x "$dest" ]]; then
    return 0
  fi
  li_ws_info "Downloading $(basename "$dest")..."
  curl -fsSL "$url" -o "$dest"
  chmod +x "$dest"
}

TOOLS="${ROOT}/build/installer-tools"
mkdir -p "$TOOLS"

LINUXDEPLOY="${TOOLS}/linuxdeploy-x86_64.AppImage"
APPIMAGETOOL="${TOOLS}/appimagetool-x86_64.AppImage"

if [[ -x "$(command -v linuxdeploy)" ]]; then
  linuxdeploy --appdir="$APPDIR" \
    --executable="${APPDIR}/usr/bin/li-studio-demo" \
    --executable="${APPDIR}/usr/bin/studio_shell_present_host" \
    --desktop-file="${APPDIR}/li-world-studio.desktop" \
    --icon-file="${APPDIR}/li-world-studio.png" \
    --output appimage
  mv -f "${LI_WS_OUT}"/Li_World_Studio*.AppImage "$OUT" 2>/dev/null \
    || mv -f ./*.AppImage "$OUT" 2>/dev/null \
    || true
fi

if [[ ! -f "$OUT" ]]; then
  fetch_tool \
    "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" \
    "$LINUXDEPLOY"
  if [[ -f "$LINUXDEPLOY" ]]; then
  "$LINUXDEPLOY" --appdir="$APPDIR" \
    --executable="${APPDIR}/usr/bin/li-studio-demo" \
    --executable="${APPDIR}/usr/bin/studio_shell_present_host" \
    --desktop-file="${APPDIR}/li-world-studio.desktop" \
    --icon-file="${APPDIR}/li-world-studio.png" \
    --output appimage 2>/dev/null || true
  mv -f "${LI_WS_OUT}"/Li*.AppImage "$OUT" 2>/dev/null || true
  fi
fi

if [[ ! -f "$OUT" ]]; then
  fetch_tool \
    "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" \
    "$APPIMAGETOOL"
  if ! ldconfig -p 2>/dev/null | grep -q libfuse.so.2; then
    li_ws_info "libfuse2 not found; using APPIMAGE_EXTRACT_AND_RUN for appimagetool"
    li_ws_info "Install for native FUSE: sudo apt-get install -y libfuse2"
  fi
  export APPIMAGE_EXTRACT_AND_RUN=1
  ARCH=x86_64 VERSION=0.1.0 "$APPIMAGETOOL" --no-appstream "$APPDIR" "$OUT"
fi

if [[ ! -f "$OUT" ]]; then
  found="$(find "$LI_WS_OUT" -maxdepth 1 -name '*.AppImage' -print -quit 2>/dev/null || true)"
  [[ -n "$found" && -f "$found" ]] && mv -f "$found" "$OUT"
fi

[[ -f "$OUT" ]] || li_ws_die "AppImage not produced (try: sudo apt-get install -y libfuse2, or run on Linux CI)"
chmod +x "$OUT"
li_ws_info "AppImage built: $OUT"
