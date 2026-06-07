#!/usr/bin/env bash
# Patch benchmarks harness tier-0 drivers until paths.py migration lands on benchmarks main.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

patch_file() {
  local rel="$1"
  local f="$BENCHMARKS_ROOT/$rel"
  [[ -f "$f" ]] || return 0
  python3 - "$f" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
if "from paths import lic_root" in text:
    sys.exit(0)
name = path.name
if name == "stability.py":
    old = '''from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
MD_DIR = REPO / "benchmarks" / "tier2_physics" / "md_lennard_jones"
BUILD_DIR = REPO / "build" / "bench" / "md_lennard_jones"
RESULTS = REPO / "benchmarks" / "results"
DEFAULT_OUT = RESULTS / "stability.csv"'''
    new = '''from pathlib import Path

from paths import lic_root, results_csv, tier_dirs

REPO = lic_root()
_, _, TIER2 = tier_dirs()
MD_DIR = TIER2 / "md_lennard_jones"
BUILD_DIR = REPO / "build" / "bench" / "md_lennard_jones"
RESULTS = results_csv().parent
DEFAULT_OUT = RESULTS / "stability.csv"'''
elif name == "verify.py":
    old = '''from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
LIC = REPO / "build" / "compiler" / "lic" / "lic"
RESULTS = REPO / "benchmarks" / "results"'''
    new = '''from pathlib import Path

from paths import lic_root, results_csv

_HARNESS = Path(__file__).resolve().parent
REPO = lic_root()
LIC = REPO / "build" / "compiler" / "lic" / "lic"
RESULTS = results_csv().parent'''
else:
    sys.exit(0)
if old not in text:
    sys.exit(0)
text = text.replace(old, new)
if name == "verify.py":
    text = text.replace(
        'sys.path.insert(0, str(REPO / "benchmarks" / "harness"))',
        "sys.path.insert(0, str(_HARNESS))",
    )
path.write_text(text, encoding="utf-8")
print(f"patched {path}")
PY
}

patch_file harness/stability.py
patch_file harness/verify.py
