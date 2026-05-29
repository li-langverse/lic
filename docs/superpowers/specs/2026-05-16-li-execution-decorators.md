# Execution decorators (spec stub)

**Status:** Phase 7d in progress (`@gpu` / `@gpu(devices=N)` MIR telemetry landed; LKIR/codegen open)
**Plan:** `.cursor/plans/li_execution_decorators_7c6e3b42.plan.md`  
**Gaps:** [Provability gaps](../../verification/provability-gaps.md) **G-dec**

## No runtime semantics

Decorators are **not** Python-style runtime callables. There is:

- **No** runtime decorator registry or dynamic dispatch  
- **No** wrapping functions at call time  
- **No** interpreting `@foo` when the program runs  

`@parallel`, `@vectorized`, `@gpu`, `@cpu`, etc. are resolved entirely during **`lic build`**: parse → validate → elaborate to MIR (`ParallelFor`, SIMD lanes, device-placement tags). Illegal stacks, invalid `devices=`, or missing `disjoint=` are **compile errors**.

User `decorator def` macros expand at **compile time** to a whitelist of builtin decorators only.

**Goal:** zero user-visible decorator failures at runtime — if it builds, placement and parallelism shape are already proved.

---

Reserved stdlib names: `cpu`, `gpu`, `tpu`, `user_defined`, `parallel`, `vectorized`, `async`, `serial`, `no_vectorize`.

User `decorator def` names: strict package-prefixed snake_case; typosquat ban; expansion whitelist to builtins only.

## GPU placement slice

`@gpu` is now visible in MIR and `lic verify` telemetry:

- `mir_gpu_proc` counts functions tagged with `@gpu`.
- `mir_gpu_multi_device_proc` counts functions tagged with `@gpu(devices=N)` where `N > 1`.
- `@gpu(devices=0)` and non-integer `devices` values are rejected (`gpu_devices`) so impossible placement is not silently accepted.
- Vendor/backend arguments such as `vendor="cuda"` are rejected; backend selection belongs to `lig` config/runtime gates, not source-level decorator strings.

This is **placement metadata only**. It does not yet lower kernels to LKIR, allocate device buffers, prove address-space separation, or emit CUDA/HIP/Metal/SPIR-V. Those remain **G-gpu** work.

See master plan Phase **7d** and `li-tests/decorator_exploits/` (to land with 7d-e).
