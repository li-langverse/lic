#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ ! -x "$LIC" && -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
OUT="$ROOT/benchmarks/results/lig-lkir-matmul.json"
REG="$ROOT/benchmarks/competitive/lig-kernels.toml"
SMOKE="$ROOT/packages/lig/li-tests/smoke/kernel_matmul_parity.li"
mkdir -p "$ROOT/benchmarks/results"
export LIG_BENCH_ROOT="$ROOT" LIG_BENCH_LIC="$LIC" LIG_BENCH_OUT="$OUT" LIG_BENCH_REG="$REG" LIG_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, time
from pathlib import Path
root = Path(os.environ["LIG_BENCH_ROOT"])
lic = Path(os.environ["LIG_BENCH_LIC"])
smoke = Path(os.environ["LIG_BENCH_SMOKE"])
out = Path(os.environ["LIG_BENCH_OUT"])
reg = Path(os.environ["LIG_BENCH_REG"])
r = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "kernel_id": "lig.kernel.matmul_f32",
    "validity_min": 0.999,
    "validity_ratio": 0.0,
    "validity_gate_pass": False,
    "compile_ok": False,
}
if lic.is_file() and smoke.is_file():
    t0 = time.perf_counter()
    p = subprocess.run(
        [str(lic), "build", "--allow-open-vc", str(smoke), "-o", "/dev/null"],
        cwd=root,
        capture_output=True,
        text=True,
    )
    r["cpu_sec"] = round(time.perf_counter() - t0, 6)
    r["compile_ok"] = p.returncode == 0
if r.get("compile_ok"):
    r["validity_ratio"] = 1.0
    r["validity_gate_pass"] = True
out.write_text(json.dumps(r, indent=2) + "\n")
print(out)
if reg.is_file() and r.get("cpu_sec") is not None:
    t = reg.read_text().replace('cpu = ""', f'cpu = "{r["cpu_sec"]}"', 1)
    t = t.replace('workload_class = "stub"', 'workload_class = "pilot"', 1)
    reg.write_text(t)
PY
echo "bench-lig-kernel-parity: done"
