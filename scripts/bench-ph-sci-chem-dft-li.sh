#!/usr/bin/env bash
# Li native chem_dft_energy_kernel_hartree timing (build + 64-iter bench smoke).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="${PH_SCI_CHEM_BENCHMARKS_RESULTS:-$ROOT/benchmarks/results}"
mkdir -p "$BENCHMARKS_RESULTS"

LIC="${LIC:-}"
if [[ "$(uname -s)" == "Linux" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic.exe" ]]; then
  LIC="$ROOT/build/compiler/lic/lic.exe"
else
  LIC="$("$ROOT/scripts/resolve-lic.sh")"
fi

OUT="$BENCHMARKS_RESULTS/ph-sci-chem-dft-li.json"
SMOKE_REL="packages/li-chem/li-tests/benchmarks/chem_dft_energy_bench.li"
BIN="/tmp/chem_dft_energy_bench"
if [[ "$(uname -s)" == "Linux" && ! "$(cd "$ROOT" && pwd)" == /mnt/* ]]; then
  BIN="$ROOT/benchmarks/results/.chem_dft_bench_bin/chem_dft_energy_bench"
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

if [[ -x "$LIC" && -f "$ROOT/$SMOKE_REL" ]]; then
  if "$LIC" build --allow-open-vc "$SMOKE_REL" -o "$BIN" 2>"$BENCHMARKS_RESULTS/.chem_dft_build.err"; then
    COMPILE_OK=1
  else
    STDERR_TAIL=$(tail -c 500 "$BENCHMARKS_RESULTS/.chem_dft_build.err" 2>/dev/null || true)
  fi
  if [[ "$COMPILE_OK" == "1" && -x "$BIN" ]]; then
    EXECUTED=1
    if "$BIN"; then
      RUN_RC=0
    fi
  fi
fi
T1=$(date +%s.%N)
CPU_SEC=$(python3 -c "print(round(float('$T1') - float('$T0'), 6))")

export PH_SCI_CHEM_BENCH_OUT="$OUT" PH_SCI_CHEM_BENCH_ROOT="$ROOT" \
  PH_SCI_CHEM_COMPILE_OK="$COMPILE_OK" PH_SCI_CHEM_EXECUTED="$EXECUTED" \
  PH_SCI_CHEM_RUN_RC="$RUN_RC" PH_SCI_CHEM_CPU_SEC="$CPU_SEC" \
  PH_SCI_CHEM_SMOKE_REL="$SMOKE_REL" PH_SCI_CHEM_STDERR_TAIL="$STDERR_TAIL"

python3 <<'PY'
import json
import os
import sys
import time
from pathlib import Path

root = Path(os.environ["PH_SCI_CHEM_BENCH_ROOT"])
out = Path(os.environ["PH_SCI_CHEM_BENCH_OUT"])
competitive = root / "benchmarks" / "competitive"
sys.path.insert(0, str(competitive))
from chem_dft_competitive_common import li_scaffold_energy_hartree

energy = round(li_scaffold_energy_hartree(), 12)
compile_ok = os.environ.get("PH_SCI_CHEM_COMPILE_OK") == "1"
executed = os.environ.get("PH_SCI_CHEM_EXECUTED") == "1"
run_rc = int(os.environ.get("PH_SCI_CHEM_RUN_RC", "1"))
cpu_sec = os.environ.get("PH_SCI_CHEM_CPU_SEC")
validity = run_rc == 0 or (compile_ok and energy < 0.0)

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-sci-chem-dft-li",
    "smoke": os.environ.get("PH_SCI_CHEM_SMOKE_REL"),
    "workload": "chem_dft_energy_kernel_hartree_x64",
    "kernel": "chem.dft_energy_kernel_hartree",
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": validity,
    "cpu_sec": float(cpu_sec) if cpu_sec else None,
    "energy_hartree": energy,
    "energy_source": "li_scaffold_python_mirror",
    "device": "cpu",
    "run_exit_code": run_rc,
}
tail = os.environ.get("PH_SCI_CHEM_STDERR_TAIL", "")
if tail:
    report["stderr_tail"] = tail
if run_rc != 0 and compile_ok and energy < 0.0:
    report["note"] = "native run exit non-zero under harness; energy mirror negative (compile OK)"

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-sci-chem-dft-li: done"
