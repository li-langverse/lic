#!/usr/bin/env bash
# Build Li World Studio .app + drag-to-Applications .dmg (macOS only).
# Prerequisites: Xcode CLI tools, cmake+ninja+LLVM 22 (brew or scripts/ci-install-llvm.sh pattern),
#   SDL2 (brew install sdl2).
# Usage: ./scripts/build-li-world-studio-installer-macos.sh [--skip-demo-build] [--profile game]
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

[[ "$(uname -s)" == "Darwin" ]] || li_ws_die "macOS installer build requires Darwin (run on macOS or macOS CI)"

mkdir -p "$LI_WS_OUT"
li_ws_ensure_assets

[[ "$SKIP_DEMO" -eq 1 ]] && export LI_WS_SKIP_DEMO_BUILD=1
li_ws_ensure_demo
li_ws_build_present_host

DEMO="$(li_ws_demo_path)"
HOST="${LI_WS_NATIVE}/studio_shell_present_host"
ICON="$(li_ws_icon_png)" || li_ws_die "icon PNG missing"

APP_NAME="Li World Studio.app"
APP="${LI_WS_OUT}/${APP_NAME}"
rm -rf "$APP"
mkdir -p "${APP}/Contents/MacOS" "${APP}/Contents/Resources"

cp -f "$DEMO" "${APP}/Contents/Resources/li-studio-demo"
chmod +x "${APP}/Contents/Resources/li-studio-demo"
cp -f "$HOST" "${APP}/Contents/Resources/studio_shell_present_host"
chmod +x "${APP}/Contents/Resources/studio_shell_present_host"
li_ws_write_profile_file "${APP}/Contents/Resources/studio-profile.txt" "$LI_WS_DEFAULT_PROFILE"
cp -f "$ICON" "${APP}/Contents/Resources/LiWorldStudio.png"

cat >"${APP}/Contents/MacOS/LiWorldStudio" <<'LAUNCHER'
#!/usr/bin/env bash
set -euo pipefail
RES="$(cd "$(dirname "$0")/../Resources" && pwd)"
PROFILE="${1:-}"
if [[ -z "$PROFILE" && -f "$RES/studio-profile.txt" ]]; then
  PROFILE="$(tr -d '\r\n' <"$RES/studio-profile.txt")"
fi
export STUDIO_DEMO_PROFILE="${PROFILE:-game}"
export STUDIO_DEMO_FRAMES="${STUDIO_DEMO_FRAMES:-3}"
PRESENT=0
for a in "$@"; do
  [[ "$a" == "present" ]] && PRESENT=1
done
if [[ "$PRESENT" -eq 1 ]]; then
  export LIG_HOST_PRESENT=1
  export STUDIO_SHELL_PRESENT_HOST_BIN="${RES}/studio_shell_present_host"
else
  unset LIG_HOST_PRESENT STUDIO_SHELL_PRESENT_HOST_BIN 2>/dev/null || true
fi
exec "${RES}/li-studio-demo"
LAUNCHER
chmod +x "${APP}/Contents/MacOS/LiWorldStudio"

cat >"${APP}/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>LiWorldStudio</string>
  <key>CFBundleIconFile</key>
  <string>LiWorldStudio</string>
  <key>CFBundleIdentifier</key>
  <string>org.lilangverse.li-world-studio</string>
  <key>CFBundleName</key>
  <string>Li World Studio</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>0.1.0</string>
  <key>LSMinimumSystemVersion</key>
  <string>12.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

ICNS="${APP}/Contents/Resources/LiWorldStudio.icns"
if command -v iconutil >/dev/null 2>&1; then
  ICONSET="$(mktemp -d)/LiWorldStudio.iconset"
  mkdir -p "$ICONSET"
  sips -z 256 256 "${APP}/Contents/Resources/LiWorldStudio.png" --out "${ICONSET}/icon_256x256.png" >/dev/null
  sips -z 128 128 "${APP}/Contents/Resources/LiWorldStudio.png" --out "${ICONSET}/icon_128x128.png" >/dev/null
  sips -z 32 32 "${APP}/Contents/Resources/LiWorldStudio.png" --out "${ICONSET}/icon_32x32.png" >/dev/null
  sips -z 16 16 "${APP}/Contents/Resources/LiWorldStudio.png" --out "${ICONSET}/icon_16x16.png" >/dev/null
  cp "${ICONSET}/icon_256x256.png" "${ICONSET}/icon_256x256@2x.png"
  cp "${ICONSET}/icon_128x128.png" "${ICONSET}/icon_128x128@2x.png"
  cp "${ICONSET}/icon_32x32.png" "${ICONSET}/icon_32x32@2x.png"
  cp "${ICONSET}/icon_16x16.png" "${ICONSET}/icon_16x16@2x.png"
  iconutil -c icns "$ICONSET" -o "$ICNS" 2>/dev/null || true
fi

DMG_STAGING="$(mktemp -d)"
trap 'rm -rf "$DMG_STAGING"' EXIT
cp -R "$APP" "${DMG_STAGING}/"
ln -sf /Applications "${DMG_STAGING}/Applications"

DMG_OUT="${LI_WS_OUT}/LiWorldStudio.dmg"
rm -f "$DMG_OUT"

if command -v create-dmg >/dev/null 2>&1; then
  create-dmg \
    --volname "Li World Studio" \
    --window-size 540 380 \
    --icon-size 96 \
    --app-drop-link 380 180 \
    "$DMG_OUT" \
    "$APP" 2>/dev/null || true
fi

if [[ ! -f "$DMG_OUT" ]]; then
  hdiutil create -volname "Li World Studio" -srcfolder "$DMG_STAGING" -ov -format UDZO "$DMG_OUT"
fi

[[ -f "$DMG_OUT" ]] || li_ws_die "DMG not created"
li_ws_info "macOS app: $APP"
li_ws_info "macOS dmg: $DMG_OUT"
