**Wave 4:** General CPU matmul + MLP forward + sync parallel RL (WP-ML-07..09, WP-RL-03)

# PH-ML-GPU execution tracker

**Wave 2:** LKIR matmul + @gpu stub (WP-ML-04..06)

**Wave 3:** Async JobGraph + >=4 env sample collection (WP-RL-02)

**Battle plan:** [PH-ML-GPU-battle-plan.md](PH-ML-GPU-battle-plan.md)

| WP | Title | Wave | Status | Verification |
|----|-------|------|--------|--------------|
| WP-ML-01 | ml_version + package smoke | 1 | done | lic check builds.li |
| WP-ML-02 | ml_matmul_f32 CPU reference | 1 | done | lic check ml_matmul_f32.li |
| WP-ML-03 | li-ml-rl EnvPool re-export | 1 | done | env_pool_reexport.li |
| WP-ML-04 | ml_matmul_f32 LKIR dispatch | 2 | done | ml_matmul_lkir_parity.li |
| WP-ML-05 | @gpu matmul emit stub | 2 | done | ml_gpu_matmul_stub.li |
| WP-ML-06 | tier-3 ph-ml-lkir-matmul.json | 2 | done | bench-ph-ml-lkir-matmul.sh |
| WP-LLM-01 | Byte tokenizer roundtrip | 1 | stub | llm_tokenize_roundtrip.li |
| WP-RL-02 | Async parallel pools | 3 | done | job_graph_collect.li + ph-ml-async-env-collect.json |

| WP-ML-07 | general ml_matmul_cpu_ref (m,n,k<=8) + @vectorized dot | 4 | done | ml_matmul_general.li |
| WP-ML-08 | ml_mlp_forward_f32 + lig MLP kid=2 | 4 | done | ml_mlp_forward.li + ph-ml-mlp-forward.json |
| WP-ML-09 | ml_lig_matmul_run_auto for li-llm | 4 | done | ml_lig_matmul_run_auto.li |
| WP-RL-03 | persistent EnvPool + SampleJob + Train/Eval nodes | 4 | done | job_graph_train_eval.li |