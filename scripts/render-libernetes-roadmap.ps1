# Re-render libernetes roadmap PNGs from docs/.mermaid-tmp/*.mmd
# Requires: Node.js (npx @mermaid-js/mermaid-cli), Python 3 + Pillow
# Usage: pwsh scripts/render-libernetes-roadmap.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$Docs = Join-Path $Root "docs"
$Tmp = Join-Path $Docs ".mermaid-tmp"
$Mmdc = "npx", "-y", "@mermaid-js/mermaid-cli"

$Diagrams = @(
    @{ Name = "waves";         Height = 600;  Out = "libernetes-roadmap-waves.png" },
    @{ Name = "bootstrap";     Height = 1200; Out = "libernetes-roadmap-bootstrap.png" },
    @{ Name = "cluster-ops";   Height = 1000; Out = "libernetes-roadmap-cluster-ops.png" },
    @{ Name = "architecture";  Height = 1200; Out = "libernetes-roadmap-architecture.png" }
)

foreach ($d in $Diagrams) {
    $in = Join-Path $Tmp "roadmap-$($d.Name).mmd"
    $out = Join-Path $Docs $d.Out
    if (-not (Test-Path $in)) {
        throw "Missing mermaid source: $in"
    }
    Write-Host "Rendering $($d.Out) ..."
    & $Mmdc[0] $Mmdc[1] $Mmdc[2] `
        -i $in -o $out `
        -w 3200 -H $d.Height -b white -s 2
}

$stackScript = @'
import os
from PIL import Image

docs = os.environ["LIB_ROADMAP_DOCS"]
parts = [
    "libernetes-roadmap-waves.png",
    "libernetes-roadmap-bootstrap.png",
    "libernetes-roadmap-cluster-ops.png",
]
target_width = 3200
gap = 48

images = []
for name in parts:
    path = os.path.join(docs, name)
    img = Image.open(path).convert("RGB")
    ratio = target_width / img.width
    resized = img.resize((target_width, int(img.height * ratio)), Image.LANCZOS)
    images.append(resized)

total_h = sum(img.height for img in images) + gap * (len(images) - 1)
canvas = Image.new("RGB", (target_width, total_h), "white")
y = 0
for idx, img in enumerate(images):
    canvas.paste(img, (0, y))
    y += img.height
    if idx < len(images) - 1:
        y += gap

out = os.path.join(docs, "libernetes-roadmap.png")
canvas.save(out)
print(f"Wrote {out} ({target_width}x{total_h})")
'@

Write-Host "Stacking combined roadmap ..."
$env:LIB_ROADMAP_DOCS = $Docs
$stackScript | python -

Write-Host "Done. PNGs in $Docs"
