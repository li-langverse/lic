# PH-02 phase-02-typechecker exit gate reconciliation (#470)

> **Issue:** [#470](https://github.com/li-langverse/lic/issues/470) · **Repo:** li-langverse/lic  
> **Vision:** **Provable** (honest type/borrow gates), **Secure** (reject ill-typed programs by default)  
> **Learned from:** [phase-02-typechecker plan](2026-05-14-phase-02-typechecker.md), [master plan §2d](2026-05-14-li-master-plan.md), [plan-checkbox audit wave](../release-notes/2026-05-25-plan-checkbox-audit-wave.md), [benchmarks audit filters](https://github.com/li-langverse/benchmarks/blob/main/docs/release-notes/2026-05-25-plan-completion-audit-filters.md)

## Goal

Close the **master-plan-gap** between `plan-completion-audit.py` and the Phase **2d** tracker by ensuring the three **exit-gate** checkboxes in `2026-05-14-phase-02-typechecker.md` reflect shipped `li-tests` evidence. This is a **docs-only** reconciliation — no compiler changes unless manifest `expected_substr` drift is discovered.

## Non-goals

- Re-opening Phase 2 implementation tasks (Tasks 1–5) — those are `stale_spec_checklists` when phases **2a–2d** are `[x]` per benchmarks audit filters.
- Weakening type/borrow diagnostics to match stale plan wording.
- Editing `trusted.lean` or provability gap rows (**G-vc**, **G-bnd**, **G-def**, **G-math-syn** stay as documented).

## Dependencies

- **PH-02** / master-plan Phase **2d** — Borrow + effects (`[x]` at tracker line ~443).
- **benchmarks** `plan-completion-audit.py` — reads `LIC_ROOT/docs/superpowers/plans/`; CI must checkout **lic** ([benchmarks#20](https://github.com/li-langverse/benchmarks/issues/20)).
- Prior checkbox wave: [2026-05-25-plan-checkbox-audit-wave.md](../release-notes/2026-05-25-plan-checkbox-audit-wave.md).

## Current state (planner scan 2026-06-07)

| Gate | Sub-plan line | Manifest evidence | Planner read |
|------|---------------|-------------------|--------------|
| `fib.li` typechecks | `Phase 2 exit gate` → `[x]` | `li-tests/manifest.toml` → `typecheck/fib.li` (`verify_ok`), `lexer_parser/fib.li` | Box already checked on **main** |
| All `bad_*.li` fail with expected errors | `[x]` | `bad_array_index.li` (`out of range`), `bad_numeric_mix.li` / `bad_int_float_add.li` (`float` / `int`) | Box already checked on **main** |
| Borrow double-mut fails cleanly | `[x]` | `borrow/double_mut.li` (`expected_substr = borrow`) | Box already checked on **main** |

With `LIC_ROOT` pointing at lic **main**, `plan-completion-audit.py` reports **0** actionable `plan_files_open` rows for `phase-02-typechecker.md` (exit gates satisfied; implementation-task bullets classified as `stale_spec_checklists` when phases 2a–2d complete).

## Sub-phases

| Sub | Deliverable | Exit gate |
|-----|-------------|-----------|
| A | **Re-read** `2026-05-14-phase-02-typechecker.md` § exit gate — confirm three boxes `[x]` with `li-tests/…` path cites | All three `[x]` with path suffixes |
| B | **Run manifest suites** — `typecheck`, `borrow` (and spot-check `lexer_parser/fib.li`) | All PASS under `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh <suite>` |
| C | **Run cross-repo audit** — `LIC_ROOT=$PWD python3 ../benchmarks/scripts/plan-completion-audit.py` | `plan_files_open` has no `phase-02-typechecker` exit-gate rows |
| D | **Drift doc** — if B fails, update manifest `expected_substr` *or* fix diagnostic text; re-run B | Issue comment explains drift; only then touch compiler |
| E | **Close #470** — when A–C green; link this plan + audit JSON path | Issue closed; `master-plan-gap` removed |

## Tests / benches

| Suite | File | `manifest.toml` outcome | `expected_substr` |
|-------|------|-------------------------|-------------------|
| `typecheck` | `typecheck/fib.li` | `verify_ok` | — |
| `typecheck` | `typecheck/bad_array_index.li` | `compile_fail` | `out of range` |
| `typecheck` | `typecheck/bad_numeric_mix.li` | `compile_fail` | `float` |
| `typecheck` | `typecheck/bad_int_float_add.li` | `compile_fail` | `int` |
| `borrow` | `borrow/double_mut.li` | `compile_fail` | `borrow` |
| `lexer_parser` | `lexer_parser/fib.li` | (parse smoke) | — |

**REQ mapping:** type rejection gates underpin **REQ-TYPE-1** (static ill-typed program rejection) — cite manifest rows in PR body, not new REQ ids.

## Provability

| Gap | Move | Notes |
|-----|------|-------|
| **G-vc** | No change | Contracts/refinements are Phase **2e** |
| **G-bnd** | No change | Bounds proofs partial beyond literal indices |
| **G-def** | No change | Default/init rules separate track |
| **G-math-syn** | No change | Operator surface is Phase **2h** |

Exit-gate closure claims **typecheck + borrow lexical v1** only — aligned with proof-before-perf pillar order.

## Rollout

1. Merge this plan PR (draft → ready for review).
2. **Implementer** (`code_implementer` after `plan-approved`): run sub-phases A–C; if already green, single verification PR or close with audit cite only.
3. Optional **benchmarks** follow-up: ensure CI sets `LIC_ROOT` so org audit digests stop filing stale #470-class issues.
4. Release note path: `docs/release-notes/2026-06-07-ph02-exit-gates-470.md` (implementer adds on close).

## Human-only

- [ ] Label **`plan-approved`** on #470 before implementer runs sub-phase D (compiler/diagnostic edits).
- [ ] Maintainer merge of this docs PR (agents do not self-merge).
