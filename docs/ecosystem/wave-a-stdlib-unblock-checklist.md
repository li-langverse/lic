# Wave A stdlib unblock checklist (WP-WA)

**Program:** Li stdlib ADT — close strict Wave A before list/dict runtime (WP1 blocked).  
**Sources:** [provability-gaps.md](../verification/provability-gaps.md), [algorithms-and-libraries-plan.md §5](algorithms-and-libraries-plan.md#5-lic-maturity--gate-before-large-scale-libraries).  
**Assessed:** 2026-05-26 · branch `cursor/wave-a-stdlib-unblock` · integration **WA-P6** · repo `/home/s4il0r/Documents/Cursor/li-langverse/lic`

**Wave A exit (strict):** **G-lean**, **G-vc**, **G-par**, **G-math** all **Done** (not Partial); `lic build` fails on open VCs by default; tier-1 pure-Li math ≤1.2× C++ (`LI_TIER1_PERF_STRICT=1`); phase **8a** workspace smoke green.

---

## Gap register (G-*)

| Gap | Required status | Actual | Gate evidence |
|-----|-----------------|--------|---------------|
| **G-lean** | Done | **Partial** | `glean_strict_build_smoke` + `autovc_lake_typecheck` pass; **P-float** `sqrt_open_bound` closed; default gate not universal on all packages |
| **G-vc** | Done | **Partial** | **P-float** `sqrt_open_bound` discharged (`Li.Discharge` + trusted libm); other float / opaque ensures open |
| **G-par** | Done | **Partial** | `race_shared_memory` 7/7; **closed slice:** `_par*` policy witnesses (`discharge_par_parallel_lean.sh`); iteration-independence specs open |
| **G-math** | Done | **Partial** | Tier-1 advisory ok on `simd_dot` / `matmul_naive`; **strict** fails on `matmul_blocked`, `horner_pure_li` |

**Verdict:** Wave A **not closed**. Do not scale stdlib ADT runtime (list/dict) until G-* rows are **Done**.

---

## Assessment gates (WA-1 … WA-8)

| ID | Item | Command | Status | Output summary |
|----|------|---------|--------|----------------|
| **WA-1** | Contract discharge corpus | `./li-tests/tooling/contracts_discharge_corpus.sh` (after `cmake --build build`) | **Partial** | Discharge smokes + par scripts pass in isolation; full corpus **exit 1** in WA-P6 run (sqrt step after long corpus — `lic build` open VC); **sqrt alone: exit 0** + `check-autovc-open-goals: ok` |
| **WA-2** | AutoVC open goals (quiet sqrt) | `lic build li-tests/contracts_verify/sqrt_open_bound.li` then `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **Pass** | `vc_sqrt_open_ensures_0_proved` via `Li.Discharge.sqrt_open_bound_spec_proved`; **exit 0** / **exit 0** |
| **WA-3** | Tier-1 perf (advisory) | `./scripts/check-tier1-li-vs-cpp.sh` | **Partial** | OK `simd_dot` 0.935×, `matmul_naive` 0.900×; GAP `matmul_blocked` 1.763×, `horner_pure_li` 8.600×; **exit 0** |
| **WA-4** | Tier-1 perf (strict ≤1.2×) | `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` | **Fail** | `FAIL strict mode (2 bench(es) > 1.2× C++)`; **exit 1** |
| **WA-5** | Compiler + Studio plan gates | `./scripts/compiler-studio-plan-gates.sh` | **Fail** | Reaches tier-0 bench; **exit 1** — `li-tests` **207 pass / 8 fail** (`sqrt_open_bound`, linalg float closed, bytes smoke, physics golden, encapsulation open, …) |
| **WA-6** | G-lean smoke | `./li-tests/tooling/glean_strict_build_smoke.sh` | **Pass** | **exit 0** |
| **WA-7** | G-lean lake typecheck | `./li-tests/tooling/autovc_lake_typecheck.sh` | **Pass** | **exit 0** |
| **WA-8** | Workspace 8a build | `./scripts/lic-workspace-build.sh` | **Pass** | All members with smoke/`lib.li` entrypoints; **exit 0** (incl. `li-sim-scientific` smoke) |

### `lic build` open-VC policy (default)

```text
$ lic build li-tests/contracts_verify/sqrt_open_bound.li
# exit 0 — lake + AutoVC typecheck
$ ./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean
check-autovc-open-goals: ok (no open Prop goals)
```

`--allow-open-vc` remains CLI-only (env bypass removed). Policy **not** weakened.

---

## Recommended next PRs (Wave A closure)

1. ~~**P-float / `sqrt_open_bound`**~~ — Done in WA-P1 (`cursor/wa-p1-pfloat`).
2. ~~**G-par policy slice**~~ — Done in WA-P5 (`cursor/wa-p5-gpar-lean`); iteration-independence still open.
3. ~~**Workspace 8a smoke (`li-sim-scientific`)**~~ — Done in WA-P4 (`cursor/wa-p4-workspace-8a`).
4. **Tier-1 perf (7e)** — `matmul_blocked` + `horner_pure_li` until `LI_TIER1_PERF_STRICT=1` green; **G-math** → Done; WA-4 → Pass.
5. **Tier-0 / manifest hygiene** — Fix 8 failing `li-tests` rows blocking WA-5.
6. **G-par iteration independence (7d-c)** — Lean specs beyond policy witnesses; **G-par** → Done.
7. **Default `lic build` certificate** — No open VCs on shipped workspace paths; **G-lean** → Done.
8. **Corpus robustness** — `rm -rf build/generated` between specimens if `AutoVC.lean` cross-contamination recurs.

**Out of scope this session:** list/dict runtime (WP1), domain lib scale-up.

---

## Session notes (WA-P6)

- Merged `wa-p1-pfloat`, `wa-p5-gpar-lean` (conflict resolve in `vc_emit_lean.cpp`), `wa-p4-workspace-8a`; skipped `wa-p2` / `wa-p3` (even with base).
- Rebuilt compiler (`cmake --build build`) before assessment — required for P-float discharge in `lic`.
- Release note: [2026-05-26-wave-a-wa-p6-integration.md](../release-notes/2026-05-26-wave-a-wa-p6-integration.md).
