# Sprint: PH-ML / PH-LLM / RL Wave 2 — LKIR matmul via @gpu

**Repos:** `lic` (primary), `benchmarks` (tier-3 ingest when competitive JSON updates)  
**Branch:** `cursor/ph-ml-dl-rl-llm-wave2` (create from `cursor/ph-ml-dl-rl-llm-wave1`; merge/rebase `cursor/lig-lkir-ph-hw-sprint` LKIR matmul pilot)  
**Do not** start or rely on the async agent swarm — standalone goal-directed SDK run (`LI_SWARM_EXTERNAL=1`).

## Prerequisites (unblocked 2026-05-30)

| Gate | Status | Notes |
|------|--------|-------|
| Wave 1 CPU spine | **DONE** | PR [#492](https://github.com/li-langverse/lic/pull/492) on `cursor/ph-ml-dl-rl-llm-wave1` |
| PH-HW LKIR matmul pilot | **DONE** | PR [#494](https://github.com/li-langverse/lic/pull/494) on `cursor/lig-lkir-ph-hw-sprint` |
| `lic` compiler | **WSL** | `./build-wsl/compiler/lic/lic` (Windows: use WSL gate runner below) |

## Current status (2026-05-30)

| Phase | Status | Notes |
|-------|--------|-------|
| **A** | pending | Branch `cursor/ph-ml-dl-rl-llm-wave2` with Wave 1 + lig LKIR matmul merged |
| **B** | pending | `ml_matmul_f32` dispatches via `lig_kernel_run` / LKIR kid=1 (CPU pilot path) |
| **C** | pending | `@gpu` decorator stub on matmul hot path (honest stub→real table; no fake CUDA emit) |
| **D** | pending | Tier-3 bench row JSON (`benchmarks/results/ph-ml-lkir-matmul.json`) with `executed: true` |
| **E** | pending | Smokes: `ml_matmul_lkir_parity.li`, `ml_gpu_matmul_stub.li` |
| **F** | pending | Tracker Wave 2 WPs **done**, release note + PR (do not merge without human) |

**Baseline:** Wave 1 landed CPU reference `ml_matmul_f32`; lig sprint landed LKIR catalog + CPU matmul pilot (`li_rt_lig_kernel_run` kid=1). Wave 2 connects them and records tier-3 bench honesty.

## Mission

Land **Wave 2** of [PH-ML-GPU-battle-plan.md](../lic/docs/game-dev/PH-ML-GPU-battle-plan.md): LKIR matmul via `@gpu` hook, tier-3 competitive bench row, honest stub→real for GPU emit (CUDA/HIP/Metal still `N/A` until `LIG_EMIT_*`).

## Read first (in order)

1. `lic/docs/game-dev/PH-ML-GPU-battle-plan.md` — Wave 2 row
2. `lic/docs/game-dev/PH-ML-GPU-execution-tracker.md` — add WP-ML-04..06
3. `lic/docs/game-dev/specs/lillm-rfc.md` — CPU vs GPU table
4. `lic/benchmarks/competitive/lig-kernels.toml` — `lig.kernel.matmul_f32`
5. `lic/packages/lig/li-tests/smoke/kernel_matmul_parity.li`
6. `lic/packages/li-ml/src/lib.li` — Wave 1 CPU spine
7. `.cursor/rules/ph-ml-stub-then-implement.mdc`

## Deliverables

### Phase A — Integration branch

- Create `cursor/ph-ml-dl-rl-llm-wave2` from Wave 1 branch; integrate lig LKIR matmul pilot (merge or cherry-pick from `cursor/lig-lkir-ph-hw-sprint`).
- Ensure `packages/li-ml` + `packages/lig` compile together.

### Phase B — LKIR dispatch in li-ml

- Extend `ml_matmul_f32` to call lig runtime matmul pilot when `ml_use_lkir()` / backend auto selects LKIR path.
- Preserve CPU reference fallback for correctness / parity smoke.
- Update execution tracker WP-ML-04 → `done`.

### Phase C — @gpu decorator stub

- Add `@gpu` entry point or attribute on matmul kernel module (honest stub: documents emit deferred until `LIG_EMIT_CUDA=1`).
- No vendor source strings in user `.li`; LKIR module owns tile contract.

### Phase D — Tier-3 bench row

- Add `scripts/bench-ph-ml-lkir-matmul.sh` (or extend lig parity script) producing `benchmarks/results/ph-ml-lkir-matmul.json`.
- JSON must include `compile_ok`, `validity_gate_pass`, `cpu_sec` or per-kernel `executed: true` — no compile-only fiction.

### Phase E — Smokes

- `packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li` — parity vs CPU reference
- `packages/li-ml/li-tests/smoke/ml_gpu_matmul_stub.li` — `@gpu` stub compiles

### Phase F — Ship

- `docs/release-notes/2026-05-30-ph-ml-dl-rl-llm-wave2.md`
- Update `PH-ML-GPU-execution-tracker.md` Wave 2 rows
- Commit, push, open PR (link #492 and #494 as dependencies)

## Progress gate

```bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
test -f docs/game-dev/PH-ML-GPU-battle-plan.md
grep -q 'Wave 2' docs/game-dev/PH-ML-GPU-battle-plan.md
test -f packages/li-ml/src/lib.li
grep -q 'ml_matmul_f32' packages/li-ml/src/lib.li
test -f packages/lig/lkir/matmul_f32.li || test -f packages/lig/lkir/matmul_tile_f32.lkir
echo "ph-ml-wave2: progress gate OK"
```

## Completion gate

Loop and reviewers treat this block as the sprint exit check (`goal-completion-gate.js`). All phases **A–F** must be **DONE** in the status table above.

```bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
if [[ -x "./scripts/ph-ml-wave2-gates.sh" ]]; then
  ./scripts/ph-ml-wave2-gates.sh
else
  LIC="${LIC:-./build-wsl/compiler/lic/lic}"
  if [[ ! -x "$LIC" && -x "./build/compiler/lic/lic" ]]; then
    LIC="./build/compiler/lic/lic"
  fi
  if [[ ! -x "$LIC" ]] && command -v wsl.exe >/dev/null 2>&1; then
    wsl.exe bash -lc "set -euo pipefail; cd \"\$(wslpath -u \"\$(pwd)\")\"; LIC=./build-wsl/compiler/lic/lic; export LIC; test -x \"\$LIC\" || { echo 'build lic: ./scripts/build.sh --build-dir build-wsl'; exit 1; }; for smoke in packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li packages/li-ml/li-tests/smoke/ml_gpu_matmul_stub.li; do test -f \"\$smoke\"; \"\$LIC\" check --allow-open-vc \"\$smoke\"; done; test -f benchmarks/results/ph-ml-lkir-matmul.json; python3 -c \"import json,sys; d=json.load(open('benchmarks/results/ph-ml-lkir-matmul.json')); sys.exit(0 if d.get('compile_ok') and d.get('validity_gate_pass') else 1)\""
  else
    test -x "$LIC" || { echo "build lic first"; exit 1; }
    for smoke in packages/li-ml/li-tests/smoke/ml_matmul_lkir_parity.li packages/li-ml/li-tests/smoke/ml_gpu_matmul_stub.li; do
      test -f "$smoke" || exit 1
      "$LIC" check --allow-open-vc "$smoke" || exit 1
    done
    test -f benchmarks/results/ph-ml-lkir-matmul.json
  fi
  test -f docs/release-notes/2026-05-30-ph-ml-dl-rl-llm-wave2.md
  grep -q 'Wave 2' docs/game-dev/PH-ML-GPU-execution-tracker.md
  echo "ph-ml-dl-rl-llm-wave2: completion gate OK"
fi
```

## Agent environment (Windows sprint host)

- `LI_SKIP_IMPLEMENTER_PREFLIGHT_GATE=1` when native `./scripts/build.sh` cannot run; prefer WSL `build-wsl` (`CC=clang-22`, `LLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm`).
- Set `LIC=./build-wsl/compiler/lic/lic` in WSL/bash; gates above auto-fallback to `wsl.exe` on Windows.
- CUDA/HIP/Metal vendor emit **out of scope** unless gated behind `LIG_EMIT_*` — do not block on GPU hardware.

## Agent

Use **`code_implementer`**.
