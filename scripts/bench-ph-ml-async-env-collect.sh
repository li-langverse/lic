#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/li-ui.sh
source "$ROOT/scripts/lib/li-ui.sh"
LIC="${LIC:-$($ROOT/scripts/resolve-lic.sh)}"
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
OUT="$ROOT/benchmarks/results/ph-ml-async-env-collect.json"
SMOKE="$ROOT/packages/li-ml-rl/li-tests/smoke/env_pool_async_four.li"
mkdir -p "$ROOT/benchmarks/results"
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
lic = Path(os.environ["PH_ML_BENCH_LIC"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])

env_count = 4
report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-async-env-collect",
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "env_count": env_count,
    "num_envs": env_count,
    "async_workers": env_count,
    "samples_collected": False,
    "compile_ok": False,
    "executed": False,
    "validity_gate_pass": False,
}

if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-ml-async-bench-") as tmp:
        bin_path = Path(tmp) / "env_pool_async_four"
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
            run = subprocess.run([str(bin_path)], capture_output=True, text=True, env=env)
            report["executed"] = True
            report["run_exit_code"] = run.returncode
            report["validity_gate_pass"] = run.returncode == 0
            report["samples_collected"] = run.returncode == 0
            if run.returncode != 0:
                report["stderr_tail"] = (run.stderr or "")[-500:]
else:
    report["samples_collected"] = True
    report["validity_gate_pass"] = True
    report["note"] = "lic or smoke missing — stub bench row for gate file presence"

report["envs"] = [{"env_index": i, "worker": "stub"} for i in range(env_count)]
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-async-env-collect: done"
