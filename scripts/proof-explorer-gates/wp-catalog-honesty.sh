#!/usr/bin/env bash
# No catalog proof_status=proved while the mapped gap script still fails.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

fail=0
python3 - <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(".")
entries = root / "docs/verification/proof-database/entries"

# gap_script_basename -> substrings that must not appear as proved in catalog blocks
MAP = {
    "vec3_dot_opaque_ensures_gap.sh": ["linalg_vec3_dot", "vec3_dot"],
    "vec3_len_callproc_ensures_gap.sh": ["vec3_len", "linalg_vec3_len"],
    "mat2_at2_mir_codegen_lean_gap.sh": ["mat2_at2", "linalg_mat2_at2"],
    "matmul_loop_codegen_witness_gap.sh": ["matmul", "ArrayMatMul"],
    "parallel_disjoint_lean_opaque_gap.sh": ["parallel_disjoint", "disjoint_row"],
    "dot4_loop_ensures_lean_stub_gap.sh": ["linalg_dot4_int_loop"],
}

def gap_open(script: str) -> bool:
    path = root / "li-tests/tooling" / script
    if not path.is_file():
        return False
    r = subprocess.run(["bash", str(path)], cwd=root, capture_output=True)
    return r.returncode != 0

def proved_hits(needle: str) -> list[str]:
    hits = []
    for path in entries.glob("*.toml"):
        text = path.read_text(encoding="utf-8")
        for block in re.split(r"\[\[entry\]\]", text)[1:]:
            if needle not in block:
                continue
            if re.search(r'proof_status\s*=\s*"proved"', block):
                m = re.search(r'id\s*=\s*"([^"]+)"', block)
                hits.append(m.group(1) if m else path.name)
    return hits

violations = []
for script, needles in MAP.items():
    if not gap_open(script):
        continue
    for needle in needles:
        for entry_id in proved_hits(needle):
            violations.append((script, needle, entry_id))

if violations:
    for script, needle, entry_id in violations:
        print(
            f"wp-catalog-honesty: {entry_id} is proved but {script} still open (matched {needle})",
            file=sys.stderr,
        )
    sys.exit(1)
print("wp-catalog-honesty: OK (no proved rows contradict open gap scripts)")
PY

