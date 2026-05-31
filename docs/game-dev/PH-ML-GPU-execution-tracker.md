**Wave 7:** PH-LLM tokenizer/safetensors/transformer + NumPy competitor (WP-LLM-01..03, WP-ML-12)

**Wave 9:** PH-LLM recovery (WP-LLM-01..05) + C++/Rust competitors + matmul perf

**Wave 6:** 16×16 flat matmul + process env scaffold + competitive benches (WP-ML-11, WP-RL-05, WP-LLM-02..04)

**Wave 5:** Thread-pool env workers + JobGraph sample queue (WP-RL-04, WP-ML-10)

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
| WP-RL-04 | pthread parallel env reward fill + sample queue | 5 | done | env_pool_thread_parallel.li + job_graph_sample_queue.li |
| WP-ML-10 | general ml_matmul_cpu_ref flat indexing | 5 | done | ml_matmul_general.li |
| WP-ML-11 | ml_matmul_max_dim + flat idx + cpu_ref_flat (m,n,k≤16) | 6 | done | ml_matmul_16_flat.li + ph-ml-wave6-gates.sh |
| WP-RL-05 | OS process env worker scaffold | 6 | done | env_pool_process_scaffold.li |
| WP-LLM-02 | llm_forward smoke + bench row | 6 | stub | llm_forward.li + ph-ml-llm-forward.json |
| WP-LLM-03 | llm_generate smoke | 6 | stub | llm_generate.li |
| WP-LLM-04 | competitive llm_forward row | 6 | stub | ph-ml-competitive.json |

**Wave 8:** SOTA competitor drivers (PyTorch/JAX/TF/Triton) + ratio_vs_li (WP-ML-12)
| WP-ML-12 | SOTA competitor drivers + ph-ml-competitive ratio_vs_li | 8 | done | bench-ph-ml-competitor-all.sh + ph-ml-wave8-gates.sh |

| WP-LLM-01 | BPE tokenizer scaffold + vocab.bpe.json | 9 | partial | llm_tokenize_bpe.li |
| WP-LLM-02 | safetensors header parse | 9 | partial | llm_safetensors_header.li |
| WP-LLM-03 | transformer matmul via ml_matmul_f32 | 9 | partial | llm_forward_matmul.li |
| WP-LLM-04 | llm_generate greedy decode | 9 | partial | llm_generate.li |
| WP-LLM-05 | llm_forward bench validity_gate_pass | 9 | done | ph-ml-llm-forward.json |
| WP-ML-13 | C++ OpenMP matmul competitor | 9 | done | bench_ph_ml_competitor_cpp_openmp_matmul.py |
| WP-ML-14 | Rust matmul competitor pilot | 9 | done | bench_ph_ml_competitor_rust_ndarray_matmul.py |
| WP-ML-15 | ml_matmul perf (lanes=8, max_dim=32) | 9 | done | ml_matmul_general.li |
| WP-RL-07 | process mode 2 thread-pool honest label | 9 | partial | env_pool_process_scaffold.li |

| WP-LLM-01 | BPE/byte tokenizer scaffold | 7 | partial | llm_tokenize_bpe.li |
| WP-LLM-02 | safetensors header parse scaffold | 7 | partial | llm_safetensors_header.li |
| WP-LLM-03 | transformer matmul graph scaffold | 7 | partial | llm_forward.li + ml_matmul_f32 |
| WP-ML-12 | NumPy matmul competitive driver | 7 | done | bench-ph-ml-competitor-numpy-matmul.sh |
| WP-RL-06 | process worker defer label | 7 | deferred | sim_rl_env_worker_process_mode_label |
