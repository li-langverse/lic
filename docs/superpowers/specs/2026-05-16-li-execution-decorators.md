# Execution decorators (spec stub)

**Status:** Phase 7d in progress (`@gpu` / `@cpu` MIR telemetry landed; LKIR/vendor codegen open)
**Plan:** `.cursor/plans/li_execution_decorators_7c6e3b42.plan.md`  
**Gaps:** [Provability gaps](../../verification/provability-gaps.md) **G-dec**

## No runtime semantics

Decorators are **not** Python-style runtime callables. There is:

- **No** runtime decorator registry or dynamic dispatch  
- **No** wrapping functions at call time  
- **No** interpreting `@foo` when the program runs  

`@parallel`, `@vectorized`, `@gpu`, `@cpu`, etc. are resolved entirely during **`lic build`**: parse → validate → elaborate to MIR (`ParallelFor`, `GpuFor`, SIMD lanes, device-placement tags). Illegal stacks, invalid `devices=`, or missing `disjoint=` are **compile errors**.

User `decorator def` macros expand at **compile time** to a whitelist of builtin decorators only.

**Goal:** zero user-visible decorator failures at runtime — if it builds, placement and parallelism shape are already proved.

---

Reserved stdlib names: `cpu`, `gpu`, `tpu`, `user_defined`, `parallel`, `vectorized`, `async`, `serial`, `no_vectorize`.

User `decorator def` names: strict package-prefixed snake_case; typosquat ban; expansion whitelist to builtins only.

## GPU / CPU placement slice

- `mir_gpu_def`, `mir_gpu_multi_device_def`, `mir_gpu_for`, `mir_cpu_def` in `lic verify` telemetry.
- `@gpu(devices=N)` requires integer literal `N >= 1`; vendor strings rejected (`gpu decorator`).
- Backend: `[engine.lig] backend = "cuda"|"rocm"|"metal"|"webgpu"` — see [gpu-backend-driver.md](../../compiler/gpu-backend-driver.md).
- `LI_GPU_BACKEND` enables `li_rt_lig_gpu_for_i64` stub; full LKIR emit remains **G-gpu**.

See master plan Phase **7d** and `li-tests/decorator_exploits/`.
