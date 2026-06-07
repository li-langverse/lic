#!/usr/bin/env bash
# WP-T10-08: ErdÅ‘s honest open/proved â€” no catalog proved when register is open/target.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json
import re
from pathlib import Path

root = Path(".")
erdos_toml = root / "docs/verification/proof-database/entries/erdos-register.toml"
text = erdos_toml.read_text(encoding="utf-8")
fake_proved = []
for block in re.split(r"\[\[entry\]\]", text)[1:]:
    id_m = re.search(r'id\s*=\s*"([^"]+)"', block)
    status_m = re.search(r'proof_status\s*=\s*"([^"]+)"', block)
    if not id_m or not status_m:
        continue
    eid, status = id_m.group(1), status_m.group(1)
    if status == "proved" and eid.startswith("E-"):
        fake_proved.append(eid)

open_json = root / "proof-db/erdos/open-conjectures.json"
if open_json.is_file():
    oc = json.loads(open_json.read_text(encoding="utf-8"))
    open_ids = {r.get("id") for r in oc.get("rows") or [] if r.get("id")}
    overlap = [e for e in fake_proved if e in open_ids]
    if overlap:
        print(f"wp-t10-08: fake proved vs open register: {', '.join(overlap[:8])}", file=sys.stderr)
        raise SystemExit(1)

print("wp-t10-08: catalog erdos honesty pre-check OK")
PY

bash scripts/proof-explorer-gates/wp-pl-05-erdos-formal.sh
bash scripts/proof-explorer-gates/wp-catalog-honesty.sh
echo "wp-t10-08-erdos-honesty: OK"
