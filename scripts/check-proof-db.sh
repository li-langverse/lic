#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="${ROOT}/proof-db/manifest.toml"
[[ "${PROOF_DB_SKIP:-0}" == "1" ]] && { echo "check-proof-db: skipped"; exit 0; }
[[ -f "$MANIFEST" ]] || { echo "check-proof-db: missing manifest" >&2; exit 1; }
python3 - "$ROOT" "${ROOT}/proof-db" "$MANIFEST" <<'PY'
import re, sys
from pathlib import Path
root, db, mp = Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3])
assert re.search(r"^schema_version\s*=\s*1\s*$", mp.read_text(), re.M)
def pm(p):
    cfg, inc, sec = {}, [], None
    for line in p.read_text().splitlines():
        line=line.split("#",1)[0].strip()
        if not line: continue
        if line=="[config]": sec="config"; continue
        if line.startswith("[[includes]]"): sec="includes"; continue
        if sec=="config" and "=" in line: k,v=line.split("=",1); cfg[k.strip()]=v.strip().strip('"')
        if sec=="includes" and line.startswith("path"): inc.append(line.split("=",1)[1].strip().strip('"'))
    return cfg, inc
def pe(p):
    d={}
    for line in p.read_text().splitlines():
        line=line.split("#",1)[0].strip()
        if not line or line.startswith("[") or line.startswith("evidence") or "=" not in line: continue
        k,v=line.split("=",1); d[k.strip()]=v.strip().strip('"')
    return d
cfg, inc = pm(mp)
for k in ("gaps_doc","roadmap_doc","spec_doc"):
    if k not in cfg or not (root/cfg[k]).is_file(): sys.exit(f"check-proof-db: bad {k}")
req={"id","kind","field","statement","proof_status","release_pin"}
errs=0; ids=set()
for rel in inc:
    ep=db/rel
    if not ep.is_file(): print("missing",ep,file=sys.stderr); errs+=1; continue
    r=pe(ep)
    if req-r.keys(): print("fields",rel,file=sys.stderr); errs+=1; continue
    if r["proof_status"] not in {"proved","open","discrepancy","axiomatic"} or r["kind"] not in {"axiom","lemma"}:
        print("enum",rel,file=sys.stderr); errs+=1
    if r["id"] in ids: print("dup",r["id"],file=sys.stderr); errs+=1
    ids.add(r["id"])
    if r["kind"]=="lemma" and r["proof_status"]=="proved" and "li_specimen" not in r:
        print("specimen",rel,file=sys.stderr); errs+=1
    if "li_specimen" in r and not (root/r["li_specimen"]).is_file():
        print("no file",r["li_specimen"],file=sys.stderr); errs+=1
    if "evidence" not in ep.read_text() and "lean_thm" not in r:
        print("evidence",rel,file=sys.stderr); errs+=1
if errs: sys.exit(1)
print(f"check-proof-db: ok ({len(ids)} entries)")
PY
