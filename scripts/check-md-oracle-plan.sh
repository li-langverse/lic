#!/usr/bin/env bash
# md-r3-oracle-plan gate: study doc + md_oracle.toml + li-tests manifest oracle paths.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STUDY="${MD_ORACLE_STUDY:-docs/numerics/studies/2026-06-06-md-r3-oracle-plan.md}"
REGISTRY="${MD_ORACLE_REGISTRY:-benchmarks/competitive/md_oracle.toml}"
PKG_MANIFEST="packages/li-sim-scientific/li-tests/manifest.toml"
MONO_MANIFEST="li-tests/manifest.toml"

fail() { echo "check-md-oracle-plan: $*" >&2; exit 1; }

[[ -f "$STUDY" ]] || fail "missing study doc: $STUDY"
[[ -f "$REGISTRY" ]] || fail "missing driver registry: $REGISTRY"
[[ -f "$PKG_MANIFEST" ]] || fail "missing package manifest: $PKG_MANIFEST"
[[ -f "$MONO_MANIFEST" ]] || fail "missing monorepo manifest: $MONO_MANIFEST"

grep -q 'sim_scientific_oracle_checksum_md' "$STUDY" \
  || fail "study must cite sim_scientific_oracle_checksum_md()"
grep -q 'check-md-oracle-plan' "$STUDY" \
  || fail "study must cite check-md-oracle-plan gate"

export STUDY REGISTRY PKG_MANIFEST MONO_MANIFEST ROOT
python3 <<'PY'
import os
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

root = Path(os.environ["ROOT"])
registry = tomllib.loads(Path(os.environ["REGISTRY"]).read_text())
pkg_text = Path(os.environ["PKG_MANIFEST"]).read_text()
mono_text = Path(os.environ["MONO_MANIFEST"]).read_text()

gate = (registry.get("harness") or {}).get("gate_script", "")
if gate != "scripts/check-md-oracle-plan.sh":
    print(f"md_oracle.toml harness.gate_script must be scripts/check-md-oracle-plan.sh (got {gate!r})")
    sys.exit(1)

study_doc = registry.get("meta", {}).get("study_doc", "")
if study_doc != os.environ["STUDY"]:
    print(f"registry study_doc mismatch: {study_doc!r}")
    sys.exit(1)

smokes = registry.get("li_tests_oracle_smoke") or []
if not smokes:
    print("md_oracle.toml: li_tests_oracle_smoke must be non-empty")
    sys.exit(1)

for row in smokes:
    path = row.get("path", "")
    if not path:
        print("li_tests_oracle_smoke row missing path")
        sys.exit(1)
    if not (root / path).is_file():
        print(f"missing oracle smoke file: {path}")
        sys.exit(1)
    pkg_rel = path.split("packages/li-sim-scientific/li-tests/", 1)[-1]
    if path not in pkg_text and pkg_rel not in pkg_text:
        print(f"package manifest must cite oracle smoke: {path} (or {pkg_rel})")
        sys.exit(1)
    if path not in mono_text:
        print(f"li-tests/manifest.toml must cite oracle smoke: {path}")
        sys.exit(1)

li_fn = (registry.get("harness") or {}).get("li_oracle_fn", "")
if li_fn != "sim_scientific_oracle_checksum_md":
    print(f"unexpected li_oracle_fn: {li_fn!r}")
    sys.exit(1)

lib = root / "packages/li-sim-scientific/src/lib.li"
if not lib.is_file() or li_fn not in lib.read_text():
    print(f"missing {li_fn} in {lib}")
    sys.exit(1)

catalog = registry.get("meta", {}).get("catalog_path", "")
if catalog and not (root / catalog).is_dir():
    print(f"warn: catalog path not scaffolded yet: {catalog}")

print("check-md-oracle-plan: OK")
print(f"  study={os.environ['STUDY']}")
print(f"  registry={os.environ['REGISTRY']}")
print(f"  oracle_smokes={len(smokes)}")
PY
