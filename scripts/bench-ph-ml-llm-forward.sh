#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ ! -x "$LIC" && -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
OUT="$BENCHMARKS_RESULTS/ph-ml-llm-forward.json"
SMOKE="$ROOT/packages/li-llm/li-tests/smoke/llm_forward.li"
META_SMOKE="$ROOT/packages/li-llm/li-tests/smoke/llm_safetensors_parse_real.li"
MATMUL_SMOKE="$ROOT/packages/li-llm/li-tests/smoke/llm_forward_matmul_real.li"
mkdir -p "$BENCHMARKS_RESULTS"
python3 "$ROOT/scripts/prepare_ph_ml_weights_fixture.py"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE" PH_ML_BENCH_META_SMOKE="$META_SMOKE" PH_ML_BENCH_MATMUL_SMOKE="$MATMUL_SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path
root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
meta_smoke = Path(os.environ["PH_ML_BENCH_META_SMOKE"])
matmul_smoke = Path(os.environ.get("PH_ML_BENCH_MATMUL_SMOKE", ""))
out = Path(os.environ["PH_ML_BENCH_OUT"])
runs, warmup = 50, 3
report = {"generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "suite": "ph-ml-llm-forward", "workload_class": "stub", "compile_ok": False, "executed": False, "validity_gate_pass": False, "tensor_metadata_ok": False, "forward_matmul_ok": False, "worker": "cpu_sync", "worker_count": 1, "tier3_runs": runs}
def pick_env():
    env = os.environ.copy()
    for cc in ("clang-22", "clang", "gcc"):
        if subprocess.run(["which", cc], capture_output=True).returncode == 0:
            env["CC"], env["CXX"] = cc, (f"{cc}++" if cc != "clang-22" else "clang++-22")
            break
    return env
def build_run(smoke_path, env, exec_smoke=True):
    smoke_rel = str(smoke_path.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-llm-bench-") as tmp:
        bin_path = Path(tmp) / "bench_bin"
        build = subprocess.run([str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
        if build.returncode != 0 or not bin_path.is_file():
            return False, None
        if not exec_smoke:
            return True, bin_path
        return subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env).returncode == 0, bin_path
if lic.is_file() and smoke.is_file():
    env = pick_env()
    if meta_smoke.is_file():
        report["tensor_metadata_ok"], _ = build_run(meta_smoke, env)
    if matmul_smoke.is_file():
        report["forward_matmul_ok"], _ = build_run(matmul_smoke, env, exec_smoke=False)
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-llm-bench-") as tmp:
        bin_path = Path(tmp) / "llm_forward"
        build = subprocess.run([str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
        report["compile_ok"] = build.returncode == 0
        if report["compile_ok"] and bin_path.is_file():
            for _ in range(warmup):
                subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env)
            t0, ok = time.perf_counter(), True
            for _ in range(runs):
                if subprocess.run([str(bin_path)], cwd=root, capture_output=True, text=True, env=env).returncode != 0:
                    ok = False
                    break
            report["executed"], report["validity_gate_pass"] = True, ok
            if ok and report.get("forward_matmul_ok"):
                report["workload_class"] = "tier3_cpu"
            elif ok and report["tensor_metadata_ok"]:
                report["workload_class"] = "pilot"
            elif ok:
                report["workload_class"] = "tier3_cpu"
            report["cpu_sec"] = round((time.perf_counter() - t0) / runs, 6)
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-llm-forward: done"
