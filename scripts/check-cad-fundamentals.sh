#!/usr/bin/env bash
# AL-4 gate: cad-fundamentals.md exists and links PH-GEO + geometry package honesty.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

CAD_DOC="$ROOT/docs/ecosystem/cad-fundamentals.md"
PH_TRACKER="$ROOT/docs/game-dev/PH-world-studio-program.md"
VISION="$ROOT/docs/game-dev/world-studio-vision.md"
GEOMETRY_README="$ROOT/packages/li-geometry/README.md"

li_phase "cad fundamentals (AL-4)"
[[ -f "$CAD_DOC" ]] || { li_fail "missing $CAD_DOC"; exit 1; }
[[ -f "$PH_TRACKER" ]] || { li_fail "missing $PH_TRACKER"; exit 1; }
[[ -f "$VISION" ]] || { li_fail "missing $VISION"; exit 1; }
[[ -f "$GEOMETRY_README" ]] || { li_fail "missing $GEOMETRY_README"; exit 1; }

export CAD_DOC PH_TRACKER VISION GEOMETRY_README
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from pathlib import Path

cad = Path(os.environ["CAD_DOC"]).read_text()
ph = Path(os.environ["PH_TRACKER"]).read_text()
vision = Path(os.environ["VISION"]).read_text()
geom_readme = Path(os.environ["GEOMETRY_README"]).read_text()

errors: list[str] = []

cad_required = (
    "PH-GEO",
    "workload_class=stub",
    "import geometry",
    "mesh_orient2d",
    "packages/li-geometry",
    "import_geometry_mesh_predicates.li",
    "GEO-1",
    "OpenCascade",
    "CGAL",
    "Manifold",
)
for token in cad_required:
    if token not in cad:
        errors.append(f"cad-fundamentals.md must mention {token!r}")

if "PH-GEO" not in ph:
    errors.append("PH-world-studio-program.md must list PH-GEO")
if "GEO-0" not in ph:
    errors.append("PH-world-studio-program.md must list GEO-0 phase")

if "PH-GEO" not in vision:
    errors.append("world-studio-vision.md must mention PH-GEO")
if "`geometry`" not in vision and "| `geometry`" not in vision:
    errors.append("world-studio-vision.md module plan must list geometry import")

if "cad-fundamentals" not in geom_readme:
    errors.append("packages/li-geometry/README.md must link cad-fundamentals.md")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("cad-fundamentals: ok")
PY

li_ok "cad fundamentals"
