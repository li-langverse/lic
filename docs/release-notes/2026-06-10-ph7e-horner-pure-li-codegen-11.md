# Release notes: 2026-06-10 — PH-7e Horner pure-Li codegen (lic#11)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PH / REQ:** PH-5b, PH-7e, PH-2f, G-math  
**Issue:** [#11](https://github.com/li-langverse/lic/issues/11) (GitLab lic#10)

## Summary

`HornerConstLoopF64` now emits a scalar FMA counted loop matching `horner_core.c`, plus new `math_linalg/` trip-edge probes and a MIR witness script. `provability-gaps.md` retracts premature tier-1 `horner_pure_li` closed-slice wording until ingest is green.

## Changed

| Area | What |
|------|------|
| Codegen | `HornerConstLoopF64` → one `emit_fma_f64` per logical step (C++ oracle parity) |
| li-tests | `horner_pure_li_mirror.li`, `horner_trip_edges.li`, manifest rows |
| Gates | `horner_mir_codegen_gap.sh` — FMA witness on mirror build |
| Docs | `provability-gaps.md` — honest Partial for `horner_pure_li` until ≤1.2× measured |

## Tests (CI)

```bash
./scripts/build.sh
./li-tests/run_all.sh math_linalg
./li-tests/tooling/horner_mir_codegen_gap.sh
./li-tests/tooling/horner_fma_numerically_stable_gap.sh
./scripts/check-tier1-li-vs-cpp.sh
```

## North star fit

Scientific computing micro-kernels · **PH-5b**, **PH-7e** · proof → easy → fast
