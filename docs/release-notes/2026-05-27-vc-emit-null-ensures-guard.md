# Release notes: 2026-05-27 — vc-emit-null-ensures-guard

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-2f / security (httpd build)  

---

## Summary

Fixes `lic build` segfault in AutoVC emission when processing trivial `ensures` on large packages (`li-net-httpd`): null-safe `ensures_rhs_eq_result` and `witness_dot4_int_loop` guard.

## Agent continuation

1. **Run:** `./build/compiler/lic/lic build --allow-open-vc --no-lean-verify packages/li-net-httpd/src/lib.li -o build/li-httpd`
2. **Run:** `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh`
3. **Then:** merge; re-run benchmarks `run-full-benchmark-suite.sh`

## Changed

- `compiler/verify/vc_emit_lean.cpp` — `ensures_rhs_eq_result` uses `.get()`; `witness_dot4_int_loop` only when `rhs != nullptr`; alias-cycle guard in `lean_type_name`

## Not changed

- httpd runtime semantics, tier-5 benches

## Breaking / Security / Performance / Downstream

N/A — crash fix only.
