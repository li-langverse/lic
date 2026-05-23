#!/usr/bin/env bash
# AL-5 gate: engineering CAE RFC + fundamentals link PH-CAE, FEA/CFD vertical rows, PH-SCI split.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

CAE_DOC="$ROOT/docs/ecosystem/engineering-cae-fundamentals.md"
CAE_RFC="$ROOT/docs/game-dev/specs/li-sim-cae-rfc.md"
PH_TRACKER="$ROOT/docs/game-dev/PH-world-studio-program.md"
VISION="$ROOT/docs/game-dev/world-studio-vision.md"
SCI_RFC="$ROOT/docs/game-dev/specs/sim-viz-scientific-rfc.md"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"

li_phase "engineering CAE RFC (AL-5)"
for f in "$CAE_DOC" "$CAE_RFC" "$PH_TRACKER" "$VISION" "$SCI_RFC" "$VERTICALS" "$CATALOG"; do
  [[ -f "$f" ]] || { li_fail "missing $f"; exit 1; }
done

export CAE_DOC CAE_RFC PH_TRACKER VISION SCI_RFC VERTICALS CATALOG
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

cae = Path(os.environ["CAE_DOC"]).read_text()
rfc = Path(os.environ["CAE_RFC"]).read_text()
ph = Path(os.environ["PH_TRACKER"]).read_text()
vision = Path(os.environ["VISION"]).read_text()
sci = Path(os.environ["SCI_RFC"]).read_text()
verticals = tomllib.loads(Path(os.environ["VERTICALS"]).read_text())
catalog = Path(os.environ["CATALOG"]).read_text()

errors: list[str] = []

cae_required = (
    "PH-CAE",
    "workload_class=stub",
    "fea_linear_elasticity",
    "cfd_lid_driven_cavity",
    "FEA",
    "CFD",
    "PH-SCI",
    "CalculiX",
    "OpenFOAM",
    "COMSOL",
    "CAE-0",
    "CAE-1",
    "sim.scientific",
)
for token in cae_required:
    if token not in cae:
        errors.append(f"engineering-cae-fundamentals.md must mention {token!r}")

rfc_required = (
    "PH-CAE",
    "fea_linear_elasticity",
    "cfd_lid_driven_cavity",
    "workload_class=stub",
    "sim-viz-scientific-rfc",
)
for token in rfc_required:
    if token not in rfc:
        errors.append(f"li-sim-cae-rfc.md must mention {token!r}")

if "PH-CAE" not in ph:
    errors.append("PH-world-studio-program.md must list PH-CAE")
if "CAE-0" not in ph:
    errors.append("PH-world-studio-program.md must list CAE-0 phase")

if "PH-CAE" not in vision:
    errors.append("world-studio-vision.md must mention PH-CAE")
if "li-sim-cae-rfc" not in vision:
    errors.append("world-studio-vision.md RFC index must link li-sim-cae-rfc.md")

if "PH-CAE" not in sci:
    errors.append("sim-viz-scientific-rfc.md must reference PH-CAE split")

ids = [str(row["id"]) for row in verticals.get("vertical", []) if isinstance(row, dict)]
for vid in ("fea_linear_elasticity", "cfd_lid_driven_cavity"):
    if vid not in ids:
        errors.append(f"verticals.toml missing [[vertical]] id={vid!r}")
    if f"## {vid}" not in catalog:
        errors.append(f"vertical-algorithm-catalog.md missing ## {vid}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("engineering-cae-rfc: ok")
PY

li_ok "engineering CAE RFC"
