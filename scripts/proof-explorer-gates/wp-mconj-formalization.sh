#!/usr/bin/env bash
# WP-EF-04 — ≥3 M-CONJ with non-trivial specimens.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import re
from pathlib import Path

spec_dir = Path("proof-db/math/specimens")
if not spec_dir.is_dir():
    raise SystemExit("wp-mconj-formalization: missing proof-db/math/specimens")

def is_nontrivial(text: str) -> bool:
    stripped = re.sub(r"#.*", "", text)
    stripped = re.sub(r"/\*.*?\*/", "", stripped, flags=re.S)
    if len(stripped.strip()) < 80:
        return False
    if re.search(r"\bTODO\b", text, re.I):
        return False
    # Require some formal structure
    return bool(re.search(r"\b(proc|theorem|lemma|ensures|requires|forall|exists)\b", stripped, re.I))

count = 0
ids = []
for path in sorted(spec_dir.glob("M-CONJ-*.li")):
    if is_nontrivial(path.read_text(encoding="utf-8", errors="replace")):
        count += 1
        ids.append(path.stem)

if count < 3:
    raise SystemExit(f"wp-mconj-formalization: only {count} non-trivial M-CONJ specimens (want >=3): {ids}")
print(f"wp-mconj-formalization: OK ({count} non-trivial: {', '.join(ids[:5])}{'...' if count > 5 else ''})")
PY
