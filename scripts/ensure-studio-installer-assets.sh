#!/usr/bin/env bash
# Generate installer branding (dark studio theme) for Unix packagers + optional PNG icon.
# Windows Inno assets: scripts/Ensure-StudioInstallerAssets.ps1
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSETS="${ROOT}/installer/assets"
mkdir -p "$ASSETS"

ICO="${ASSETS}/app.ico"
PNG="${ASSETS}/LiWorldStudio.png"
PNG_ALT="${ASSETS}/app-icon-256.png"

if [[ -f "$PNG" && -f "$ICO" ]]; then
  exit 0
fi

gen_png_python() {
  local out="$1"
  python3 - "$out" <<'PY'
import struct, zlib, sys

def png_chunk(tag: bytes, data: bytes) -> bytes:
    return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

def write_png(path: str, w: int, h: int) -> None:
    bg = (13, 17, 23)
    accent = (61, 214, 255)
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        for x in range(w):
            if 12 <= x < w * 55 // 100 and h * 12 // 100 <= y < h * 12 // 100 + 28:
                raw.extend(accent)
            elif 12 <= x < w * 70 // 100 and h * 22 // 100 <= y < h * 22 // 100 + 20:
                raw.extend(accent)
            else:
                raw.extend(bg)
    comp = zlib.compress(bytes(raw), 9)
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)
    outb = b"\x89PNG\r\n\x1a\n"
    outb += png_chunk(b"IHDR", ihdr)
    outb += png_chunk(b"IDAT", comp)
    outb += png_chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(outb)

write_png(sys.argv[1], 256, 256)
PY
}

if [[ ! -f "$PNG" ]]; then
  if command -v convert >/dev/null 2>&1 && [[ -f "$ICO" ]]; then
    convert "$ICO" -resize 256x256 "$PNG"
  elif command -v magick >/dev/null 2>&1 && [[ -f "$ICO" ]]; then
    magick "$ICO" -resize 256x256 "$PNG"
  elif command -v python3 >/dev/null 2>&1; then
    gen_png_python "$PNG"
  else
    echo "WARN: cannot generate LiWorldStudio.png (install python3 or ImageMagick)" >&2
    exit 0
  fi
  cp -f "$PNG" "$PNG_ALT" 2>/dev/null || ln -sf "$(basename "$PNG")" "$PNG_ALT" 2>/dev/null || cp -f "$PNG" "$PNG_ALT"
fi

if [[ ! -f "$ICO" ]] && command -v pwsh >/dev/null 2>&1 && [[ -f "${ROOT}/scripts/Ensure-StudioInstallerAssets.ps1" ]]; then
  pwsh -NoProfile -File "${ROOT}/scripts/Ensure-StudioInstallerAssets.ps1"
fi

echo "Installer assets ready: $ASSETS"
