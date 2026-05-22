# Tier-2 physics benches: extern `requires`/`ensures` + `raises IO`

## Summary

Nine tier-2 shared-kernel drivers plus `three_body_pure` now declare `requires`/`ensures` on `extern proc` and `raises IO` on `main`, unblocking `bench.py --tier 2` (including `rigid_body_stack`).

## Agent continuation

1. **Read:** `benchmarks/tier2_physics/*/li/main.li` (pattern matches `wave_equation_1d`); `benchmarks/harness/bench.py` (`build_li` passes `--allow-open-vc`).
2. **Run:** `cd benchmarks/harness && python3 bench.py --tier 2`; confirm `benchmarks/results/latest.csv` includes `rigid_body_stack`.
3. **Then:** In **benchmarks** repo after merge — `LIC_ROOT=<lic> ./scripts/ingest/ingest-lic.sh`; refresh dashboard Pages.
4. **Blocked on:** P-float `sqrt_open_bound` discharge; full NumPy broadcast (2i); Lean `disjoint_elem` proofs (7d-c).

## Changed

| Path | Evidence |
|------|----------|
| `benchmarks/tier2_physics/rigid_body_stack/li/main.li` | `lic build` + tier-2 sweep green |
| `benchmarks/tier2_physics/{cloth_swing,combustion_passive,euler_fluid_2d,fdtd_waveguide_2d,orbit_two_body,ragdoll_chain,schrodinger_1d_barrier,wind_field_bc}/li/main.li` | same contract pattern |
| `benchmarks/tier2_physics/three_body_pure/li/main.li` | `li_rt_sqrt` contracts + `ensures` on `three_body_forces` |
| `docs/verification/p-float-sqrt-open.md` | documents why `sqrt_open_bound` must remain open |
| `docs/verification/provability-gaps.md` | notes proc-level `@parallel(disjoint=)` inheritance while Lean proofs remain open |

## Not changed

- `sqrt_open_bound.li` — still intentionally open in `contracts_discharge_corpus.sh`.
- Compiler broadcast beyond `array[1]` × `array[N]` (PH-2i full NumPy rules).
- Lean G-par discharge (`Discharge.lean` disjoint lemmas).

## Breaking / Security / Performance / Downstream

| Topic | Status |
|-------|--------|
| **Breaking** | N/A — bench drivers only |
| **Security** | N/A — no trusted surface or runtime policy changed |
| **Performance** | N/A — no kernel change |
| **Downstream** | **benchmarks** ingest after merge; `catalog.toml` `rigid_body_stack` row unchanged |
