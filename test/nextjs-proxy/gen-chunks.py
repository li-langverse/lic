#!/usr/bin/env python3
"""Generate Next.js-like static chunks for TLS proxy integration test."""
from __future__ import annotations

import argparse
from pathlib import Path

CHUNKS = [
    ("_next/static/chunks/webpack-deadbeef.js", 15561),
    ("_next/static/chunks/main-deadbeef.js", 1321365),
    ("_next/static/chunks/framework-deadbeef.js", 198432),
    ("_next/static/chunks/pages/_app-deadbeef.js", 88421),
    ("_next/static/chunks/pages/index-deadbeef.js", 45120),
    ("_next/static/chunks/pages/sign_in-deadbeef.js", 92341),
    ("_next/static/css/deadbeef.css", 86772),
    ("_next/static/media/logo-deadbeef.woff2", 12480),
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
    scripts = []
    for relpath, nbytes in CHUNKS:
        path = out / relpath
        path.parent.mkdir(parents=True, exist_ok=True)
        unit = b"/* nextjs-proxy chunk */\n" if relpath.endswith(".js") or relpath.endswith(".css") else b"\x00"
        path.write_bytes(filler(unit, nbytes))
        assert path.stat().st_size == nbytes
        if relpath.endswith(".js"):
            scripts.append(f'<script src="/{relpath}" defer></script>')
        elif relpath.endswith(".css"):
            scripts.append(f'<link rel="stylesheet" href="/{relpath}">')
    index = out / "index.html"
    index.write_text(
        "<!DOCTYPE html><html><head>" + "".join(scripts) + "</head><body>next</body></html>\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
