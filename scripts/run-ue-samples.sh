#!/usr/bin/env bash
# Run UE5 baseline samples → ue-baselines.csv → import_ue_baseline.py
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PROJECT="${UE_SAMPLE_PROJECT:-$ROOT/samples/ue5-li-baseline/LiWorldBenchmark/LiWorldBenchmark.uproject}"
MASS_TEST="${UE5MASSTEST_ROOT:-$ROOT/../UE5MassTest/MassTest/MassTest.uproject}"
if [[ -f "$MASS_TEST" ]]; then
  PROJECT="$MASS_TEST"
  echo "Using UE5MassTest project: $PROJECT"
fi
OUT_CSV="$ROOT/benchmarks/competitive/ue-baselines.csv"
UE_ROOT="${UE_ROOT:-}"

find_ue_cmd() {
  if [[ -n "$UE_ROOT" ]]; then
    for cand in \
      "$UE_ROOT/Engine/Binaries/Linux/UnrealEditor-Cmd" \
      "$UE_ROOT/Engine/Binaries/Linux/UnrealEditor" \
      "$UE_ROOT/Engine/Binaries/Mac/UnrealEditor-Cmd" \
      "$UE_ROOT/Engine/Binaries/Win64/UnrealEditor-Cmd.exe"; do
      if [[ -x "$cand" ]]; then
        echo "$cand"
        return 0
      fi
    done
  fi
  command -v UnrealEditor-Cmd 2>/dev/null || command -v UnrealEditor 2>/dev/null || return 1
}

echo "== UE5 baseline capture =="
if ! UE_CMD="$(find_ue_cmd)"; then
  cat <<'EOF' >&2
ERROR: Unreal Editor not found.
  export UE_ROOT=/path/to/UE_5.4   # contains Engine/Binaries/...
  Or install UE 5.4+ and add UnrealEditor-Cmd to PATH.

See samples/ue5-li-baseline/README.md
Cloud CI cannot run UE without a self-hosted runner (.github/workflows/ue-baseline.yml).
EOF
  exit 2
fi

echo "Using: $UE_CMD"
LOG="$ROOT/benchmarks/results/ue_sample.log"
mkdir -p "$(dirname "$LOG")"

# Game mode benchmark map (DefaultMap must exist in project; use empty open world).
"$UE_CMD" "$PROJECT" \
  -unattended -nopause -nosplash -nullrhi \
  -ExecCmds="stat unit,stat startfile,stat stopfile" \
  -log="$LOG" 2>&1 | tail -20 || true

SAVED_CSV="$ROOT/samples/ue5-li-baseline/LiWorldBenchmark/Saved/LiBenchmark.csv"
if [[ -f "$SAVED_CSV" ]]; then
  cp -f "$SAVED_CSV" "$OUT_CSV"
  echo "wrote $OUT_CSV from UE Saved/"
else
  # Parse stat unit from log if present
  python3 <<PY
import re
from pathlib import Path
log = Path("$LOG")
out = Path("$OUT_CSV")
rows = ["benchmark,subsystem,wall_time_ms,source,ue_version,notes"]
if log.is_file():
    text = log.read_text(errors="replace")
    m = re.search(r"Frame Time.*?([0-9.]+)\\s*ms", text, re.I | re.S)
    if m:
        rows.append(f"game_world_soa_10k,stat unit frame,{m.group(1)},ue5_log_parse,5.4,from $LOG")
if len(rows) < 2:
    raise SystemExit("No UE timing captured — run editor sample locally or check log")
out.write_text("\\n".join(rows) + "\\n")
print(f"wrote {out}")
PY
fi

python3 "$ROOT/benchmarks/harness/import_ue_baseline.py" --csv "$OUT_CSV"
echo ""
echo "Next steps:"
echo "  1. Add rows for game_replication_encode, sim_physics_frame, render_frame_present if missing"
echo "  2. ./scripts/run-world-benches.sh && ./scripts/publish-benchmarks-ingest.sh"
echo "  3. See docs/game-dev/UE-BENCHMARK-RUNBOOK.md"
echo "done: $OUT_CSV + ue-baselines-merged.json"
