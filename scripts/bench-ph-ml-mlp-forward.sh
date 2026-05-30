#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
OUT="$ROOT/benchmarks/results/ph-ml-mlp-forward.json"
SMOKE="$ROOT/packages/li-ml/li-tests/smoke/ml_mlp_forward.li"
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
    "suite": "ph-ml-mlp-forward",
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "compile_ok": False,
    "executed": False,
    "validity_gate_pass": False,
    "worker": "sync",
    "worker_count": 1,
    "parallelism_model": "cpu_sync_simd_vectorized",
}

if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-mlp-bench-") as tmp:
        bin_path = Path(tmp) / "ml_mlp_forward"
        env = os.environ.copy()
        for cc in ("clang-22", "clang", "gcc"):
            if subprocess.run(["which", cc], capture_output=True).returncode == 0:
                env["CC"] = cc
                env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
                break
        t0 = time.perf_counter()
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)],
            cwd=root, capture_output=True, text=True, env=env,
        )
        report["compile_ok"] = build.returncode == 0
        if report["compile_ok"] and bin_path.is_file():
            run = subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
            report["executed"] = True
            report["validity_gate_pass"] = run.returncode == 0
            report["run_exit_code"] = run.returncode
            report["cpu_sec"] = round(time.perf_counter() - t0, 6)
        elif not report["compile_ok"]:
            report["stderr_tail"] = (build.stderr or "")[-500:]

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-mlp-forward: done"