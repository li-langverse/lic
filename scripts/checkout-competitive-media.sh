#!/usr/bin/env bash
# Checkout competitor reference media into gitignored local folder.
# Links + analysis stay in docs/game-dev/competitive-intel/*.md (committed).
# Binaries: docs/game-dev/competitive-intel/media/local/** (see .gitignore)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${ROOT}/docs/game-dev/competitive-intel/media/local"
export ROOT
export BASE="${BASE#${ROOT}/}"

mkdir -p "${BASE}"/{unreal-engine,unity,godot,roblox,blender,figma,fortnite-uefn,capcut,paraview,comsol,cura,cursor,houdini,clips}

download() {
  local url="$1" dest="$2"
  if curl -fsSL "$url" -o "$dest"; then
    echo "  ok $(basename "$dest")"
    return 0
  fi
  echo "  fail $(basename "$dest") <- $url"
  return 1
}

echo "== Godot editor (official docs) =="
GD="https://docs.godotengine.org/en/4.5/_images"
mapfile -t godot_imgs < <(curl -fsSL "https://docs.godotengine.org/en/4.5/getting_started/introduction/first_look_at_the_editor.html" \
  | rg -o '_images/editor[^"'\'' ]+\.webp' | sort -u)
for p in "${godot_imgs[@]}"; do
  name=$(basename "$p")
  download "${GD}/${name}" "${BASE}/godot/${name}" || true
done

echo "== Unity UI Builder =="
UN="https://docs.unity3d.com/6000.6/Documentation/uploads/Main/UIBuilder"
for img in UIBuilderAnnotatedMainWindow UXMLPreviewPane CanvasSizeSettings DarkLightEditorTheme; do
  download "${UN}/${img}.png" "${BASE}/unity/${img}.png" || true
done

echo "== Roblox Studio (prod.docsiteassets.roblox.com) =="
RB="https://prod.docsiteassets.roblox.com/assets/studio"
declare -A roblox=(
  ["general/Toolbar-Mezzanine.png"]="toolbar-mezzanine.png"
  ["general/Mezzanine-Testing-Controls.png"]="mezzanine-testing.png"
  ["general/Mezzanine-Right.png"]="mezzanine-right.png"
  ["general/Editor-Window.jpg"]="editor-window.jpg"
  ["general/Docking-Grouped-Tabs.png"]="docking-grouped-tabs.png"
  ["explorer/Parent-Child-Hierarchy.png"]="explorer-hierarchy.png"
)
for path in "${!roblox[@]}"; do
  download "${RB}/${path}" "${BASE}/roblox/${roblox[$path]}" || true
done

echo "== Blender VSE =="
download "https://docs.blender.org/manual/en/latest/_images/editors_vse_overview.svg" \
  "${BASE}/blender/vse-overview.svg" || true
download "https://docs.blender.org/manual/en/latest/_images/editors_vse_view_types.svg" \
  "${BASE}/blender/vse-view-types.svg" || true

echo "== Figma UI3 blog hero =="
download "https://cdn.sanity.io/images/599r6htc/regionalized/97284b712a3df41c61698edaeb20fd9146c66af3-1608x1072.png?w=1200&q=70&fit=max&auto=format" \
  "${BASE}/figma/ui3-redesign-hero.png" || true

echo "== CapCut desktop (marketing / resource pages) =="
CC_PAGE="https://www.capcut.com/resource/how-to-use-capcut-on-pc/"
mapfile -t cc_imgs < <(curl -fsSL "$CC_PAGE" 2>/dev/null | rg -o 'https://p16[^"'\'' ]+\.webp' | sort -u | head -8)
i=0
for url in "${cc_imgs[@]}"; do
  i=$((i + 1))
  download "$url" "${BASE}/capcut/desktop-ui-$(printf '%02d' "$i").webp" || true
done

echo "== ParaView docs (pipeline browser figures) =="
curl -fsSL "https://docs.paraview.org/en/latest/UsersGuide.html" 2>/dev/null | rg -o '_images/[^"'\'' ]+\.(png|webp|jpg)' | sort -u | head -5 | while read -r p; do
  name=$(basename "$p")
  download "https://docs.paraview.org/en/latest/${p}" "${BASE}/paraview/${name}" || true
done

echo "== YouTube thumbnails (from catalog.json demo entries) =="
python3 - <<'PY'
import json, os, subprocess
from pathlib import Path

root = Path(os.environ["ROOT"])
catalog = root / "docs/game-dev/competitive-intel/catalog.json"
clips = root / os.environ["BASE"] / "clips"
data = json.loads(catalog.read_text())
for e in data.get("entries", []):
    yid = e.get("youtube_id")
    if not yid:
        continue
    slug = e["id"].lower().replace("-", "_")
    dest = clips / f"{slug}-thumb.jpg"
    for url in (
        f"https://i.ytimg.com/vi/{yid}/maxresdefault.jpg",
        f"https://i.ytimg.com/vi/{yid}/hqdefault.jpg",
    ):
        r = subprocess.run(
            ["curl", "-fsSL", url, "-o", str(dest)],
            capture_output=True,
        )
        if r.returncode == 0:
            print(f"  ok {dest.name}")
            break
    else:
        print(f"  fail {slug}")
PY

echo "== Unreal Sequencer (Epic docs CDN) =="
UE="https://d1iv7db44yhgxn.cloudfront.net/documentation/images"
declare -A ue=(
  ["d6f13bae-0c80-4a49-be8a-8de27538deb0/sequenceasset.png"]="sequencer-sequence-asset.png"
  ["ebbb1c16-6495-448b-8fa3-f19af40e5d67/createseq.png"]="sequencer-create.png"
  ["6b60fd77-8c0c-4f6e-abce-e9dceaddf151/seqopen.png"]="sequencer-open.png"
)
for path in "${!ue[@]}"; do
  download "${UE}/${path}" "${BASE}/unreal-engine/${ue[$path]}" || true
done

echo "== Write manifest =="
export ROOT BASE
python3 - <<'PY'
import json, os, time
from pathlib import Path

base = Path(os.environ["ROOT"]) / os.environ["BASE"]
files = []
for p in sorted(base.rglob("*")):
    if p.is_file() and p.name not in (".gitkeep", "manifest.json"):
        rel = p.relative_to(base).as_posix()
        files.append({
            "local_path": rel,
            "bytes": p.stat().st_size,
            "competitor": rel.split("/")[0],
        })
manifest = {
    "schema": "competitive_intel_local_v1",
    "checked_out": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "policy": "gitignored_local_only",
    "file_count": len(files),
    "files": files,
}
out = base / "manifest.json"
out.write_text(json.dumps(manifest, indent=2) + "\n")
print(f"Wrote {out} ({len(files)} files)")
PY

echo "Done. Open: ${BASE}/"
