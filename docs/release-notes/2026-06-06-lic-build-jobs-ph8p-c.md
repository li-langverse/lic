# PH-8p-c: lic build --jobs wires parallel LLVM emit

## Summary

`compile_jobs_from_options()` now drives parallel LLVM emit Pass 2 (per-`MirFn` bodies) when `--jobs=N` > 1. Pass 1 (symbol declare) and Lean verify remain serial.

## Changed

| Path | Evidence |
|------|----------|
| `compiler/codegen/emit.cpp` | Parallel Pass 2 via thread pool; `emit_user_fn_body` helper |
| `compiler/codegen/compile.cpp` | `LI_COMPILE_JOBS_LOG=1` diagnostic |
| `li-tests/tooling/compile_jobs_httpd_smoke.sh` | #525 acceptance smoke on httpd `lib.li` |
| `scripts/ci.sh` | 8p phase includes compile-jobs smoke |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | 8p-c wired row |
| `data/swarm-gap-registry/registry.yaml` | Close `gap-plan-debt-lic-master-plan-phase-8p-*` |

## Not changed

- Parallel MIR lowering, Lean verify, or clang link
- 8p-b workspace pool (separate track)

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| Breaking | N/A — `--jobs=1` serial path unchanged |
| Security | N/A |
| Performance | `--jobs>1` schedules Pass 2 workers; LLVMContext mutex serializes IR today (ThreadSafeModule follow-up for full speedup) |
| Downstream | Use `LI_COMPILE_JOBS_LOG=1` to inspect effective job budget |
