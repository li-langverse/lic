# Wave A stdlib unblock checklist (WP-WA)

**Program:** Li stdlib ADT — close strict Wave A before list/dict runtime (WP1 blocked).  
**Sources:** [provability-gaps.md](../verification/provability-gaps.md), [algorithms-and-libraries-plan.md §5](algorithms-and-libraries-plan.md#5-lic-maturity--gate-before-large-scale-libraries).  
**Assessed:** 2026-05-26 · branch `cursor/wave-a-stdlib-unblock` · repo `/home/s4il0r/Documents/Cursor/li-langverse/lic`

**Wave A exit (strict):** **G-lean**, **G-vc**, **G-par**, **G-math** all **Done** (not Partial); `lic build` fails on open VCs by default; tier-1 pure-Li math ≤1.2× C++ (`LI_TIER1_PERF_STRICT=1`); phase **8a** workspace smoke green.

---

## Gap register (G-*)

| Gap | Required status | Actual | Gate evidence |
|-----|-----------------|--------|---------------|
| **G-lean** | Done | **Partial** | Corpus + `glean_strict_build_smoke` pass on closed specimens; default `lic build` rejects open VCs (`lic_exit=1` on `sqrt_open_bound`); workspace packages still have open goals |
| **G-vc** | Done | **Partial** | `contracts_discharge_corpus.sh` ok; intentional open `vc_sqrt_open_ensures_0` / P-float |
| **G-par** | Done | **Partial** | `race_shared_memory` 7/7; `_par*` Lean discharge (`discharge_par_parallel_lean.sh`); iteration-independence specs open |
| **G-math** | Done | **Partial** | Tier-1 checksum verify ok; **strict** perf: 2/4 benches over 1.2× (`matmul_blocked`, `horner_pure_li`) |

**Verdict:** Wave A **not closed**. Do not scale stdlib ADT runtime (list/dict) until G-* rows are **Done**.

---

## Assessment gates (WA-1 … WA-8)

| ID | Item | Command | Status | Output summary |
|----|------|---------|--------|----------------|
| **WA-1** | Contract discharge corpus | `./li-tests/tooling/contracts_discharge_corpus.sh` | **Pass** | All discharge scripts + lake ok; `sqrt_open_bound` keeps 1 open VC by design; ends `contracts_discharge_corpus: ok` (exit 0) |
| **WA-2** | AutoVC open goals (repo default) | `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **Fail** | `open VC: vc_sqrt_open_ensures_0`; `1 open obligation(s)` (exit 1) — expected until P-float closed |
| **WA-3** | Tier-1 perf (advisory) | `./scripts/check-tier1-li-vs-cpp.sh` | **Partial** | After `bench.py --tier 1`: OK `simd_dot` 1.059×, `matmul_naive` 0.905×; **GAP** `matmul_blocked` 1.886×, `horner_pure_li` 2.800×; advisory exit 0 |
| **WA-4** | Tier-1 perf (strict ≤1.2×) | `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` | **Fail** | `FAIL strict mode (2 bench(es) > 1.2× C++)` (exit 1) |
| **WA-5** | Compiler + Studio plan gates | `./scripts/compiler-studio-plan-gates.sh` | **Fail** | Through tier-1 verify + Lean smokes; **exit 1** at `bench tier 0` (`li-tests` 211 pass / **4 fail** in security/stdlib paths) |
| **WA-6** | G-lean smoke | `./li-tests/tooling/glean_strict_build_smoke.sh` | **Pass** | `check-autovc-open-goals: ok`; `glean_strict_build_smoke: ok` (exit 0) |
| **WA-7** | G-lean lake typecheck | `./li-tests/tooling/autovc_lake_typecheck.sh` | **Pass** | `autovc_lake_typecheck: ok` (exit 0) |
| **WA-8** | Workspace 8a build | `./scripts/lic-workspace-build.sh` | **Fail** | Smoke builds pass until `li-sim-scientific` `src/lib.li`: `14 proof obligation(s) still need a Lean proof` (exit 1) |

### `lic build` open-VC policy (default)

```text
$ lic build li-tests/contracts_verify/sqrt_open_bound.li
lic build: 1 proof obligation(s) still need a Lean proof (see build/generated/AutoVC.lean)
lic_exit=1
```

`--allow-open-vc` remains CLI-only (env bypass removed). Policy **not** weakened.

---

## Recommended next PRs (Wave A closure)

1. **P-float / `sqrt_open_bound`** — Close or narrow `vc_sqrt_open_ensures_0`; update provability-gaps **G-vc** → Done slice; WA-2 → Pass.
2. **Tier-1 perf (7e)** — Pure-Li `matmul_blocked` IKJ/blocked codegen + `horner_pure_li` FMA/unroll until `LI_TIER1_PERF_STRICT=1` green; **G-math** → Done; WA-4 → Pass.
3. **Workspace 8a proofs** — Proof-complete smokes for `li-sim-scientific` (and members using `src/lib.li` without smoke); WA-8 → Pass.
4. **G-par Lean** — AST policy is partial; add Lean discharge for `_par*` VCs; **G-par** → Done.
5. **Default `lic build` certificate** — Wire strict Lean on main user paths (no `--no-lean-verify` in CI smoke); align **G-lean** Done with “fails on any open VC” for shipped packages.
6. **Docs sync** — When a gap closes, same PR updates `provability-gaps.md` + this checklist.

**Out of scope this session:** list/dict runtime (WP1), domain lib scale-up.

---

## Session notes

- Ran `python3 benchmarks/harness/bench.py --tier 1` to refresh `benchmarks/results/latest.csv` before tier-1 assessment.
- Fixed `bench.py` `--verify-results --tier 1` fall-through (return 0 after tier-1 verify, mirroring tier 4).
