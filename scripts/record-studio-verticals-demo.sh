#!/usr/bin/env bash
# Record Li World Studio per-vertical demo MP4 (HTML mocks + optional native present tick).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERT="$ROOT/deploy/studio-demo/screenshots/verticals"
PNG="$VERT/png"
MEDIA="$ROOT/docs/demo/media"
CHROME="${CHROME:-}"
DRY_RUN="${STUDIO_VERTICALS_DRY_RUN:-0}"

for c in "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" google-chrome chromium chromium-browser; do
  if [[ -x "$c" ]] || command -v "$c" >/dev/null 2>&1; then
    CHROME="$c"
    break
  fi
done

if [[ ! -f "$VERT/manifest.json" ]]; then
  echo "record-studio-verticals-demo: run generate-mocks.py first" >&2
  exit 2
fi

mkdir -p "$PNG" "$MEDIA"

if [[ "$DRY_RUN" == "1" ]]; then
  echo "record-studio-verticals-demo: dry-run — would capture:"
  for f in "$VERT"/*.html; do
    [[ -f "$f" ]] || continue
    echo "  file://$f -> $PNG/$(basename "$f" .html).png"
  done
  echo "  encode -> $MEDIA/studio-verticals-demo.mp4 (~75s @ 7×10s + 5s outro)"
  exit 0
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "record-studio-verticals-demo: install ffmpeg" >&2
  exit 3
fi

if [[ -z "$CHROME" ]]; then
  echo "record-studio-verticals-demo: Chrome/Chromium required" >&2
  exit 4
fi

echo "record-studio-verticals-demo: PNG capture (1920×1080)"
chmod +x "$VERT/capture.sh" 2>/dev/null || true
OUT="$PNG" bash "$VERT/capture.sh"

LIST="$MEDIA/ffmpeg-verticals-scenes.txt"
: >"$LIST"
dur="${STUDIO_VERTICAL_SCENE_SEC:-10}"
for id in game sim_rl sim_automotive sim_robotics sim_additive sim_scientific sim_drug_design; do
  png="$PNG/${id}.png"
  if [[ ! -f "$png" ]]; then
    echo "record-studio-verticals-demo: missing $png" >&2
    exit 5
  fi
  echo "file '${png}'" >>"$LIST"
  echo "duration ${dur}" >>"$LIST"
done
echo "file '${PNG}/game.png'" >>"$LIST"
echo "duration 5" >>"$LIST"

echo "record-studio-verticals-demo: encoding MP4"
ffmpeg -y -f concat -safe 0 -i "$LIST" \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2" \
  -c:v libx264 -pix_fmt yuv420p -r 30 \
  "$MEDIA/studio-verticals-demo.mp4" 2>/dev/null

ffdur=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \
  "$MEDIA/studio-verticals-demo.mp4" 2>/dev/null || echo "?")
echo "record-studio-verticals-demo: done → $MEDIA/studio-verticals-demo.mp4 (${ffdur}s)"

if [[ "${LIG_HOST_PRESENT:-0}" == "1" ]] && [[ -x "$ROOT/scripts/studio-shell-present-tick.sh" ]]; then
  echo "record-studio-verticals-demo: optional native present tick (not spliced into MP4 yet)"
  bash "$ROOT/scripts/studio-shell-present-tick.sh" >"$MEDIA/studio-verticals-present-tick.json" || true
fi

echo "Voiceover beats → docs/demo/studio-verticals-demo-script.md"
echo "Honesty matrix → docs/demo/VERTICALS-RECORDING.md"
