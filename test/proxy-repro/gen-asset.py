#!/usr/bin/env python3
"""Generate backend static assets matching GitLab CSS probe size (835437 bytes)."""
from __future__ import annotations

import argparse
from pathlib import Path

DEFAULT_BYTES = 835437
CSS_NAME = "application-deadbeef.css"


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--out-dir", type=Path, required=True)
    p.add_argument("--bytes", type=int, default=DEFAULT_BYTES)
    args = p.parse_args()
    out = args.out_dir
    out.mkdir(parents=True, exist_ok=True)

    css_path = out / "assets" / CSS_NAME
    css_path.parent.mkdir(parents=True, exist_ok=True)
    # Repeatable filler — not valid CSS, but stable byte count for curl probes.
    unit = b"/* li-httpd proxy-repro filler */\n"
    data = bytearray()
    while len(data) < args.bytes:
        need = args.bytes - len(data)
        data.extend(unit[:need])
    css_path.write_bytes(data)
    assert css_path.stat().st_size == args.bytes

    sign_in = out / "users" / "sign_in"
    sign_in.parent.mkdir(parents=True, exist_ok=True)
    sign_in.write_text(
        f"""<!DOCTYPE html>
<html><head>
<link rel="stylesheet" href="/assets/{CSS_NAME}">
</head><body>sign in</body></html>
""",
        encoding="utf-8",
    )
    print(f"gen-asset: {css_path} ({args.bytes} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
