# li-ml traceability (stub)

**Package ID:** `PKG-li-ml`  
**Import:** `ml` (+ submodules `ml.nn`, `ml.optim`, `ml.dl`, `ml.ai`)  
**Program:** PH-ML ML-0 (Wave 0)

## Work packages (Wave 0)

| WP | Module | Smoke |
|----|--------|-------|
| WP-ML-01 | workspace | `builds.li` |
| WP-ML-02 | `ml` | `activations.li` |
| WP-ML-03 | `ml.nn` | `mlp_forward.li` |
| WP-ML-06 | `ml.optim` | `train_step.li` (SGD via `dl_train_step4`) |
| WP-ML-09 | `ml.ai` | `ai_batch.li` |
| WP-ML-10 | `ml` + `lig` | `gpu_bridge.li` (interface only) |

## Proof gates

- All Wave 0 smokes: `outcome = verify_ok` in `li-tests/manifest.toml`
- Tier-3 correctness: **not claimed** until Wave 1 (WP-BENCH-ML-02)

## Cross-links

- [README.md](README.md)
- [PH-ML-GPU-battle-plan.md](../../docs/game-dev/PH-ML-GPU-battle-plan.md)
- [PH-ML-GPU-execution-tracker.md](../../docs/game-dev/PH-ML-GPU-execution-tracker.md)
