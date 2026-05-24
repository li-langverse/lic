#!/usr/bin/env python3
"""Write .canvas.status.json so the IDE picks up external canvas refreshes."""
from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: write-canvas-status.py <path/to/name.canvas.tsx>", file=sys.stderr)
        return 2
    canvas = Path(sys.argv[1]).expanduser()
    if canvas.name.endswith(".canvas.tsx"):
        status = canvas.with_name(canvas.name[: -len(".tsx")] + ".status.json")
    else:
        status = canvas.with_suffix(".status.json")
    payload = {
        "status": "rendered",
        "refreshedAt": datetime.now(timezone.utc).isoformat(),
        "source": str(canvas),
    }
    status.parent.mkdir(parents=True, exist_ok=True)
    status.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(f"canvas-status: {status}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
