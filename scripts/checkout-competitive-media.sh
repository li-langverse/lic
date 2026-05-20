#!/usr/bin/env bash
# Checkout competitor reference media into gitignored local folder.
# Links + analysis stay in docs/game-dev/competitive-intel/*.md (committed).
# Binaries: docs/game-dev/competitive-intel/media/local/** (see .gitignore)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASE="${ROOT}/docs/game-dev/competitive-intel/media/local"
export ROOT
export BASE="${BASE#${ROOT}/}"

DIRS=(
  unreal-engine unity godot roblox blender figma fortnite-uefn
  capcut paraview comsol cura cursor houdini davinci vscode
  simscale benchling comfyui prusa gazebo clips
)
for d in "${DIRS[@]}"; do mkdir -p "${BASE}/${d}"; done

download() {
  local url="$1" dest="$2"
  if curl -fsSL -A "Mozilla/5.0 (compatible; LiIntelCheckout/1.0)" "$url" -o "$dest"; then
    echo "  ok $(basename "$dest")"
    return 0
  fi
  echo "  fail $(basename "$dest")"
  return 1
}

yt_thumb() {
  local id="$1" slug="$2"
  local dest="${BASE}/clips/${slug}-thumb.jpg"
  download "https://i.ytimg.com/vi/${id}/maxresdefault.jpg" "$dest" \
    || download "https://i.ytimg.com/vi/${id}/hqdefault.jpg" "$dest" || true
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

echo "== Roblox Studio =="
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

echo "== Figma UI3 =="
download "https://cdn.sanity.io/images/599r6htc/regionalized/97284b712a3df41c61698edaeb20fd9146c66af3-1608x1072.png?w=1200&q=70&fit=max&auto=format" \
  "${BASE}/figma/ui3-redesign-hero.png" || true

echo "== CapCut desktop =="
CC_PAGE="https://www.capcut.com/resource/how-to-use-capcut-on-pc/"
mapfile -t cc_imgs < <(curl -fsSL "$CC_PAGE" 2>/dev/null | rg -o 'https://p16[^"'\'' ]+\.webp' | sort -u | head -12)
i=0
for url in "${cc_imgs[@]}"; do
  i=$((i + 1))
  download "$url" "${BASE}/capcut/desktop-ui-$(printf '%02d' "$i").webp" || true
done

echo "== Unreal Sequencer (Epic CDN) =="
UE="https://d1iv7db44yhgxn.cloudfront.net/documentation/images"
declare -A ue=(
  ["d6f13bae-0c80-4a49-be8a-8de27538deb0/sequenceasset.png"]="sequencer-sequence-asset.png"
  ["ebbb1c16-6495-448b-8fa3-f19af40e5d67/createseq.png"]="sequencer-create.png"
  ["6b60fd77-8c0c-4f6e-abce-e9dceaddf151/seqopen.png"]="sequencer-open.png"
)
for path in "${!ue[@]}"; do
  download "${UE}/${path}" "${BASE}/unreal-engine/${ue[$path]}" || true
done

echo "== VS Code interface (docs) =="
VSC="https://code.visualstudio.com/assets/docs/getstarted/userinterface"
for img in hero sidebyside tabs-editor-groups floating-editor minimap; do
  download "${VSC}/${img}.png" "${BASE}/vscode/${img}.png" || true
done

echo "== Cursor =="
download "https://cursor.com/public/opengraph-image.png" "${BASE}/cursor/og-product.png" || true

echo "== DaVinci Resolve (cut/edit UI promos) =="
BMD="https://images.blackmagicdesign.com/images/products/davinciresolve"
for pair in \
  "cut/automatic/automatic-xl.jpg:cut-automatic-ui.jpg" \
  "edit/addeffects/addeffects-xl.jpg:edit-effects-ui.jpg"; do
  path="${pair%%:*}"; name="${pair##*:}"
  download "${BMD}/${path}" "${BASE}/davinci/${name}" || true
done

echo "== Houdini (SideFX product shots) =="
download "https://media.sidefx.com/uploads/products/houdini20/overview/h20_nodes2.png" \
  "${BASE}/houdini/h20-nodes.png" || true
download "https://media.sidefx.com/uploads/products/houdini20/overview/h20_pipeline.png" \
  "${BASE}/houdini/h20-pipeline.png" || true
download "https://media.sidefx.com/uploads/products/overview/coffee_mix_mpm.png" \
  "${BASE}/houdini/overview-network.png" || true

echo "== SimScale / COMSOL / Benchling (marketing UI) =="
download "https://frontend-assets.simscale.com/media/2017/03/Website_Banner_Product-tour-368x250.jpg" \
  "${BASE}/simscale/product-tour.jpg" || true
download "https://frontend-assets.simscale.com/media/2026/02/cfd_cover_image_1x-368x250.webp" \
  "${BASE}/simscale/cfd-cover.webp" || true
download "https://cdn.comsol.com/blog/COMSOL_Blog_OG_Home.png" \
  "${BASE}/comsol/blog-og.png" || true
download "https://images.ctfassets.net/kzeezny59h5p/7jzaiOP1IQTVCPOS1ogiN2/d5d39570218a62727dfdf764b2dec402/Platform.png" \
  "${BASE}/benchling/platform-ui.png" || true

echo "== ParaView (docs + Cornell CVW) =="
curl -fsSL "https://docs.paraview.org/en/latest/Tutorials/SelfDirectedTutorial/basicUsage.html" 2>/dev/null \
  | rg -o '_images/[^"'\'' ]+\.(png|webp|jpg)' | sort -u | head -6 | while read -r p; do
  download "https://docs.paraview.org/en/latest/${p}" "${BASE}/paraview/$(basename "$p")" || true
done
curl -fsSL "https://cvw.cac.cornell.edu/paraview/user-interface/pipeline-browser" 2>/dev/null \
  | rg -io 'https?://[^"'\'' ]+\.(png|jpg)' | head -3 | while read -r url; do
  download "$url" "${BASE}/paraview/cvw-$(basename "$url")" || true
done

echo "== Prusa / Cura (web + thumbs) =="
download "https://www.prusa3d.com/img/eshop_og_image.jpg" "${BASE}/prusa/og-prusaslicer.jpg" || true

echo "== Extra tutorial thumbnails (dimension backlog) =="
declare -A extra_yt=(
  ["qHJSz4V7DJk"]="cura_5_interface"
  ["2ZZ4eVWmwtg"]="paraview_intro"
  ["J7LpydZu7yQ"]="capcut_pc"
  ["sTfv3NVoJ70"]="davinci_resolve_18_ui"
  ["0yGJDyQwezk"]="comsol_model_builder"
  ["by7QPeQH8ZY"]="uefn_first_game"
)
for id in "${!extra_yt[@]}"; do
  yt_thumb "$id" "${extra_yt[$id]}"
done

echo "== YouTube thumbnails (catalog.json) =="
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
    if dest.exists():
        print(f"  skip {dest.name} (exists)")
        continue
    for url in (
        f"https://i.ytimg.com/vi/{yid}/maxresdefault.jpg",
        f"https://i.ytimg.com/vi/{yid}/hqdefault.jpg",
    ):
        r = subprocess.run(
            ["curl", "-fsSL", "-A", "Mozilla/5.0", url, "-o", str(dest)],
            capture_output=True,
        )
        if r.returncode == 0:
            print(f"  ok {dest.name}")
            break
    else:
        print(f"  fail {slug}")
PY

echo "== Write manifest =="
python3 - <<'PY'
import json, time
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
    "schema": "competitive_intel_local_v2",
    "checked_out": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "policy": "gitignored_local_only",
    "file_count": len(files),
    "files": files,
}
(base / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(f"Wrote manifest ({len(files)} files)")
PY

echo "Done: ${BASE}/"
echo "Study notes: docs/game-dev/competitive-intel/material-study-notes.md"
