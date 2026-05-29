#!/usr/bin/env bash
# Capture vertical PNGs via li-studio-demo + LIG_HOST_PRESENT (Li-native path; WP-UX-14b Step 1).
# Falls back to studio-verticals-capture-native.sh (C paint_blit) when demo binary missing.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEMO="${STUDIO_LI_DEMO_BIN:-$ROOT/build/li-studio-demo}"
PNG_DIR="${STUDIO_VERTICALS_NATIVE_PNG_DIR:-$ROOT/docs/demo/media/native-verticals/png}"
FRAMES="${STUDIO_DEMO_FRAMES:-1}"

if [[ ! -x "$DEMO" ]]; then
  echo "studio-verticals-capture-li-demo: $DEMO missing; run:" >&2
  echo "  lic build --allow-open-vc --no-lean-verify packages/li-studio/src/main.li -o build/li-studio-demo" >&2
  echo "studio-verticals-capture-li-demo: falling back to C paint_blit capture" >&2
  exec "$ROOT/scripts/studio-verticals-capture-native.sh"
fi

mkdir -p "$PNG_DIR"
export LIG_HOST_PRESENT=1
profiles=(game sim_rl sim_automotive sim_robotics sim_additive sim_scientific sim_drug_design)
ids=(1 2 3 4 5 6 7)
for i in "${!profiles[@]}"; do
  slug="${profiles[$i]}"
  pid="${ids[$i]}"
  STUDIO_DEMO_PROFILE="$slug" STUDIO_DEMO_FRAMES="$FRAMES" "$DEMO" || {
    echo "studio-verticals-capture-li-demo: $slug demo failed" >&2
    exit 1
  }
  echo "studio-verticals-capture-li-demo: $slug tick ok (profile_id=$pid; PNG readback Step 1 TBD)"
done
echo "studio-verticals-capture-li-demo: demo ticks complete; wire RenderReadPixels → $PNG_DIR in Step 1"
