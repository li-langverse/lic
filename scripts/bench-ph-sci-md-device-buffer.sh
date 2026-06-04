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
OUT="$ROOT/benchmarks/results/ph-sci-md-device-buffer.json"
SMOKE="$ROOT/packages/li-sim-scientific/li-tests/smoke/scientific_gpu_md_device_buffer.li"
mkdir -p "$BENCHMARKS_RESULTS"
export LIG_EMIT_CUDA="${LIG_EMIT_CUDA:-1}"
bash "$ROOT/scripts/lig-emit-vendor-stub.sh" >/dev/null
export PH_SCI_BENCH_ROOT="$ROOT" PH_SCI_BENCH_LIC="$LIC" PH_SCI_BENCH_OUT="$OUT" PH_SCI_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["PH_SCI_BENCH_ROOT"])
lic = Path(os.environ["PH_SCI_BENCH_LIC"])
smoke = Path(os.environ["PH_SCI_BENCH_SMOKE"])
out = Path(os.environ["PH_SCI_BENCH_OUT"])

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-sci-md-device-buffer",
    "kernel_id": "lig.kernel.md_force_short",
    "parity_tolerance": 0.001,
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "compile_ok": False,
    "parity_gate_pass": False,
    "executed": False,
    "lig_emit_cuda": os.environ.get("LIG_EMIT_CUDA") == "1",
}

if lic.is_file() and smoke.is_file():
    smoke_rel = str(smoke.relative_to(root))
    with tempfile.TemporaryDirectory(prefix="ph-sci-md-buf-") as tmp:
        bin_path = Path(tmp) / "scientific_gpu_md_device_buffer"
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
            report["parity_gate_pass"] = run.returncode == 0
            if run.returncode != 0:
                report["stderr_tail"] = (run.stderr or "")[-500:]

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-sci-md-device-buffer: done"
