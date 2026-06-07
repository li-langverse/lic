#!/usr/bin/env bash
# PH-ML Stage 3 — Parallel RL (async collect executed, IPC scaffold, train scaffold).
set -euo pipefail
ROOT="${PH_ML_STAGE3_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)}"
cd "$ROOT"

run_in_wsl() {
  local wsl_root
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  wsl.exe bash -lc "cd '$wsl_root' && export PH_ML_STAGE3_ROOT='$wsl_root' PH_ML_STAGE3_INNER=1 && bash scripts/ph-ml-stage3-gates.sh"
}

if [[ "${PH_ML_STAGE3_INNER:-0}" != "1" ]] && [[ ! -x "$ROOT/build/compiler/lic/lic" && ! -x "$ROOT/build/compiler/lic/lic.exe" ]] && command -v wsl.exe >/dev/null 2>&1; then
  wsl_root="$(wsl.exe wslpath -u "$ROOT" 2>/dev/null | tr -d '\r\n')"
  if [[ -n "$wsl_root" ]] && wsl.exe bash -lc "test -x '$wsl_root/build-wsl/compiler/lic/lic'" 2>/dev/null; then
    run_in_wsl
    exit $?
  fi
fi

export BENCHMARKS_ALLOW_NO_HARNESS=1
# shellcheck source=lib/benchmarks-env.sh
source "$ROOT/scripts/lib/benchmarks-env.sh"
export BENCHMARKS_RESULTS="$ROOT/benchmarks/results"
mkdir -p "$BENCHMARKS_RESULTS"

LIC="${LIC:-}"
if [[ -x "$ROOT/build-wsl/compiler/lic/lic" ]]; then
  LIC="$ROOT/build-wsl/compiler/lic/lic"
elif [[ -x "$ROOT/build/compiler/lic/lic" ]]; then
  LIC="$ROOT/build/compiler/lic/lic"
fi
[[ -x "$LIC" ]] || { echo "ph-ml-stage3-gates: build lic (./scripts/build.sh --build-dir build-wsl in WSL)"; exit 1; }

bash scripts/ph-ml-program-complete-gates.sh

grep -q '"li-ml-rl"' packages/li.toml || { echo "3.1: li-ml-rl missing from workspace members"; exit 1; }
grep -q 'env_pool_ipc_prepare_shards' packages/li-sim/src/lib.li || { echo "3.2: missing IPC shard prepare"; exit 1; }
grep -q 'policy_loss_mean' packages/li-ml-rl/src/lib.li || { echo "3.3: missing policy_loss_mean train scaffold"; exit 1; }
grep -q 'sim_rl_env_cartpole_v1_semantics' packages/li-sim/src/lib.li || { echo "3.2: missing CartPole stub semantics"; exit 1; }

export CC="${CC:-clang-22}" CXX="${CXX:-clang++-22}"
for smoke in \
  packages/li-ml-rl/li-tests/smoke/env_pool_async_four.li \
  packages/li-ml-rl/li-tests/smoke/env_pool_process_scaffold.li \
  packages/li-ml-rl/li-tests/smoke/job_graph_train_eval.li \
  packages/li-sim/li-tests/smoke/env_pool_ipc_scaffold.li; do
  [[ -f "$smoke" ]] || { echo "missing smoke: $smoke"; exit 1; }
  "$LIC" build --allow-open-vc "$smoke" -o /dev/null || { echo "lic build failed: $smoke"; exit 1; }
done

bash scripts/bench-ph-ml-async-env-collect.sh
bash scripts/bench-ph-ml-competitive.sh

python3 - <<'PY'
import json, sys
from pathlib import Path

root = Path("benchmarks/results")
async_d = json.loads((root / "ph-ml-async-env-collect.json").read_text())
if not async_d.get("executed"):
    sys.exit("3.1: ph-ml-async-env-collect executed must be true")
if not async_d.get("validity_gate_pass"):
    sys.exit("3.1: ph-ml-async-env-collect validity_gate_pass must be true")
if async_d.get("worker") != "thread_pool":
    sys.exit("3.1: worker must be thread_pool")
if (async_d.get("env_count") or 0) < 4:
    sys.exit("3.1: need >=4 envs")

comp = json.loads((root / "ph-ml-competitive.json").read_text())
rows = {r.get("id"): r for r in (comp.get("rows") or [])}
async_row = rows.get("async_env_collect") or {}
li = async_row.get("li") or {}
if not li.get("executed"):
    sys.exit("3.1: competitive async_env_collect li.executed must be true")
if not li.get("validity_gate_pass"):
    sys.exit("3.1: competitive async_env_collect li.validity_gate_pass must be true")
if not async_d.get("g_ml_async_proof"):
    sys.exit("3.1: g_ml_async_proof must be true")
print("stage3 benches OK", "cpu_sec=", async_d.get("cpu_sec"), "li_ratio=", li.get("ratio_vs_li"))
PY

[[ -f data/goal-directed-sprints/ph-ml-stage3-parallel-rl.md ]] \
  || { echo "missing stage3 goal file"; exit 1; }
[[ -f docs/release-notes/2026-06-04-ph-ml-stage3-parallel-rl.md ]] \
  || { echo "missing stage3 release note"; exit 1; }
[[ -f docs/game-dev/specs/ml-rl-ppo-deferral.md ]] \
  || { echo "missing PPO deferral spec"; exit 1; }
grep -q 'Stage 3' docs/game-dev/PH-ML-GPU-battle-plan.md \
  || { echo "battle plan missing Stage 3 row"; exit 1; }
grep -q 'WP-RL-10' docs/game-dev/PH-ML-GPU-execution-tracker.md \
  || { echo "tracker missing Stage 3 WPs"; exit 1; }

echo "ph-ml-stage3-parallel-rl: completion gate OK"
