#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export ROOT
exec python3 - <<'PY'
import json, os, re
from pathlib import Path
ROOT = Path(os.environ["ROOT"])
TR = re.compile(r"^theorem\s+(\w+)")
def cls(n,b):
    if re.search(r"placeholder", n, re.I): return "placeholder"
    if re.search(r"\bsorry\b", b): return "open"
    if b.strip().endswith(":= trivial"): return "placeholder"
    if ":= rfl" in b or ":= by" in b or "_proved" in n: return "proved"
    return "proved"
def scan(p, ns, src):
    if not p.is_file(): return []
    lines=p.read_text().splitlines(); out=[]; i=0
    while i<len(lines):
        m=TR.match(lines[i].strip())
        if not m: i+=1; continue
        name=m.group(1); ch=[lines[i]]; i+=1
        while i<len(lines):
            if TR.match(lines[i].strip()): break
            ch.append(lines[i])
            if ":=" in lines[i]: break
            i+=1
        out.append({"id":f"{ns}.{name}","status":cls(name,"\n".join(ch)),"source":src,"file":str(p.relative_to(ROOT))})
    return out
rec=[]
rec.extend(scan(ROOT/"docs/semantics/Discharge.lean","Li.Discharge","discharge"))
for rel,ns,src in [("docs/semantics/Core.lean","Li","core"),("proof-db/lean/ProofDB.lean","Li.ProofDB","proofdb"),("build/generated/AutoVC.lean","AutoVC","autovc")]:
    rec.extend(scan(ROOT/rel,ns,src))
rec.sort(key=lambda r:r["id"])
for r in rec: print(json.dumps(r,separators=(",",":")))
PY
