# PH-ML / PH-LLM / RL Wave 3 (2026-05-30)

## Summary

Wave 3 tranche: async JobGraph scaffold in li-ml-rl, >=4 parallel env sample collection via EnvPool stub workers, Studio sim_rl smoke, async env bench JSON.

## Stub to Real

| API | Stub | Real (Wave 3) | Verification |
|-----|------|---------------|--------------|
| `JobGraphStub` / `SampleJob` | in-process DAG counters | sync stub workers over 4 env slots | job_graph_collect.li |
| `ml_rl_job_graph_collect` | wraps `env_pool_stub_step` | same; fills graph + replay contract | job_graph_collect.li |
| `ml_rl_env_pool_async_collect` | n/a | >=4 env handles via default pool | env_pool_async_four.li |
| Studio sim_rl | profile + step hook | JobGraph collect + `studio_sim_rl_step_hook` | studio_sim_rl_step.li |

## Packages

- packages/li-ml-rl — JobGraph types, async collect defs, smokes
- packages/li-sim — EnvPool stub (pool_size default 4)
- packages/li-studio — sim_rl vertical smoke
- benchmarks/results/ph-ml-async-env-collect.json — `env_count >= 4`

## Gates (Wave 3)

- Progress gate: `ph-ml-wave3: progress gate OK`
- Completion gate: `ph-ml-dl-rl-llm-wave3: completion gate OK` (`scripts/ph-ml-wave3-gates.sh`)

## Branch

`cursor/ph-ml-dl-rl-llm-wave3` · WP-RL-02 done
