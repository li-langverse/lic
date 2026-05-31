#!/usr/bin/env python3
"""Binary-search li-studio lib.li for lic check error region."""
import json
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
lic = root / "build-wsl/compiler/lic/lic"
src = root / "packages/li-studio/src/lib.li"
lines = src.read_text(encoding="utf-8").splitlines(keepends=True)

# Keep header imports (until first def after imports)
header_end = 0
for i, ln in enumerate(lines):
    if ln.startswith("def ") and not ln.startswith("def li_std"):
        header_end = i
        break
header = "".join(lines[:header_end])


def err_count(body: str) -> int:
    stub = header + "\n# bisect stub\n" + body + "\n"
    with tempfile.NamedTemporaryFile("w", suffix=".li", delete=False, encoding="utf-8") as f:
        f.write(stub)
        path = f.name
    r = subprocess.run([str(lic), "check", "--format=json", path], capture_output=True, text=True)
    Path(path).unlink(missing_ok=True)
    try:
        d = json.loads(r.stdout or "{}")
    except json.JSONDecodeError:
        return 999
    return sum(1 for x in d.get("diagnostics", []) if x.get("severity") == "error")


defs: list[tuple[str, str]] = []
buf: list[str] = []
name = ""
for ln in lines[header_end:]:
    if ln.startswith("def "):
        if buf:
            defs.append((name, "".join(buf)))
        name = ln.strip().split("(")[0].replace("def ", "")
        buf = [ln]
    elif buf:
        buf.append(ln)
if buf:
    defs.append((name, "".join(buf)))

lo, hi = 0, len(defs)
while lo < hi:
    mid = (lo + hi) // 2
    body = "".join(b for _, b in defs[lo:mid])
    n = err_count(body)
    print(f"defs[{lo}:{mid}] ({mid-lo} procs) -> {n} errors")
    if n > 0:
        hi = mid
    else:
        lo = mid + 1

print(f"first error proc near index {lo}: {defs[lo][0] if lo < len(defs) else 'END'}")
