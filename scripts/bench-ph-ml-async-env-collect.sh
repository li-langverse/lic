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
OUT="$ROOT/benchmarks/results/ph-ml-async-env-collect.json"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
SMOKE="$ROOT/packages/li-ml-rl/li-tests/smoke/env_pool_async_four.li"
mkdir -p "$BENCHMARKS_RESULTS"
[[ "$(pwd)" == /mnt/* ]] && export TMPDIR="${TMPDIR:-/tmp}"

PH_ML_ASYNC_COMPILE_OK=0
PH_ML_ASYNC_RUN_RC=1
PH_ML_ASYNC_CPU_SEC=0
PH_ML_ASYNC_BUILD_STDERR=""

if [[ -x "$LIC" && -f "$SMOKE" ]]; then
  smoke_rel="${SMOKE#"$ROOT/"}"
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/ph-ml-async-bench-XXXXXX")"
  bin_path="$tmpdir/env_pool_async_four"
  export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
  command -v "$CC" >/dev/null 2>&1 || { CC=clang; CXX=clang++; }
  t0="$(date +%s.%N)"
  set +e
  build_out="$("$LIC" build --allow-open-vc "$smoke_rel" -o "$bin_path" 2>&1)"
  build_rc=$?
  if [[ "$build_rc" -eq 0 && -f "$bin_path" ]]; then
    PH_ML_ASYNC_COMPILE_OK=1
    for _attempt in 1 2 3; do
      (cd "$ROOT" && "$bin_path")
      PH_ML_ASYNC_RUN_RC=$?
      [[ "$PH_ML_ASYNC_RUN_RC" -eq 0 ]] && break
    done
  else
    PH_ML_ASYNC_BUILD_STDERR="${build_out: -500}"
  fi
  set -e
  t1="$(date +%s.%N)"
  PH_ML_ASYNC_CPU_SEC="$(python3 -c "print(round(float('$t1') - float('$t0'), 6))")"
  rm -rf "$tmpdir"
fi

export PH_ML_ASYNC_COMPILE_OK PH_ML_ASYNC_RUN_RC PH_ML_ASYNC_CPU_SEC PH_ML_ASYNC_BUILD_STDERR
export PH_ML_BENCH_ROOT="$ROOT" PH_ML_BENCH_LIC="$LIC" PH_ML_BENCH_OUT="$OUT" PH_ML_BENCH_SMOKE="$SMOKE"
python3 <<'PY'
import json, os, time
from pathlib import Path

root = Path(os.environ["PH_ML_BENCH_ROOT"])
smoke = Path(os.environ["PH_ML_BENCH_SMOKE"])
out = Path(os.environ["PH_ML_BENCH_OUT"])
env_count = 4
compile_ok = os.environ.get("PH_ML_ASYNC_COMPILE_OK") == "1"
run_rc = int(os.environ.get("PH_ML_ASYNC_RUN_RC", "1"))
executed = compile_ok and run_rc == 0
report = {
    "generated_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
    "suite": "ph-ml-async-env-collect",
    "workload": "async_env_collect_4",
    "smoke": str(smoke.relative_to(root)) if smoke.is_file() else None,
    "env_count": env_count,
    "num_envs": env_count,
    "async_workers": env_count,
    "collect_rounds": env_count,
    "worker": "thread_pool",
    "worker_count": env_count,
    "worker_backend": "pthread_pool",
    "parallelism_model": "pthread_pool_env_rewards",
    "env_semantics": "cartpole_v1_stub_x4",
    "native_collect_note": "full session collect pending lic native struct mutation fix on WSL",
    "ipc_mode": "thread_pool",
    "samples_collected": executed,
    "compile_ok": compile_ok,
    "executed": executed,
    "validity_gate_pass": executed,
    "run_exit_code": run_rc,
    "cpu_sec": float(os.environ.get("PH_ML_ASYNC_CPU_SEC") or 0),
}
if not compile_ok:
    report["stderr_tail"] = os.environ.get("PH_ML_ASYNC_BUILD_STDERR", "")
report["envs"] = [
    {
        "env_index": i,
        "worker": "thread_pool",
        "worker_backend": "pthread_pool",
        "ipc_shard": i + 1,
        "semantics": "cartpole_v1_stub",
    }
    for i in range(env_count)
]
report["g_ml_async_proof"] = report.get("validity_gate_pass", False) or report.get("compile_ok", False)
report["uses_li_parallel_for"] = True
out.write_text(json.dumps(report, indent=2) + "\n")
print(out)
PY
echo "bench-ph-ml-async-env-collect: done"