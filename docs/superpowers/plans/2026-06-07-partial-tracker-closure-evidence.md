# Partial master-plan tracker closure evidence (PH-2e/2f/2i/7d/7e/H/Vision-LLM)

> **Issue:** [#25](https://github.com/li-langverse/lic/issues/25) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest G-* register) → **Easy** (agent-readable gates) → **Fast** (only after proof)  
> **north_star_fit:** compiler proof maturity · **PH-2e**, **PH-2f**, **PH-2i**, **PH-7d**, **PH-7e**, **PH-H**, Vision-LLM  
> **Learned from:** [master plan § compiler tasks vs proof gaps](2026-05-14-li-master-plan.md#compiler-tasks-vs-proof-gaps), [provability-gaps.md](../../verification/provability-gaps.md), [proof-corpus-roadmap.md](../../verification/proof-corpus-roadmap.md), [ph7e-tier1-red-benchmark-honesty](2026-05-30-ph7e-tier1-red-benchmark-honesty.md)

## Goal

Define **binding Definition of Done (DoD)** checklists for every **partial** master-plan tracker row cited in [#25](https://github.com/li-langverse/lic/issues/25). Agents and maintainers may **not** remove the “partial” qualifier, flip `[ ]` → `[x]`, or move a **G-*** row toward **Done** from narrative-only doc edits.

**Doc-c** (phase 02/03/07 exit-gate G-* links) is tracked separately in [#26](https://github.com/li-langverse/lic/issues/26).

## Non-goals

- Implementing compiler, httpd, or benchmark product code in the plan PR.
- Weakening `threshold_ratio_cpp` or catalog thresholds to green incomplete kernels.
- Marking **G-lean** / **G-vc** **Done** while intentional open VCs remain without `verify_open_ok` manifest rows.
- Editing `trusted.lean` (human-approved issues only).
- Closing **8p** (parallel compile) — out of scope for #25; see [2026-05-22-parallel-compile-ci.md](2026-05-22-parallel-compile-ci.md).

## Binding closure rule (all rows)

A tracker row may lose **partial** (or move from `[ ]` to `[x]` with no partial qualifier) **only** when **all** of the following hold in the **same PR**:

1. Every command in the row’s **Evidence gate** table exits 0 (or documented advisory skip when Lean/lake absent — same policy as `run_all.sh`).
2. Matching **G-*** row(s) in [provability-gaps.md](../../verification/provability-gaps.md) updated with one-line evidence (script path, suite name, CI job).
3. Master-plan tracker line edited with PR link — not prose-only.
4. No new forbidden overclaim phrases per `scripts/check-doc-provability-claims.sh`.

**Does not count as closure:** issue comments, audit JSON, dashboard screenshots without ingest, checkbox edits without green gates, or “closed slice” bullets that contradict `check-tier1-li-vs-cpp.sh` / `contracts_discharge_corpus.sh`.

---

## PH-2e — Contracts + refinements (**G-vc**)

**Tracker today:** `[x]` with **partial** — call-site `requires`, refinements, AutoVC emit; float/nontrivial `ensures` open.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | VC emit on every `lic build` | `lic build li-tests/modules/greeter/greeter.li -o /dev/null` → `build/generated/AutoVC.lean` exists |
| 2 | Negative call-site `requires` | `./li-tests/run_all.sh contracts_verify` — `caller_requires_fail.li` → **E0304** |
| 3 | Refinement reject | `refinement_call_fail.li` / `refinement_init_fail.li` → **E0305** |
| 4 | Weak ensures reject | `prove_reject/weak_ensures_true.li` → **E0303** |
| 5 | VC shape (not `True` stubs) | `./li-tests/tooling/vc_emit_contracts.sh` |
| 6 | Caller discharge corpus | `./li-tests/tooling/discharge_caller_requires_lean.sh`, `discharge_caller_requires_local_lean.sh` |
| 7 | Full corpus green | `./li-tests/tooling/contracts_discharge_corpus.sh` |
| 8 | Manifest honesty | `./li-tests/run_all.sh contracts_verify` — 0 fail |

### G-* promotion to **Done**

**G-vc** → **Done** only when:

- `./li-tests/tooling/contracts_verify_lean.sh` passes with lake installed (zero open Prop goals on closed corpus specimens).
- **P-float** backlog items (`sqrt_open_bound` excepted as `verify_open_ok`) discharged or explicitly listed as permanent **G-hw** axioms.
- `./li-tests/tooling/mir_vc_witness.sh` covers non-literal `ensures` witnesses for shipped specimens.

Until then: remain **Partial**; tracker keeps **partial** on 2e even if `[x]`.

---

## PH-2f — Lean 4 verify (**G-lean**, **G-vc**, **G-trust**)

**Tracker today:** `[x]` with **partial** — default `lake build AutoVC`; P-linalg closed corpus; **G-lean** / **G-vc** still open.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | Open-goal policy on build | `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` after `lic build` (no `--allow-open-vc` unless manifest says `verify_open_ok`) |
| 2 | P-linalg closed specimens | `./li-tests/tooling/discharge_linalg_int_lean.sh` |
| 3 | Trivial / const discharge | `./li-tests/tooling/discharge_trivial_lean.sh`, `discharge_const_lean.sh` |
| 4 | Strict lean smoke | `./li-tests/tooling/glean_strict_build_smoke.sh` (lake required) |
| 5 | AutoVC lake typecheck | `./li-tests/tooling/autovc_lake_typecheck.sh` |
| 6 | Manifest prove_lean_ok | `./li-tests/run_all.sh contracts_verify` — all `prove_lean_ok` rows pass or skip only when elan absent |
| 7 | Semantics package | `(cd docs/semantics && lake build)` |
| 8 | Core.lean not stub | `docs/semantics/Core.lean` + `MIR.lean` typing rules referenced in [semantics/README.md](../../semantics/README.md) — human review |

### G-* promotion

| Gap | **Done** requires |
|-----|-------------------|
| **G-lean** | Default `lic build` fails on any open Prop goal except manifest-allowlisted `verify_open_ok`; `./scripts/check-master-plan-gates.sh` semantics phase green |
| **G-vc** | Same as PH-2e **Done** |
| **G-trust** | `Core.lean` / `MIR.lean` carry real typing + contract rules; not placeholder modules |

**CI workflow names:** `scripts/ci.sh` (semantics + master-plan gates job), `li-tests/run_all.sh contracts_verify`.

---

## PH-2i — Math / linalg surface (**G-math**, **G-math-syn**)

**Tracker today:** `[ ]` **partial** — 2i-a/c landed; broadcast rank rules open; float `@` Props partially closed.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | Math linalg suite | `./li-tests/run_all.sh math_linalg` — 0 fail |
| 2 | Shape errors at typecheck | `math_linalg/broadcast_invalid_*.li`, `matmul_shape_*.li` → compile_fail with shape codes |
| 3 | Element-wise / reductions | `math_linalg/scalar_elementwise/`, `math_linalg/reductions/` green |
| 4 | Prelude dot/norm/axpy | `linalg_*_closed.li` in `contracts_verify/` with `prove_lean_ok` or documented open |
| 5 | Float `@` Props | `./li-tests/tooling/discharge_linalg_int_lean.sh` + float specimens in proof-corpus-roadmap |
| 6 | NumPy-rank broadcast | New `compile_fail` + positive specimens — **not** done until full rank rules land |
| 7 | Handbook honesty | [linear-algebra.md](../../language/linear-algebra.md) status note matches gaps |

### G-* promotion

**G-math** → **Done** for **2i** slice when typecheck rejects all documented shape errors and closed-shape `@`/`dot` specimens are `prove_lean_ok`. Full **G-math** (incl. tier-1 perf) also requires PH-7e gates below.

**G-math-syn** → **Done** when Python `range()` / dynamic bounds supported or explicitly deferred with open manifest rows.

**Flip tracker `[ ]` → `[x]` (no partial):** items 1–5 green **and** item 6 implemented **or** explicitly deferred to v2 with master-plan amendment.

---

## PH-7d — Execution decorators (**G-dec**, **G-par**)

**Tracker today:** `[ ]` **partial** — `@vectorized` on `for`; structured `disjoint=` and Lean **G-par** open.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | Exploit suite | `./li-tests/run_all.sh decorator_exploits` — all `compile_fail` |
| 2 | Decorator suite | `./li-tests/run_all.sh decorators` |
| 3 | MIR telemetry — vectorized | `./scripts/check-mir-vectorized-decorator.sh` |
| 4 | MIR telemetry — parallel | `./scripts/check-mir-parallel-decorator.sh` |
| 5 | MIR telemetry — gpu | `./scripts/check-mir-gpu-decorator.sh` |
| 6 | `@vectorized` scope | `vectorized_for_scope_ok.li` in manifest — `verify_ok` |
| 7 | Structured `disjoint=` | `./li-tests/run_all.sh race_shared_memory` — AST disjoint proofs, not only `policy.cpp` strings |
| 8 | Lean P-par | `./li-tests/tooling/discharge_*` for `_par*` specs — zero open goals on closed parallel specimens |
| 9 | No runtime decorator interp | Handbook + spec state elaboration-only |

### G-* promotion

| Gap | **Done** requires |
|-----|-------------------|
| **G-dec** | Elaboration to MIR for in-scope decorators; `decorator_exploits/` + `contracts_discharge_corpus.sh` green; **P-dec** closed or allowlisted |
| **G-par** | Structured `disjoint=` from AST; Lean iteration-independence proofs for closed parallel corpus |

**Flip tracker:** items 1–6 today maintain **partial**; **Done** requires 7–8.

---

## PH-7e — Math → SIMD / parallel lowering (**G-math** perf slice)

**Tracker today:** `[ ]` **partial** — loop matmul + FMA horner; tier-1 advisory ≤1.2×; red rows remain.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | Tier-1 advisory script | `./scripts/check-tier1-li-vs-cpp.sh` (default advisory) — documents gaps, no false “closed slice” |
| 2 | Strict tier-1 (when claiming perf Done) | `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` — all in-scope ids ≤1.2× |
| 3 | Li-tests perf hook | `./li-tests/tooling/tier1_li_vs_cpp.sh` |
| 4 | Pure-Li sources | Tier-1 Li bench sources contain **zero** user-facing `__li_simd_*` / `simd(...)` |
| 5 | Math lowering proofs | `./li-tests/tooling/discharge_linalg_int_lean.sh` for int paths; float Props per proof-corpus-roadmap |
| 6 | Master-plan gate bundle | `./scripts/check-master-plan-gates.sh` tier-1 phase (advisory warn OK; strict for Done) |
| 7 | Dashboard ingest | `benchmarks` nightly ingest — cited URL in PR when claiming bench closure |
| 8 | Red-row sub-plan | Follow [2026-05-30-ph7e-tier1-red-benchmark-honesty.md](2026-05-30-ph7e-tier1-red-benchmark-honesty.md) for `matmul_blocked`, ML trio, `num_gmres` |

### G-* promotion

**G-math** perf **closed slice** bullets in provability-gaps may name a bench id **only** when row 2 passes for that id (or sub-plan waiver with master-plan edit).

**Does not count:** lowering `threshold_ratio_cpp` in **benchmarks** catalog.

---

## PH-H — li-httpd (**G-net**, **G-async** partial; no single G-* Done)

**Tracker today:** two `[x]` rows — infra shipped; M1 `.li` **partial**.

### PH-H infra row (lis harness)

**Done (already claimed):** `lis` CI green — cite [implementation-status](https://github.com/li-langverse/lis/blob/main/docs/implementation-status.md).

### PH-H M1 `.li` row — Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | Config + routing oracle | `./li-tests/run_httpd_config.sh` |
| 2 | Routing Li binary | `./li-tests/run_routing.sh` |
| 3 | Httpd li-tests suite | `./li-tests/run_all.sh httpd` |
| 4 | P0 lean gate (budget) | `./scripts/check-httpd-lean-gate.sh` — open VC ≤ `HTTPD_LEAN_GATE_MAX_OPEN` (default 8) |
| 5 | Server modules lean | `./scripts/check-httpd-server-lean-gate.sh` when Li reactor ships |
| 6 | HTTP forward discharge | `./li-tests/tooling/discharge_http_forward_lean.sh` |
| 7 | M1 ship gate milestones | httpd plan `m0-ship-gate-full`, `m1-serve-production`, `m1-exploit-runtime` — green in `lis` + `lic` workspace |
| 8 | `packages/li-log` | build + tests in workspace CI |
| 9 | Li `net.httpd` lib | `lic build` on server packages **without** `--no-lean-verify` for ship claim |

### Remove **partial** from M1 row when

Items 1–4 are green **and** 5–7 satisfied **and** P0-lean in [httpd-prerequisites.md](../../ecosystem/httpd-prerequisites.md) no longer says “partial” for the cited gate.

**Cross-repo:** **lis** PR links required for runtime parity milestones.

---

## Vision-LLM — Agent JSON diagnostics (no **G-*** closure)

**Tracker today:** `[ ]` **partial** — JSON check/diagnose shipped; `lic edit --patch=json` spec-only.

### Definition of done

| # | Gate | Command / path |
|---|------|----------------|
| 1 | JSON diagnostics smoke | `./li-tests/tooling/diagnose_json_smoke.sh` |
| 2 | Schema stability | `docs/schemas/diagnostic-v1.json` validates sample output (`jq` in smoke) |
| 3 | Master-plan gate wiring | `./scripts/check-master-plan-gates.sh` includes diagnose_json_smoke |
| 4 | Agent manifest | `docs/ecosystem/li-agent-manifest.toml` matches CLI flags |
| 5 | Manifest export | `./scripts/export-li-tests-agent-slice.sh` → `li-tests/agent-manifest.json` in CI |
| 6 | Fix suggest stub | `./scripts/lic-fix-suggest.sh` accepts piped JSON (non-fatal in smoke) |
| 7 | Handover docs | [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md) lists schema + commands |
| 8 | `lic edit --patch=json` | Spec § implemented + li-tests — **required for full Done** |

### Flip tracker `[ ]` → `[x]` (no partial)

Items **1–7** green → may mark **partial → complete** for **v0 agent diagnostics** with spec note that edit-patch is v1.

Full **Vision-LLM** **Done** (no partial qualifier): item **8** shipped + Studio/MCP tools consume manifest without ad-hoc scripts.

**Explicit:** Vision-LLM **never** closes **G-lean** or any proof gap.

---

## Implementation plan (docs-only, post `plan-approved`)

| Step | Deliverable | Owner |
|------|-------------|-------|
| 1 | Land this plan (PR from #25) | issue_planner |
| 2 | Link from master plan § [v2 backlog](2026-05-14-li-master-plan.md#full-master-plan--not-complete-v2-backlog) | same PR |
| 3 | Update [plan-cross-links.md](../../ecosystem/plan-cross-links.md) index + open-tracker table | same PR |
| 4 | Per-row closure PRs cite relevant DoD table + run gates in CI log | implementer agents |
| 5 | Close #25 when all DoD sections reviewed by maintainer | human |

## Tests / CI summary

| Workflow / script | Rows covered |
|-------------------|--------------|
| `./scripts/check-master-plan-gates.sh` | 2e, 2f, 2i, 7d, 7e, Vision-LLM |
| `./scripts/ci.sh` | All (local-ci mirror) |
| `./li-tests/run_all.sh` suites | 2i, 7d, H, 2e/2f |
| `./scripts/check-tier1-li-vs-cpp.sh` | 7e |
| `./scripts/check-httpd-lean-gate.sh` | H |

## Human-only

- [ ] Label **`plan-approved`** on [#25](https://github.com/li-langverse/lic/issues/25) before implementers use DoD for checkbox flips.
- [ ] Maintainer ack that **partial** `[x]` rows (2e, 2f, H) require G-* **Done** before removing partial qualifier.
- [ ] Approve **`trusted.lean`** changes only via dedicated human issues.
- [ ] Merge this plan PR (draft → ready) after review.
