#!/usr/bin/env python3
"""Generate Next.js-like static chunks for TLS proxy integration test (18+ assets)."""
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
    ("_next/static/chunks/pages/dashboard-deadbeef.js", 156789),
    ("_next/static/chunks/pages/settings-deadbeef.js", 112233),
    ("_next/static/chunks/pages/profile-deadbeef.js", 203456),
    ("_next/static/chunks/pages/admin-deadbeef.js", 178432),
    ("_next/static/chunks/pages/api-deadbeef.js", 45120),
    ("_next/static/chunks/pages/docs-deadbeef.js", 92341),
    ("_next/static/chunks/pages/search-deadbeef.js", 88421),
    ("_next/static/chunks/pages/notifications-deadbeef.js", 156789),
    ("_next/static/chunks/pages/projects-deadbeef.js", 112233),
    ("_next/static/css/deadbeef.css", 86772),
    ("_next/static/css/theme-deadbeef.css", 12480),
    ("_next/static/media/logo-deadbeef.woff2", 12480),
    ("_next/static/media/icons-deadbeef.woff2", 245600),
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
        if relpath.endswith(".woff2"):
            unit = b"\x00\x01\x02\x03"
        else:
            unit = b"/* nextjs-proxy chunk */\n"
        path.write_bytes(filler(unit, nbytes))
        assert path.stat().st_size == nbytes
        if relpath.endswith(".js"):
            scripts.append(f'<script src="/{relpath}" defer></script>')
        elif relpath.endswith(".css"):
            scripts.append(f'<link rel="stylesheet" href="/{relpath}">')
        elif relpath.endswith(".woff2"):
            scripts.append(f'<link rel="preload" href="/{relpath}" as="font" type="font/woff2" crossorigin>')
    index = out / "index.html"
    index.write_text(
        "<!DOCTYPE html><html><head>" + "".join(scripts) + "</head><body>next</body></html>\n",
        encoding="utf-8",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
