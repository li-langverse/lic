
| WP-LIG-01 | LIG_EMIT_* vendor emit progress | 12 | partial | lig-emit-vendor-stub.sh |
| WP-LLM-06 | GPU matmul via li_rt_lig_matmul_ready | 12 | partial | llm_safetensors_mmap.li |
| WP-LLM-08 | li-httpd trusted route scaffold | 12 | partial | llm_trusted_httpd_route.li |
| WP-LLM-09 | safetensors 64B/tensor mmap chunk | 12 | partial | llm_safetensors_mmap.li |
| WP-ML-05 | @gpu LKIR launch pipeline | 12 | partial | ml_gpu_lkir_launch.li |
| WP-ML-19 | 16×16 blocked CPU matmul | 12 | done | ml_matmul_cpu_blocked_16 |
| WP-RL-07 | fork/spawn IPC bench | 12 | partial | bench_ph_ml_rl_env_ipc_fork.py |

| WP-LIG-02 | Vendor PTX/HS/MSL lowering bytes (Wave 13 T1) | 13 | done | lig_emit_vendor_lowering_ready + build/lig-emit-vendor.ptx |
| WP-ML-20 | @gpu device buffer pipeline (Wave 13 T2) | 13 | done | ml_gpu_device_buffer_pipeline + ml_gpu_device_buffer.li |
| WP-LLM-10 | `import ml` in li-llm (Wave 13 T3) | 13 | done | llm_import_ml.li |
| WP-LLM-11 | safetensors/GGUF file mmap (Wave 13 T7) | 13 | done | llm_weights_file_mmap.li + prepare_ph_ml_weights_fixture.py |
| WP-LLM-12 | live Ollama/li-httpd proxy bench (Wave 13 T8) | 13 | done | bench_ph_ml_llm_trusted_httpd.py live_proxy |
| WP-ML-21 | 32×32 blocked LKIR matmul competitive row (Wave 13 T6) | 13 | done | ml_matmul_lkir_logical_32 + bench-ph-ml-lkir-matmul-32.sh |
| WP-RL-08 | Li process fork env pool + Studio hook (Wave 13 T4) | 13 | done | env_pool_li_process_fork.li + studio_sim_rl_step_hook |
| WP-RL-09 | SB3/Ray hard CI benches (Wave 13 T5) | 13 | done | bench_ph_ml_competitor_sb3_vecenv.py + bench_ph_ml_competitor_ray_rllib.py |

**Wave 13:** program complete — closes Wave 12 deferred items (T1–T8); milestone gate `ph-ml-wave13-gates.sh`, completion gate `ph-ml-program-complete-gates.sh`

**Wave 12:** final deferred GPU/LLM/RL/competitive items

**Wave 10:**
**Wave 11:** Wave 10 carryover sprint (WP-LLM-06..08, WP-RL-07, competitive)

| WP | Item | Wave | Status | Artifact |
| WP-LLM-06 | GPU/LKIR matmul progress | 11 | done | ml_gpu_matmul_stub.li |
| WP-LLM-07 | lillm-import HF/offline | 11 | partial | lillm-import.sh |
| WP-LLM-08 | Ollama trusted backend scaffold | 11 | partial | llm_trusted_backend_scaffold.li |
| WP-LLM-09 | safetensors byte tensor scaffold | 11 | done | llm_safetensors_bytes.li |
| WP-ML-19 | 16×16 logical LKIR matmul row | 11 | partial | ml_matmul_16_lkir.li |
| WP-ML-20 | Rust MLP competitor | 11 | partial | bench_ph_ml_competitor_rust_mlp.py |
| WP-RL-07 | SB3 SubprocVecEnv + fork IPC pilot | 11 | partial | bench_ph_ml_rl_env_ipc_fork.py |

**Wave 10:** PH-LLM depth + RL IPC + competitive MLP/SB3 (WP-LLM-01..07, WP-RL-06..07)

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

| WP-LLM-01 | BPE merge pass | 10 | partial | llm_tokenize_bpe.li |
| WP-LLM-02 | safetensors tensor scaffold | 10 | partial | llm_safetensors_tensors.li |
| WP-LLM-03 | transformer matmul contrib | 10 | partial | llm_forward_matmul.li |
| WP-LLM-04 | KV-cache greedy decode | 10 | partial | llm_kv_cache_decode.li |
| WP-LLM-05 | tier-3 LLM bench row | 10 | done | ph-ml-llm-forward.json |
| WP-LLM-06 | GPU matmul hint (honest stub) | 10 | partial | llm_forward_gpu_matmul_hint |
| WP-LLM-07 | HF import CLI + doc | 10 | partial | lillm-import.sh |
| WP-RL-06 | IPC multiprocess scaffold | 10 | partial | env_pool_ipc_scaffold.li |
| WP-RL-07 | SB3 SubprocVecEnv driver | 10 | partial | bench_ph_ml_competitor_sb3_vecenv.py |
| WP-ML-16 | NumPy MLP competitor | 10 | done | bench_ph_ml_competitor_numpy_mlp.py |
| WP-ML-17 | C++ MLP competitor | 10 | done | bench_ph_ml_competitor_cpp_openmp_mlp.py |
| WP-ML-18 | ml_matmul perf v6 lanes=8 max_dim=32 | 10 | done | ml_matmul_general.li |
| program complete | Wave 13 | done | ph-ml-program-complete-gates.sh |

