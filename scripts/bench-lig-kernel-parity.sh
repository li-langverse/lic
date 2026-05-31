#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"

LIC="${LIC:-$ROOT/build/compiler/lic/lic}"
if [[ ! -x "$LIC" && -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
if [[ ! -x "$LIC" && -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
fi
if [[ -x "$LIC" ]]; then
  LIC="$(cd "$(dirname "$LIC")" && pwd)/$(basename "$LIC")"
fi
OUT="$BENCHMARKS_RESULTS/lig-lkir-matmul.json"
REG="$BENCHMARKS_COMPETITIVE/lig-kernels.toml"
SMOKE="$ROOT/packages/lig/li-tests/smoke/kernel_matmul_parity.li"
PILOT_ID="${LIG_BENCH_PILOT_KERNEL_ID:-lig.kernel.matmul_f32}"
mkdir -p "$BENCHMARKS_RESULTS"
export LIG_BENCH_ROOT="$ROOT" LIG_BENCH_LIC="$LIC" LIG_BENCH_OUT="$OUT" LIG_BENCH_REG="$REG" LIG_BENCH_SMOKE="$SMOKE" LIG_BENCH_PILOT_ID="$PILOT_ID"
python3 <<'PY'
import json, os, re, shutil, subprocess, tempfile, time
from pathlib import Path

root = Path(os.environ["LIG_BENCH_ROOT"])
lic = Path(os.environ["LIG_BENCH_LIC"])
smoke = Path(os.environ["LIG_BENCH_SMOKE"])
out = Path(os.environ["LIG_BENCH_OUT"])
reg = Path(os.environ["LIG_BENCH_REG"])
pilot_id = os.environ["LIG_BENCH_PILOT_ID"]

def parse_kernel_ids(text: str) -> list[str]:
    return re.findall(r'^id = "(lig\.kernel\.[^"]+)"', text, re.MULTILINE)

def bench_env() -> dict[str, str]:
    env = os.environ.copy()
    if "CC" not in env:
        for cc in ("clang", "clang-22", "gcc"):
            if shutil.which(cc):
                env["CC"] = cc
                cxx = cc.replace("clang", "clang++").replace("gcc", "g++")
                if shutil.which(cxx):
                    env["CXX"] = cxx
                break
    return env

kernel_ids: list[str] = []
if reg.is_file():
    kernel_ids = parse_kernel_ids(reg.read_text())

pilot = {
    "kernel_id": pilot_id,
    "validity_min": 0.999,
    "validity_ratio": 0.0,
    "validity_gate_pass": False,
    "compile_ok": False,
    "executed": False,
    "status": "pilot",
}
smoke_cwd = root
smoke_rel = str(smoke.relative_to(root)) if smoke.is_file() else ""

if lic.is_file() and smoke.is_file():
    with tempfile.TemporaryDirectory(prefix="lig-bench-") as tmp:
        bin_path = Path(tmp) / "kernel_matmul_parity"
        t0 = time.perf_counter()
        build = subprocess.run(
            [str(lic), "build", "--allow-open-vc", smoke_rel, "-o", str(bin_path)],
            cwd=smoke_cwd,
            capture_output=True,
            text=True,
            env=bench_env(),
        )
        pilot["compile_ok"] = build.returncode == 0
        if not pilot["compile_ok"]:
            pilot["stderr_tail"] = (build.stderr or "")[-500:]
        elif bin_path.is_file():
            run_t0 = time.perf_counter()
            run = subprocess.run([str(bin_path)], capture_output=True, text=True)
            pilot["cpu_sec"] = round(time.perf_counter() - run_t0, 6)
            pilot["executed"] = True
            pilot["run_exit_code"] = run.returncode
            pilot["validity_gate_pass"] = run.returncode == 0
            pilot["validity_ratio"] = 1.0 if run.returncode == 0 else 0.0
            if run.returncode != 0:
                pilot["stderr_tail"] = (run.stderr or "")[-500:]
        pilot["build_cpu_sec"] = round(time.perf_counter() - t0, 6)

kernels = []
for kid in kernel_ids:
    if kid == pilot_id:
        kernels.append(pilot)
    else:
        kernels.append({"kernel_id": kid, "status": "stub", "compile_ok": False, "executed": False})

report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "registry": str(reg.relative_to(root)) if reg.is_file() else None,
    "kernel_ids": kernel_ids,
    "kernels": kernels,
    "kernel_id": pilot_id,
    "validity_min": pilot["validity_min"],
    "validity_ratio": pilot["validity_ratio"],
    "validity_gate_pass": pilot["validity_gate_pass"],
    "compile_ok": pilot["compile_ok"],
    "executed": pilot.get("executed", False),
}
if "cpu_sec" in pilot:
    report["cpu_sec"] = pilot["cpu_sec"]
if "build_cpu_sec" in pilot:
    report["build_cpu_sec"] = pilot["build_cpu_sec"]

out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
print("kernel_ids:", " ".join(kernel_ids))
PY
echo "bench-lig-kernel-parity: done"
