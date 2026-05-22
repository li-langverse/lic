#!/usr/bin/env bash
# Schema catalog golden — setup-censor migration parser (Python).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONPATH="$ROOT/scripts${PYTHONPATH:+:$PYTHONPATH}"

mig="$ROOT/li-tests/schema_catalog/migrations"
golden="$ROOT/li-tests/schema_catalog/golden_paths.txt"
tmp="$(mktemp)"
gen_dir="$(mktemp -d)"

python3 "$ROOT/scripts/setup-censor-httpd.py" --migrations "$mig" -o "$gen_dir"
python3 - <<PY
from pathlib import Path
import tomllib
from schema_catalog import merge_catalog, parse_migrations_dir

mig = Path("$mig")
cat = merge_catalog(parse_migrations_dir(mig))
got = sorted(cat.json_paths)
exp = sorted(ln.strip() for ln in Path("$golden").read_text().splitlines() if ln.strip())
if got != exp:
    raise SystemExit(f"paths mismatch:\n  got={got}\n  exp={exp}")
gen = tomllib.loads((Path("$gen_dir") / "leak_censor.generated.toml").read_text())
paths = gen["generated"]["json_paths"]["paths"]
if sorted(paths) != sorted(exp):
    raise SystemExit("generated.toml paths mismatch")
print("schema_catalog: OK")
PY
rm -rf "$gen_dir" "$tmp"
