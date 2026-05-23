#!/usr/bin/env bash
# Refresh offline competitor UI snapshots for agents (Layer C intel).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/docs/game-dev/competitive-intel/downloads"
mkdir -p "$DEST"

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

MANIFEST="$ROOT/docs/game-dev/competitive-intel/sources.manifest.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$MANIFEST" <<'PY'
import json, sys
from datetime import date
path = sys.argv[1]
data = json.load(open(path))
data["last_fetched"] = date.today().isoformat()
json.dump(data, open(path, "w"), indent=2)
print(f"updated last_fetched in {path}")
PY
fi

echo "ok: competitive intel snapshots in $DEST"
