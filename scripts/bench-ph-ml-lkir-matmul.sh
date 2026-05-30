#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
OUT="$ROOT/benchmarks/results/ph-ml-lkir-matmul.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li"
mkdir -p "$ROOT/benchmarks/results"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-lkir-matmul",
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "compile_ok": False,
    "validity_gate_pass": False,
    "validity_ratio": 0.0,
    "executed": False,
    "cpu_sec": None,
}

if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-bench-") as tmp:
        bin_path = Path(tmp) / "ml_matmul_lkir_parity"
        t0 = time.perf_counter()
        env = os.environ.copy()
        for cc in ("clang-22", "clang", "gcc"):
            if subprocess.run(["which", cc], capture_output=True).returncode == 0:
                env["CC"] = cc
                env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
                break
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)],
            cwd=root,
            capture_output=True,
            text=True,
            env=env,
        )
        report["compile_ok"] = build.returncode == 0
        if not report["compile_ok"]:
            report["stderr_tail"] = (build.stderr or "")[-500:]
        elif bin_path.is_file():
            run_t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True, env=env)
            report["cpu_sec"] = round(time.perf_counter() - run_t0, 6)
            report["executed"] = True
            report["run_exit_code"] = run.returncode
            report["validity_gate_pass"] = run.returncode == 0
            report["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0
            if run.returncode != 0:
                report["stderr_tail"] = (run.stderr or "")[-500:]
        report["build_cpu_sec"] = round(time.perf_counter() - t0, 6)

kernels = [
    {
        "kernel_id": "ml.lkir.matmul_f32",
        "status": "pilot",
        "compile_ok": report["compile_ok"],
        "executed": report["executed"],
        "validity_gate_pass": report["validity_gate_pass"],
        "validity_ratio": report["validity_ratio"],
    }
]
report["kernels"] = kernels

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-lkir-matmul: done"
