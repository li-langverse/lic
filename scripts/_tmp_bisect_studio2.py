#!/usr/bin/env python3
import json
import re
import subprocess
import tempfile
from pathlib import Path

root = Path(__file__).resolve().parents[1]
lic = root / "build-wsl/compiler/lic/lic"

def load(path: str) -> str:
    r = subprocess.run(
        ["git", "-C", str(root), "show", path],
        capture_output=True,
        text=True,
        check=True,
    )
    return r.stdout

def split_defs(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    cur_name = ""
    buf: list[str] = []
    for ln in text.splitlines(keepends=True):
        if ln.startswith("def "):
            if cur_name:
                out[cur_name] = "".join(buf)
            cur_name = ln.split("(")[0].replace("def ", "").strip()
            buf = [ln]
        elif cur_name:
            buf.append(ln)
    if cur_name:
        out[cur_name] = "".join(buf)
    return out

main = split_defs(load("main:packages/li-studio/src/lib.li"))
branch = split_defs(load("HEAD:packages/li-studio/src/lib.li"))
added = [n for n in branch if n not in main]
print(f"main={len(main)} branch={len(branch)} added={len(added)}")

# Rebuild file: main text + subset of added defs (preserve branch order)
branch_text = (root / "packages/li-studio/src/lib.li").read_text(encoding="utf-8")
# header through last import / before first def
m = re.search(r"^def ", branch_text, re.MULTILINE)
header = branch_text[: m.start()] if m else ""

def check_names(names: list[str]) -> int:
    body = header + "".join(branch[n] for n in added if n in names)
    with tempfile.NamedTemporaryFile("w", suffix=".li", delete=False, encoding="utf-8") as f:
        f.write(body)
        path = Path(f.name)
    r = subprocess.run([str(lic), "check", "--format=json", str(path)], capture_output=True, text=True)
    path.unlink(missing_ok=True)
    d = json.loads(r.stdout or "{}")
    return sum(1 for x in d.get("diagnostics", []) if x.get("severity") == "error")

# names only in added list, binary search first bad
subset = list(added)
lo, hi = 0, len(subset)
while lo < hi:
    mid = (lo + hi) // 2
    n = check_names(subset[:mid])
    print(f"added[:{mid}] -> {n} errors")
    if n > 0:
        hi = mid
    else:
        lo = mid + 1

first = subset[lo] if lo < len(subset) else "NONE"
print(f"first added proc introducing errors: {first} (index {lo})")
if lo < len(subset):
    n_one = check_names([first])
    print(f"  alone -> {n_one} errors")
