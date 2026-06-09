#!/usr/bin/env python3
"""Generate backend static assets for TLS proxy repro (multi-size CSS/JS)."""
from __future__ import annotations

import argparse
from pathlib import Path

# GitLab sign_in representative sizes (bytes)
ASSETS = [
    ("assets/application-deadbeef.css", 835437, "text/css"),
    ("assets/page_bundles/login-deadbeef.css", 460, "text/css"),
    ("assets/tailwind-deadbeef.css", 86772, "text/css"),
    ("assets/webpack/runtime.deadbeef.bundle.js", 15561, "application/javascript"),
    ("assets/webpack/main.deadbeef.chunk.js", 1321365, "application/javascript"),
    ("assets/webpack/super_sidebar.deadbeef.chunk.js", 319851, "application/javascript"),
]
CSS_NAME = ASSETS[0][0].split("/")[-1]


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

    links: list[str] = []
    scripts: list[str] = []
    for relpath, nbytes, kind in ASSETS:
        path = out / relpath
        path.parent.mkdir(parents=True, exist_ok=True)
        if kind == "text/css":
            unit = b"/* li-httpd proxy-repro filler */\n"
            path.write_bytes(filler(unit, nbytes))
            links.append(f'<link rel="stylesheet" href="/{relpath}">')
        else:
            unit = b"!(function(){/* li-httpd proxy-repro */});\n"
            path.write_bytes(filler(unit, nbytes))
            scripts.append(f'<script src="/{relpath}" defer></script>')
        assert path.stat().st_size == nbytes
        print(f"gen-asset: {path} ({nbytes} bytes)")

    sign_in = out / "users" / "sign_in"
    sign_in.parent.mkdir(parents=True, exist_ok=True)
    sign_in.write_text(
        "<!DOCTYPE html>\n<html><head>\n"
        + "\n".join(links)
        + "\n"
        + "\n".join(scripts)
        + "\n</head><body>sign in</body></html>\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
