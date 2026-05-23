#!/usr/bin/env bash
# AL-6 gate: cinematic algorithm RFC + fundamentals link PH-CIN, encode/color/audio vertical rows.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"

CIN_DOC="$ROOT/docs/ecosystem/cinematic-algorithm-fundamentals.md"
CIN_RFC="$ROOT/docs/game-dev/specs/li-cinematic-rfc.md"
PH_TRACKER="$ROOT/docs/game-dev/PH-world-studio-program.md"
VISION="$ROOT/docs/game-dev/world-studio-vision.md"
PUB_RFC="$ROOT/docs/game-dev/specs/publication-export-rfc.md"
VERTICALS="$ROOT/benchmarks/competitive/verticals.toml"
CATALOG="$ROOT/docs/ecosystem/vertical-algorithm-catalog.md"
SEQ_README="$ROOT/packages/li-seq/README.md"
STUDIO_LIB="$ROOT/packages/li-studio/src/lib.li"
COMPOSABLE="$ROOT/li-tests/composable/import_studio_cinematic_algorithms.li"

li_phase "cinematic algorithm RFC (AL-6)"
for f in "$CIN_DOC" "$CIN_RFC" "$PH_TRACKER" "$VISION" "$PUB_RFC" "$VERTICALS" "$CATALOG" "$SEQ_README" "$STUDIO_LIB" "$COMPOSABLE"; do
  [[ -f "$f" ]] || { li_fail "missing $f"; exit 1; }
done

export CIN_DOC CIN_RFC PH_TRACKER VISION PUB_RFC VERTICALS CATALOG SEQ_README STUDIO_LIB COMPOSABLE
python3 - <<'PY'
from __future__ import annotations

import os
import sys
from pathlib import Path

try:
    import tomllib
except ImportError:
    import tomli as tomllib  # type: ignore

cin = Path(os.environ["CIN_DOC"]).read_text()
rfc = Path(os.environ["CIN_RFC"]).read_text()
ph = Path(os.environ["PH_TRACKER"]).read_text()
vision = Path(os.environ["VISION"]).read_text()
pub = Path(os.environ["PUB_RFC"]).read_text()
verticals = tomllib.loads(Path(os.environ["VERTICALS"]).read_text())
catalog = Path(os.environ["CATALOG"]).read_text()
seq_readme = Path(os.environ["SEQ_README"]).read_text()
studio = Path(os.environ["STUDIO_LIB"]).read_text()

errors: list[str] = []

cin_required = (
    "PH-CIN",
    "workload_class=stub",
    "cinematic_encode",
    "cinematic_color_grade",
    "cinematic_audio_sync",
    "ffmpeg",
    "Rec.709",
    "ACES",
    "CIN-0",
    "CIN-1",
    "import seq",
    "import anim",
    "publish_encode_preset_h264",
    "publish_color_linear_to_rec709",
    "publish_audio_sample_index_for_frame",
    "import_studio_cinematic_algorithms.li",
)
for token in cin_required:
    if token not in cin:
        errors.append(f"cinematic-algorithm-fundamentals.md must mention {token!r}")

rfc_required = (
    "PH-CIN",
    "cinematic_encode",
    "cinematic_color_grade",
    "cinematic_audio_sync",
    "workload_class=stub",
    "publication-export-rfc",
    "ffmpeg",
)
for token in rfc_required:
    if token not in rfc:
        errors.append(f"li-cinematic-rfc.md must mention {token!r}")

if "PH-CIN" not in ph:
    errors.append("PH-world-studio-program.md must list PH-CIN")
if "CIN-0" not in ph:
    errors.append("PH-world-studio-program.md must list CIN-0 phase")

if "PH-CIN" not in vision:
    errors.append("world-studio-vision.md must mention PH-CIN")
if "li-cinematic-rfc" not in vision:
    errors.append("world-studio-vision.md RFC index must link li-cinematic-rfc.md")

if "li-cinematic-rfc" not in pub:
    errors.append("publication-export-rfc.md must reference li-cinematic-rfc.md for video encode")

if "cinematic-algorithm-fundamentals" not in seq_readme:
    errors.append("packages/li-seq/README.md must link cinematic-algorithm-fundamentals.md")

for fn in (
    "publish_encode_preset_h264",
    "publish_color_linear_to_rec709",
    "publish_audio_sample_index_for_frame",
    "publish_cinematic_smoke_entry",
):
    if fn not in studio:
        errors.append(f"packages/li-studio/src/lib.li must define {fn}")

ids = [str(row["id"]) for row in verticals.get("vertical", []) if isinstance(row, dict)]
for vid in ("cinematic_encode", "cinematic_color_grade", "cinematic_audio_sync"):
    if vid not in ids:
        errors.append(f"verticals.toml missing [[vertical]] id={vid!r}")
    if f"## {vid}" not in catalog:
        errors.append(f"vertical-algorithm-catalog.md missing ## {vid}")

if errors:
    for e in errors:
        print(e, file=sys.stderr)
    sys.exit(1)

print("cinematic-rfc: ok")
PY

li_ok "cinematic algorithm RFC"
