#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[1]
lic = root / "build-wsl/compiler/lic/lic"
pkgs = [
    "li-sim-viz",
    "li-scene",
    "li-world",
    "li-physics-runtime",
    "li-assets",
    "li-sim-automotive",
    "li-sim-sensors",
    "li-sim-drug-design",
    "li-render",
    "li-studio",
]
for pkg in pkgs:
    f = root / "packages" / pkg / "src" / "lib.li"
    if not f.exists():
        print(f"{pkg}: missing")
        continue
    r = subprocess.run(
        [str(lic), "check", "--format=json", str(f)],
        capture_output=True,
        text=True,
    )
    d = json.loads(r.stdout or "{}")
    errs = [x for x in d.get("diagnostics", []) if x.get("severity") == "error"]
    print(f"{pkg}: ok={d.get('ok')} errs={len(errs)}")
    for e in errs[:8]:
        loc = f"{e.get('file')}:{e.get('line')}"
        print(f"  {loc} {e.get('code')}: {e.get('message', '')[:72]}")
