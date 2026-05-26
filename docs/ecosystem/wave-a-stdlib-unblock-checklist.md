# Wave A stdlib unblock checklist (WP-WA)

**Program:** Li stdlib ADT — close strict Wave A before list/dict runtime (WP1 blocked).  
**Sources:** [provability-gaps.md](../verification/provability-gaps.md), [algorithms-and-libraries-plan.md §5](algorithms-and-libraries-plan.md#5-lic-maturity--gate-before-large-scale-libraries).  
**Assessed:** 2026-05-26 · branch `cursor/wp-lic-01-verticals-toml` · **WP-LIC-02/03** · repo `/home/s4il0r/Documents/Cursor/li-langverse/lic`

**Wave A exit (strict):** **G-lean**, **G-vc**, **G-par**, **G-math** all **Done** (not Partial); `lic build` fails on open VCs by default; tier-1 pure-Li math ≤1.2× C++ (`LI_TIER1_PERF_STRICT=1`); phase **8a** workspace smoke green.

---

## Gap register (G-*)

| Gap | Required status | Actual | Gate evidence |
|-----|-----------------|--------|---------------|
| **G-lean** | Done | **Partial** | `glean_strict_build_smoke` + `autovc_lake_typecheck` pass; **P-float** `sqrt_open_bound` closed (`Li.Trusted` + `Li.Discharge`); default gate not universal on all packages |
| **G-vc** | Done | **Partial** | **P-float** `sqrt_open_bound` discharged; other float / opaque ensures open |
| **G-par** | Done | **Partial** | `race_shared_memory` 7/7; **closed slice:** `_par*` policy witnesses; iteration-independence specs open |
| **G-math** | Done | **Partial** | **Strict tier-1 slice closed (WP-LIC-02):** `LI_TIER1_PERF_STRICT=1` green on all four pure-Li math benches |

**Verdict:** Wave A **not closed**. Do not scale stdlib ADT runtime (list/dict) until G-* rows are **Done** and WA-5 tier-0 is green.

---

## Assessment gates (WA-1 … WA-8)

| ID | Item | Command | Status | Output summary |
|----|------|---------|--------|----------------|
| **WA-1** | Contract discharge corpus | `./li-tests/tooling/contracts_discharge_corpus.sh` (after `cmake --build build`) | **Pass** | `AutoVcFileLock` in `lic` + corpus `rm` stale `AutoVC.lean`; **exit 0** when run in isolation |
| **WA-2** | AutoVC open goals (quiet sqrt) | `lic build li-tests/contracts_verify/sqrt_open_bound.li` then `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **Pass** (WP-LIC-03) | `vc_sqrt_open_ensures_0_proved` via `Li.Discharge.sqrt_open_bound_spec` |
| **WA-3** | Tier-1 perf (advisory) | `./scripts/check-tier1-li-vs-cpp.sh` | **Pass** | All four pure-Li math benches ≤1.2× C++; **exit 0** |
| **WA-4** | Tier-1 perf (strict ≤1.2×) | `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` | **Pass** | **exit 0** (WP-LIC-02) |
| **WA-5** | Compiler + Studio plan gates | `./scripts/compiler-studio-plan-gates.sh` | **Partial** | WP-LIC-03 in progress — tier-1 verify + Lean smokes pass; tier-0 `run_all` failures being closed |
| **WA-6** | G-lean smoke | `./li-tests/tooling/glean_strict_build_smoke.sh` | **Pass** | **exit 0** |
| **WA-7** | G-lean lake typecheck | `./li-tests/tooling/autovc_lake_typecheck.sh` | **Pass** | **exit 0** |
| **WA-8** | Workspace 8a build | `./scripts/lic-workspace-build.sh` | **Pass** | All members with smoke/`lib.li` entrypoints; **exit 0** |


### `lic build` open-VC policy (default)

```text
$ lic build li-tests/contracts_verify/sqrt_open_bound.li
build ok → build/generated/AutoVC.lean has vc_sqrt_open_ensures_0_proved
$ ./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean
check-autovc-open-goals: ok (no open Prop goals)
```

`--allow-open-vc` remains CLI-only (env bypass removed). Policy **not** weakened.

---

## Recommended next PRs (Wave A closure)

1. ~~**P-float / `sqrt_open_bound`**~~ — Done (WP-LIC-03 cherry-pick from WA-P1).
2. ~~**G-par policy slice**~~ — Done in WA-P5; iteration-independence still open.
3. ~~**Workspace 8a smoke (`li-sim-scientific`)**~~ — Done in WA-P4.
4. ~~**Tier-1 perf (7e)**~~ — **Done (WP-LIC-02)**; WA-4 **Pass**.
5. **Tier-0 / manifest hygiene** — WP-LIC-03: composable imports, advisory check cache, physics golden; **WA-5** → Pass.
6. **G-par iteration independence (7d-c)** — Lean specs beyond policy witnesses; **G-par** → Done.
7. **Default `lic build` certificate** — No open VCs on shipped workspace paths; **G-lean** → Done.


**Out of scope this session:** list/dict runtime (WP1), domain lib scale-up.

---

## Session notes (WP-LIC-02 / WP-LIC-03, 2026-05-26)

- Ported tier-1 codegen from `cursor/fix-wave-a-and-swarm-9031` (no full 61-commit studio merge): `ArrayMatMulBlocked2DF64`, `HornerConstLoopF64`, `matmul_blocked/li` `mm_blocked_512` hook (BK=16 for ≤1.2× strict).
- Horner: `x=0.999999` in C/Li/params + harness verify guards (`bench.py` native timing floor).
- **WA-4:** `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` → **exit 0**.
- **WA-5:** `./scripts/compiler-studio-plan-gates.sh` → holds on `bench tier 0` (`run_all` 18 failures); tier-1 verify and math suites green.
