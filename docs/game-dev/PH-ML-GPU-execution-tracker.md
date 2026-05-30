# PH-ML-GPU execution tracker

**Wave 2:** LKIR matmul + @gpu stub (WP-ML-04..06)

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
| WP-RL-02 | Async parallel pools | 3 | blocked | PH-ML Wave 3 |
