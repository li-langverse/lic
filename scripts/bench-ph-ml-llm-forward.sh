#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
OUT="$BENCHMARKS_RESULTS/ph-ml-llm-forward.json"
SMOKE="$ROOT/packages/li-llm/li-tests/smoke/llm_forward.li"
mkdir -p "$BENCHMARKS_RESULTS"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path
root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])
runs = 50
warmup = 3
report = {"generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "suite": "ph-ml-llm-forward", "workload_class": "stub", "compile_ok": False, "executed": False, "validity_gate_pass": False, "worker": "cpu_sync", "worker_count": 1, "tier3_runs": runs}
if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-llm-bench-") as tmp:
        bin_path = Path(tmp) / "llm_forward"
        env = os.environ.copy()
        for cc in ("clang-22", "clang", "gcc"):
            if subprocess.run(["which", cc], capture_output=True).returncode == 0:
                env["CC"] = cc
                env["CXX"] = f"{cc}++" if cc != "clang-22" else "clang++-22"
                break
        build = subprocess.run([str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
        report["compile_ok"] = build.returncode == 0
        if report["compile_ok"] and bin_path.is_file():
            for _ in range(warmup):
                subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
            t0 = time.perf_counter()
            ok = True
            for _ in range(runs):
                run = subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
                if run.returncode != 0:
                    ok = False
                    break
            report["executed"] = True
            report["validity_gate_pass"] = ok
            report["workload_class"] = "tier3_cpu" if ok else "stub"
            report["cpu_sec"] = round((time.perf_counter() - t0) / runs, 6)
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-llm-forward: done"
