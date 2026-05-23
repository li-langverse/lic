#!/usr/bin/env bash
# Refresh offline competitor UI snapshots for agents (Layer C intel).
# Usage:
#   ./scripts/fetch-competitive-intel.sh           # curl HTML snapshots
#   ./scripts/fetch-competitive-intel.sh --tavily  # + Tavily research (needs TAVILY_API_KEY)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/docs/game-dev/competitive-intel/downloads"
mkdir -p "$DEST"
export PATH="${HOME}/.local/bin:${PATH}"

fetch() {
  local name="$1" url="$2"
  echo "==> $name"
  curl -fsSL -o "$DEST/$name" "$url"
}

fetch "paraview-properties-panel.html" \
  "https://docs.paraview.org/en/latest/ReferenceManual/propertiesPanel.html"
fetch "prusa-ui-overview.html" \
  "https://help.prusa3d.com/article/ui-overview_1766"
fetch "blender-panel-api.html" \
  "https://docs.blender.org/api/current/bpy.types.Panel.html"

if [[ "${1:-}" == "--tavily" ]]; then
  if [[ -z "${TAVILY_API_KEY:-}" ]]; then
    echo "TAVILY_API_KEY not set — source ~/Documents/Cursor/.env" >&2
    exit 1
  fi
  command -v tvly >/dev/null 2>&1 || {
    echo "tvly missing — run: ./scripts/setup-tavily-cli.sh" >&2
    exit 1
  }
  echo "==> tavily research (drug-discovery UI)"
  tvly research "Drug discovery lab in the loop UI Benchling LiveDesign Recursion LOWE workflow stages" \
    --model mini -o "$DEST/research-drug-discovery-ui.md"
  echo "==> tavily research (scientific editor docking)"
  tvly research "ParaView Blender Unreal dockable panel UI best practices scientific simulation" \
    --model mini -o "$DEST/research-scientific-editor-ui.md"
  echo "==> tavily search (robotics sim UI)"
  tvly search "NVIDIA Isaac Sim editor UI viewport" --json -o "$DEST/search-isaac-sim-ui.json"
  tvly search "Unreal Engine dock tab layout editor" --json -o "$DEST/search-unreal-dock-ui.json"
fi

MANIFEST="$ROOT/docs/game-dev/competitive-intel/sources.manifest.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$MANIFEST" "${1:-}" <<'PY'
import json, sys
from datetime import date
path = sys.argv[1]
tavily = len(sys.argv) > 2 and sys.argv[2] == "--tavily"
data = json.load(open(path))
data["last_fetched"] = date.today().isoformat()
if tavily:
    data["last_tavily"] = date.today().isoformat()
json.dump(data, open(path, "w"), indent=2)
print(f"updated {path}")
PY
fi

echo "ok: competitive intel in $DEST"
