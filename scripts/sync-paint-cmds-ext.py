#!/usr/bin/env python3
"""Mirror packages/li-ui/src/paint_cmds_ext.li into lib.li between marker comments."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXT = ROOT / "packages/li-ui/src/paint_cmds_ext.li"
LIB = ROOT / "packages/li-ui/src/lib.li"
BEGIN = "# BEGIN paint-cmds-ext (scripts/sync-paint-cmds-ext.py)"
END = "# END paint-cmds-ext"


def fail(msg: str) -> None:
    print(f"sync-paint-cmds-ext: {msg}", file=sys.stderr)
    sys.exit(1)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args()
    if not EXT.is_file():
        fail(f"missing {EXT}")
    if not LIB.is_file():
        fail(f"missing {LIB}")
    body = EXT.read_text(encoding="utf-8").rstrip() + "\n"
    block = f"{BEGIN}\n# Mirrored for `import ui` — edit src/paint_cmds_ext.li + re-run sync.\n\n{body}{END}\n"
    text = LIB.read_text(encoding="utf-8")
    if BEGIN not in text or END not in text:
        fail(f"markers missing in {LIB}")
    start = text.index(BEGIN)
    end = text.index(END) + len(END)
    next_text = text[:start] + block + text[end + 1 :]
    if args.verify:
        if next_text != text:
            fail("lib.li paint-cmds-ext mirror out of date (run sync-paint-cmds-ext.py)")
        print("sync-paint-cmds-ext: verify ok")
        return 0
    LIB.write_text(next_text, encoding="utf-8", newline="\n")
    print(f"sync-paint-cmds-ext: updated {LIB.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
