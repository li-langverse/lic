# PH-SCI simulation gap-close plan (monorepo pointer)

Full gap-close inventory lives in sibling worktrees; this repo tracks **GPU science** execution.

## GPU Chem / DFT (headline)

See **[ph-sci-gpu-chem-dft.md](ph-sci-gpu-chem-dft.md)** for WP-SCI-GPU-CHEM-01..04, stub vs real audit, and PH-ML Phase 3 LKIR hooks.

## Phase 3 — Vendor GPU / LKIR (excerpt)

Cross-reference [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md) Waves 2, 11–13, Stage 2.

- **WP-SCI-GPU-VENDOR-01** — Science hot loop LKIR pilot (numerics three-body or **chem DFT density loop** after CHEM-01).
- **WP-SCI-GPU-VENDOR-02** — Device buffer bind for MD/chem grids.
- **WP-SCI-GPU-VENDOR-03** — `ph-sci-gpu-chem-gates.sh` + `check-science-gpu-gate.sh` unified CI.

## Verification

```bash
bash scripts/ph-sci-gpu-chem-gates.sh
./li-tests/run_all.sh science_gpu
```
