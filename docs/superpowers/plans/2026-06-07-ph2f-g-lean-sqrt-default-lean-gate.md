# PH-2f / G-lean: close `sqrt_open_bound`; default Lean gate on `lic build`

> **Issue:** [#17](https://github.com/li-langverse/lic/issues/17) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** first — `lic build` must be an honest proof-certificate path; no drift between tracker, gap register, and corpus  
> **North star fit:** compiler verification, scientific computing — **PH-2f**, **G-lean**, **G-vc**  
> **Umbrella:** [#32](https://github.com/li-langverse/lic/issues/32) sub-phases **B** (sqrt story) + **C** (strict gate) — this issue is the **2f/G-lean slice only**  
> **Learned from:** [master plan §2f](2026-05-14-li-master-plan.md), [provability-gaps §G-lean](../../verification/provability-gaps.md), [proof-corpus-roadmap](../../verification/proof-corpus-roadmap.md), [strict-by-default](../../ecosystem/strict-by-default.md)

## Goal

Reconcile the **`sqrt_open_bound`** float `abs` VC story and document the **default Lean gate** on `lic build` so Phase **2f**, **G-lean**, and **G-vc** rows cite the same evidence. Close the drift where `Discharge.lean` already proves `sqrt_open_bound_spec` via a trusted libm axiom while the manifest still lists `verify_open_ok` and the master plan calls the specimen **intentional open**.

Define auditable **Tier A / B / C** exit gates for the Lean pipeline (open-VC count, default `lake build AutoVC`, opt-in `--strict-lean`) aligned with [strict-by-default](../../ecosystem/strict-by-default.md). **Blocks** Phase H M1 `.li` P0-lean per [httpd-prerequisites](../../ecosystem/httpd-prerequisites.md).

## Problem (evidence drift)

| Source | Claim today | Drift |
|--------|-------------|-------|
| `Discharge.lean` | `sqrt_open_bound_spec_proved` via `Li.TrustedMath.li_rt_sqrt_bound` | Lean lemma exists; manifest still `verify_open_ok` |
| `proof-corpus-roadmap.md` L30 | `sqrt_open_bound.li` **Closed** | `contracts_discharge_corpus.sh` L81 still says **intentionally open** |
| `provability-gaps.md` summary L36 | **Closed slice** via `Li.Discharge` | Gap-register table L85: **intentional open** |
| Master plan ~L455 | 2f **partial**; `sqrt_open_bound` **intentional open** | Contradicts proof-corpus **Closed** row |
| `manifest.toml` | `outcome = "verify_open_ok"` | Contrast: 14× `prove_lean_ok` closed specimens |
| Issue digest | `--strict-lean` not default on `lic build` | **Misleading:** Tier B Lean (`lake build AutoVC`) **is** default; only `--check-open-goals` strict pass is opt-in |

**Root cause:** `sqrt_open_bound` was kept as an open-VC **control specimen** (`BUG-C-12` / `vec3_len` contrast) after `Discharge.lean` gained a trusted discharge. Docs, manifest, and corpus scripts were not updated in one PR.

## Non-goals

- Marking **G-lean** **Done** — universal Lean kernel discharge remains research (**G-meta**).
- Default `--strict-lean` on every `lic build` — Tier C stays opt-in; Tier A+B are the default certificate path.
- Editing `trusted.lean` / `Li.TrustedMath` axioms without a **human-approved** issue (swarm mandate).
- Conflating this slice with **#16** (full tracker reconciliation) or **#21** (2e / G-vc Tier B/C witnesses).
- Weakening `threshold_ratio_cpp` or benchmark gates.
- Implementing compiler product code in the **plan** PR (docs-only).

## Dependencies

| ID | Relationship |
|----|--------------|
| **PH-2f** | Lean 4 verify on `lic build` — master plan line ~387 |
| **G-lean** | Canonical Lean gate row |
| **G-vc** | Float `abs` VC emission — `sqrt_open_bound` is **P-float** slice |
| **G-test-verify** | Manifest honesty — `prove_lean_ok` vs `verify_open_ok` |
| **G-hw** | FP/hardware axiomatic limit — `li_rt_sqrt_bound` is trusted, not IEEE-derived |
| **P-float** | Float `abs` / sqrt error bounds backlog |
| **#32** | Umbrella Lean/VC evidence — close #17 when B+C exit gates land |
| **#16** | Broader PH-row reconciliation — out of scope for this slice |
| **#21** | 2e / G-vc contracts — sibling track |
| Phase H **P0-lean** | Downstream consumer — needs honest 2f gate story |

## Default Lean gate model (Tier A / B / C)

| Tier | Behavior | Default? | Opt-out | Evidence |
|------|----------|----------|---------|----------|
| **A — Open VC count** | `lic build` fails when `count_open_autovc_goals() > 0` | **Yes** | `--allow-open-vc` (CLI only; env bypass removed) | `compiler/lic/main.cpp` ~L636–646; `check-autovc-open-goals.sh` |
| **B — Lean typecheck** | `lake build` + `lake build AutoVC Discharge` when `lake` installed | **Yes** | `--no-lean-verify` (documented downgrade) | `scripts/lean-verify-stub.sh`; `run_all.sh` `prove_lean_ok` |
| **C — Strict open goals** | `lean-verify-stub.sh --check-open-goals` after Tier B | **No** — requires `--strict-lean` | N/A | `compiler/lic/main.cpp` ~L591–592, ~L649; `lic verify --strict-lean` |

**Policy alignment:** [strict-by-default](../../ecosystem/strict-by-default.md) — proof is always on; Tier B skip and `--allow-open-vc` are **explicit downgrades**, not silent defaults.

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| **A** | **Evidence audit** — run corpus on `sqrt_open_bound`; capture AutoVC open vs discharged state | `./li-tests/tooling/contracts_discharge_corpus.sh` green; `./scripts/check-autovc-open-goals.sh` result recorded in issue comment |
| **B** | **`sqrt_open_bound` reconciliation** — if `Discharge.sqrt_open_bound_spec_proved` discharges under normal `lic build`, promote manifest to `prove_lean_ok`; else document **trusted closed slice** with `verify_open_ok` retained as regression control | `manifest.toml`, `proof-corpus-roadmap.md` L30, `contracts_discharge_corpus.sh` L81 **agree**; `provability-gaps.md` summary + register row **agree** |
| **C** | **Tier A/B/C doc sync** — add subsection to `provability-gaps.md` “`lic build` today”; cross-link `strict-by-default.md` | `./scripts/check-doc-provability-claims.sh` green |
| **D** | **Master plan Phase 2f** — update checkbox ~L455: cite Tier model + sqrt status; link this plan | Tracker text names Tier A/B default + Tier C opt-in |
| **E** | **proof-db evidence** — update `proof-db/lemmas/G-lean-autovc-strict.toml` paths + `proof_status` when Tier C story is documented | `proof-db` row matches `check-autovc-open-goals.sh` + `scripts/ci.sh` |
| **F** | **httpd prerequisite honesty** — `httpd-prerequisites.md` P0-lean cites Tier B default + remaining **G-lean Partial** limit | No overclaim that kernel is universal certificate |

## Tests / verification (cite in every closure PR)

| Check | Command / artifact | Role |
|-------|-------------------|------|
| Open VC control | `li-tests/contracts_verify/sqrt_open_bound.li` | **P-float** specimen |
| Manifest outcome | `li-tests/manifest.toml` (`prove_lean_ok` or documented `verify_open_ok`) | **G-test-verify** |
| Discharge corpus | `./li-tests/tooling/contracts_discharge_corpus.sh` | **G-lean**, **G-vc** |
| Open-goal inventory | `./scripts/check-autovc-open-goals.sh build/generated/AutoVC.lean` | **G-lean** Tier A |
| Closed specimens | `./li-tests/run_all.sh contracts_verify` | 14× `prove_lean_ok` baseline |
| Lean discharge lemma | `docs/semantics/Discharge.lean` — `sqrt_open_bound_spec_proved` | **P-float** trusted slice |
| VC witness telemetry | `./li-tests/tooling/mir_vc_witness.sh` | **G-vc** — `witnessed_ensures=` |
| Default build gate | `lic build` without flags on `greeter.li` or closed specimen | Tier A+B |
| Strict probe | `lic build --strict-lean` on specimen with known open goal | Tier C fails as expected |
| Doc guard | `./scripts/check-doc-provability-claims.sh` | Doc-c |

**Run (audit):**

```bash
LI_REPO_ROOT=$PWD ./li-tests/tooling/contracts_discharge_corpus.sh
LI_REPO_ROOT=$PWD ./li-tests/run_all.sh contracts_verify
```

## Provability mapping

| Gap / item | Move | Honest limit |
|------------|------|--------------|
| **G-lean** | **Partial** → **honest Partial** | Reconcile sqrt: **closed slice (trusted libm)** OR retain open control with aligned docs — not both |
| **G-vc** | **Partial** (sqrt slice) | Float `abs` bound discharged via `Li.TrustedMath.li_rt_sqrt_bound` (**G-hw** axiomatic) |
| **G-test-verify** | No regression | 14× `prove_lean_ok` stay green; sqrt promotion only if audit proves discharge |
| **PH-2f** | Tracker **partial** with evidence links | Not **Done** until universal kernel (**G-meta**) |
| **P-float** | Partial → **closed trusted slice** for sqrt | Other float ensures remain open |

Do **not** claim `lic build` = universal Lean certificate until **G-lean** row explicitly lists remaining open classes (`mat2_at2_eval`, opaque returns, loop ensures).

## Rollout

1. Merge this **plan** PR (draft → ready for review).
2. Maintainer adds **`plan-approved`** on **#17**; remove **`plan-needed`**.
3. **Implementation PR** (may include manifest + doc + minimal compiler wiring if audit finds AutoVC still emits open goal for sqrt):
   - Sub-phases A–F in one or two PRs.
   - Same PR must touch `provability-gaps.md` when gap status changes (engineering standard).
4. Post evidence matrix on **#17** after sub-phase A.
5. Reference **#32** umbrella; close **#17** when B+C+D exit gates pass (do not wait for full #32 H merge).
6. Unblock **Phase H M1** P0-lean narrative once Tier model is documented.

## Human-only

- [ ] Label **`plan-approved`** on **#17** before implementation agents run.
- [ ] Approve any `trusted.lean` / `Li.TrustedMath` axiom change if audit shows discharge gap.
- [ ] Decide: promote `sqrt_open_bound` to `prove_lean_ok` **or** keep as `verify_open_ok` control — plan requires **one** story, not both.
- [ ] Do not self-merge governance PRs.

## north_star_fit

**Domain:** compiler verification / proof certificate · **PH:** 2f · **G-***: G-lean, G-vc, G-test-verify · **Pillar:** Provability first — default Lean gate documented honestly; sqrt drift closed without weakening strict-by-default.
