#!/usr/bin/env python3
"""Generate a static site mimicking real websites: HTML + 18 parallel CSS/JS/font assets."""
from __future__ import annotations

import argparse
from pathlib import Path

ASSETS = [
    ("static/css/site.deadbeef.css", 835437, "text/css"),
    ("static/css/header.deadbeef.css", 460, "text/css"),
    ("static/css/footer.deadbeef.css", 86772, "text/css"),
    ("static/css/grid.deadbeef.css", 12480, "text/css"),
    ("static/css/theme.deadbeef.css", 98234, "text/css"),
    ("static/css/print.deadbeef.css", 44102, "text/css"),
    ("static/js/runtime.deadbeef.js", 15561, "application/javascript"),
    ("static/js/main.deadbeef.js", 1321365, "application/javascript"),
    ("static/js/vendor.deadbeef.js", 512000, "application/javascript"),
    ("static/js/analytics.deadbeef.js", 92341, "application/javascript"),
    ("static/js/search.deadbeef.js", 178432, "application/javascript"),
    ("static/js/comments.deadbeef.js", 88421, "application/javascript"),
    ("static/js/maps.deadbeef.js", 156789, "application/javascript"),
    ("static/js/ads.deadbeef.js", 45120, "application/javascript"),
    ("static/js/social.deadbeef.js", 203456, "application/javascript"),
    ("static/js/lazy.deadbeef.js", 112233, "application/javascript"),
    ("static/fonts/inter-regular.deadbeef.woff2", 245600, "font/woff2"),
    ("static/fonts/inter-bold.deadbeef.woff2", 319851, "font/woff2"),
    ("static/fonts/icons.deadbeef.woff2", 198432, "font/woff2"),
]


def filler(unit: bytes, nbytes: int) -> bytes:
    data = bytearray()
    while len(data) < nbytes:
        need = nbytes - len(data)
        data.extend(unit[:need])
    return bytes(data)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out-dir", type=Path, required=True)
    args = p.parse_args()
    out = args.out_dir
    out.mkdir(parents=True, exist_ok=True)

    head_links: list[str] = []
    body_scripts: list[str] = []
    for relpath, nbytes, kind in ASSETS:
        path = out / relpath
        path.parent.mkdir(parents=True, exist_ok=True)
        if kind == "text/css":
            unit = b"/* real-site integration filler */\n"
            path.write_bytes(filler(unit, nbytes))
            head_links.append(f'<link rel="stylesheet" href="/{relpath}">')
        elif kind == "font/woff2":
            unit = b"\x00\x01\x02\x03"
            path.write_bytes(filler(unit, nbytes))
            head_links.append(f'<link rel="preload" href="/{relpath}" as="font" type="font/woff2" crossorigin>')
        else:
            unit = b"!(function(){/* real-site */});\n"
            path.write_bytes(filler(unit, nbytes))
            body_scripts.append(f'<script src="/{relpath}" defer></script>')
        assert path.stat().st_size == nbytes
        print(f"gen-real-site: {path} ({nbytes} bytes)")

    index = out / "index.html"
    index.write_text(
        "<!DOCTYPE html>\n<html><head>\n"
        + "\n".join(head_links)
        + "\n</head><body>\n<h1>real-site</h1>\n"
        + "\n".join(body_scripts)
        + "\n</body></html>\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
