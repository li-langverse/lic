#!/usr/bin/env bash
# Li native sim_scientific_oracle_checksum_md timing (build + bench smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_MD_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

LIC="${LIC:-}"
if [[ "$(uname -s)" == "Linux" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
else
  LIC="$("$ROOT/scripts/resolve-lic.sh" 2>/dev/null || true)"
fi

OUT="$BENCHMARKS_RESULTS/ph-sci-md-oracle-li.json"
SMOKE_REL="packages/li-sim-scientific/li-tests/smoke/scientific_oracle_bench.li"
BIN="/tmp/scientific_oracle_bench"
if [[ "$(uname -s)" == "Linux" && ! "$(cd "$ROOT" && pwd)" == /mnt/* ]]; then
  BIN="$ROOT/benchmarks/results/.md_oracle_bench_bin/scientific_oracle_bench"
  mkdir -p "$(dirname "$BIN")"
fi

for cc in clang-22 clang gcc; do
  if command -v "$cc" >/dev/null 2>&1; then
    export CC="$cc"
    export CXX="${cc/clang/clang++}"
    [[ "$cc" == "clang-22" ]] && export CXX="clang++-22"
    break
  fi
done

COMPILE_OK=0
RUN_RC=1
EXECUTED=0
CPU_SEC=""
STDERR_TAIL=""
T0=$(date +%s.%N)

if [[ -n "$LIC" && -x "$LIC" && -f "$ROOT/$SMOKE_REL" ]]; then
  if "$LIC" build --allow-open-vc "$ROOT/$SMOKE_REL" -o "$BIN" 2>"$BENCHMARKS_RESULTS/.md_oracle_build.err"; then
    COMPILE_OK=1
  else
    STDERR_TAIL=$(tail -c 500 "$BENCHMARKS_RESULTS/.md_oracle_build.err" 2>/dev/null || true)
  fi
  if [[ "$COMPILE_OK" == "1" ]]; then
    if (cd "$ROOT" && "$BIN" >/dev/null 2>"$BENCHMARKS_RESULTS/.md_oracle_run.err"); then
      RUN_RC=0
      EXECUTED=1
    else
      STDERR_TAIL=$(tail -c 500 "$BENCHMARKS_RESULTS/.md_oracle_run.err" 2>/dev/null || true)
    fi
  fi
fi
T1=$(date +%s.%N)
if [[ "$EXECUTED" == "1" ]]; then
  CPU_SEC=$(python3 -c "print(round(float('$T1') - float('$T0'), 6))")
fi

export PH_SCI_MD_LI_OUT="$OUT" PH_SCI_MD_LI_ROOT="$ROOT"
export PH_SCI_MD_LI_EXECUTED="$EXECUTED" PH_SCI_MD_LI_CPU_SEC="${CPU_SEC:-}"
export PH_SCI_MD_LI_COMPILE_OK="$COMPILE_OK" PH_SCI_MD_LI_RUN_RC="$RUN_RC"
export PH_SCI_MD_LI_STDERR_TAIL="$STDERR_TAIL"
python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_MD_LI_ROOT"])
sys.path.insert(0, str(root / "benchmarks" / "competitive"))
from md_oracle_competitive_common import DRIFT_TOLERANCE, KERNEL, WORKLOAD, li_oracle_checksum_md

out = Path(os.environ["PH_SCI_MD_LI_OUT"])
executed = os.environ.get("PH_SCI_MD_LI_EXECUTED") == "1"
cpu_sec = os.environ.get("PH_SCI_MD_LI_CPU_SEC") or None
if cpu_sec:
    cpu_sec = float(cpu_sec)
drift = li_oracle_checksum_md()
doc = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-sci-md-oracle-li",
    "workload": WORKLOAD,
    "kernel": KERNEL,
    "executed": executed,
    "compile_ok": os.environ.get("PH_SCI_MD_LI_COMPILE_OK") == "1",
    "run_rc": int(os.environ.get("PH_SCI_MD_LI_RUN_RC", "1")),
    "cpu_sec": cpu_sec,
    "energy_drift_checksum": round(drift, 12),
    "energy_drift_source": "li_native" if executed else "li_python_mirror",
    "validity_gate_pass": 0.0 < drift < DRIFT_TOLERANCE,
    "validity_ratio": 1.0 if 0.0 < drift < DRIFT_TOLERANCE else 0.0,
    "stderr_tail": os.environ.get("PH_SCI_MD_LI_STDERR_TAIL") or None,
    "registry_gate": "scripts/ph-sci-md-oracle-competitive-gates.sh",
}
out.write_text(json.dumps(doc, indent=2) + "\n", encoding="utf-8")
print(out)
PY
echo "bench-ph-sci-md-oracle-li: done"
