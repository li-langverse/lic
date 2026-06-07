# PH-ML Stage 2 — Native DL spine

**Repos:** `lic`  
**Branch:** `cursor/ph-ml-stage2-dl-spine`  
**Gate:** `bash scripts/ph-ml-stage2-gates.sh` (WSL + `lic-bin-select`)

## Phases

| Phase | Scope | Done when |
|-------|--------|-----------|
| **2.1** | CPU/LKIR matmul scale, vendor emit HIP/MSL stubs, `@gpu` buffer + kid=2 | `ml_matmul_flat_to_nested_general`, 32×32 bench `executed:true`, program-complete still passes |
| **2.2** | `ml_mlp_forward_f32` + lig kid=2, competitive MLP row | `bench-ph-ml-mlp-competitive.sh`, tier-1/tier-3 `executed:true` |
| **2.3a** | Autograd RFC | `docs/game-dev/specs/ml-autograd-forward-tape-rfc.md` |
| **2.3b** | Backward stub ≤32 | `ml_autograd_*` smokes, honest `workload_class` |
| **2.3c** | `ml_mlp_train_step` tier-1 bench | `ph-ml-mlp-train-step.json` with `forward_only_scaffold` |

## Status

| Phase | Status |
|-------|--------|
| 2.1 | **DONE** — 8×8 flat matmul, LKIR×32 prologue, HIP/MSL emit stubs, MLP in device pipeline |
| 2.2 | **DONE** — lig kid=2 runtime, competitive MLP bench |
| 2.3 | **DONE** — RFC + stub + train-step bench scaffold |

## Completion gate

```bash
bash scripts/ph-ml-stage2-gates.sh
```

Must also keep `bash scripts/ph-ml-program-complete-gates.sh` green (invoked inside stage2 gate).
