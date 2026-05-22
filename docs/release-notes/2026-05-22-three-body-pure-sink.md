# Release notes: 2026-05-22 — three-body-pure-sink

**Status:** WIP
**Repo:** li-langverse/lic
**PR:** branch `cursor/three-body-pure-sink-d968`
**PH / REQ:** PH-5b, PH-7e
**Author:** agent

---

## Summary

`three_body_pure` now uses scalar state, mirrors the native Verlet work scale, and sinks final energy so tier-2 timings measure the Li loop instead of dead-code elimination.

## Agent continuation

1. Read: `benchmarks/tier2_physics/three_body_pure/li/main.li`, `benchmarks/tier2_physics/three_body_pure/common/three_body_core.c`, and `benchmarks/harness/bench.py`.
2. Run: `LLVM_DIR=/usr/lib/llvm-18/lib/cmake/llvm ./scripts/build.sh`; `cd benchmarks/harness && python3 bench.py --tier 2 --runs 1`; then check the `three_body_pure` Li/native ratio in `benchmarks/results/latest.csv`.
3. Then: after `lic#169` lands, rebase this stacked branch onto `main` and rerun tier-2 before benchmarks ingest.
4. Blocked on: `lic#169` because this branch is stacked on the tier-2 extern-contract PR.

## Changed

| Area | What | Evidence |
|------|------|----------|
| `benchmarks/tier2_physics/three_body_pure/li/main.li` | Added `li_rt_volatile_sink_f64`, rewrote the driver to scalar state, mirrored the native `10000000`-step velocity-Verlet work scale, initialized velocities, and sank final energy. | Red check: Li/native ratio was `0.004x` before the change; first array-state fix remained too fast at `0.167x`; scalar-state run is `0.939x`. |

## Not changed

- `li_rt_sqrt` and `sqrt_open_bound` proof policy remain unchanged.
- Shared-C tier-2 drivers and dashboard ingest are not changed here.
- A Li checksum/`--verify` oracle is not added; the pure-Li harness path remains timing-honesty only.
- Full NumPy broadcast and G-par Lean proofs remain open.

## Breaking changes

None — benchmark driver only.

## Security

N/A — this uses the existing runtime volatile sink; no runtime/trusted implementation, stdlib seal, or policy code changed.

## Performance

Tier-2 benchmark honesty change. `cd benchmarks/harness && python3 bench.py --tier 2 --runs 1` reports `three_body_pure li=0.2291s`, `cpp=0.2440s`, ratio `0.939x` on this runner.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Re-ingest after `lic#169` and this branch land. |

## CHANGELOG entry

```markdown
### Fixed
- **Tier-2 `three_body_pure` bench honesty:** use scalar state, mirror native Verlet work scale, and sink final energy via `li_rt_volatile_sink_f64` so LLVM cannot delete the hot loop — `docs/release-notes/2026-05-22-three-body-pure-sink.md`.
```
