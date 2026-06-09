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

$pngScript = @'
import os
import sys
from PIL import Image

PNG_KWARGS = {"format": "PNG", "optimize": False, "compress_level": 6}


def save_windows_png(img: Image.Image, path: str) -> None:
    if img.mode == "P":
        img = img.convert("RGBA")
    elif img.mode not in ("RGB", "RGBA"):
        img = img.convert("RGB")
    img.save(path, **PNG_KWARGS)


def normalize_png(path: str) -> None:
    with Image.open(path) as img:
        img.load()
        save_windows_png(img.copy(), path)
    print(f"Normalized {path}")


def stack_roadmap(docs: str) -> None:
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
        with Image.open(path) as img:
            rgb = img.convert("RGB")
        ratio = target_width / rgb.width
        resized = rgb.resize((target_width, int(rgb.height * ratio)), Image.LANCZOS)
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
    save_windows_png(canvas, out)
    print(f"Wrote {out} ({target_width}x{total_h})")


if __name__ == "__main__":
    mode = sys.argv[1]
    docs = os.environ["LIB_ROADMAP_DOCS"]
    if mode == "normalize":
        for name in sys.argv[2:]:
            normalize_png(os.path.join(docs, name))
    elif mode == "stack":
        stack_roadmap(docs)
    else:
        raise SystemExit(f"unknown mode: {mode}")
'@

$diagramNames = $Diagrams | ForEach-Object { $_.Out }
Write-Host "Normalizing mmdc PNGs for Windows shell viewers ..."
$env:LIB_ROADMAP_DOCS = $Docs
$pngScript | python - normalize @diagramNames

Write-Host "Stacking combined roadmap ..."
$pngScript | python - stack

Write-Host "Done. PNGs in $Docs"
