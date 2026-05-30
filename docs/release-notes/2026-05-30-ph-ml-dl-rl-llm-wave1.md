# PH-ML / PH-LLM / RL Wave 1 (2026-05-30)

## Summary

Wave 1 tranche: CPU matmul spine in li-ml, li-ml-rl EnvPool re-export, PH-ML program docs, ml-async-parallel RFC JobGraph sketch.

## Stub to Real

| API | Stub | Real (Wave 1) | Verification |
|-----|------|---------------|--------------|
| ml_matmul_f32 | lig id only | CPU reference matmul | ml_matmul_f32.li |
| ml_rl_env_pool_step | n/a | delegates sim_rl_session_env_pool_step | env_pool_reexport.li |
| llm_forward | checksum top_id | unchanged stub (Wave 2 matmul hook) | llm_forward.li |

## Packages

- packages/li-ml — ml_version, ml_matmul_f32, smokes
- packages/li-ml-rl — ml_rl_env_pool_step re-export
- docs/game-dev/PH-ML-GPU-battle-plan.md + tracker

## Gates (Wave 1)

- Progress gate: `ph-ml-wave1: progress gate OK` (file presence + JobGraph RFC)
- Completion gate: `ph-ml-dl-rl-llm-wave1: completion gate OK` (smoke paths; `lic check` when compiler built)

## Branch

Swarm run: `code_implementer-1780121552859` · agent: `code_implementer`

Verification run 2026-05-30: progress + completion gates exit 0 (smoke paths; `lic check` deferred without local compiler build).

Verification run `code_implementer-1780122552128`: progress + completion gates exit 0 on `cursor/ph-ml-dl-rl-llm-wave1` (PR #492).
