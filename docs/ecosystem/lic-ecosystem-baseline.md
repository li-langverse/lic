# Li ecosystem baseline — phase 0 (2026-05-22)

**Purpose:** Clean starting point for the **lic ecosystem gap loop** (scientific / engineering / gaming packages). **Out of scope:** li-httpd / webserver work (separate agent on `cursor/httpd-plan-loop-54aa`).

**Plan:** [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md) §7–§12 · **Proof honesty:** [provability-gaps.md](../verification/provability-gaps.md)

## Branch / PR target

| Item | Value |
|------|--------|
| Implementation branch | `cursor/lic-ecosystem-plan-loop-54aa` (from `main`) |
| Docs import | `algorithms-and-libraries-plan.md` from `cursor/httpd-plan-loop-goal-directed` (PR #172) — merged here for agents without waiting on httpd PR stack |
| Loop driver | `scripts/lic-ecosystem-plan-loop.py` (phase 1; not started until dry-run approved) |

## CI while GHA quota exhausted

- **Do not** treat missing GitHub checks as green.
- Run **`./scripts/local-ci.sh`** on this branch before merge (see skill `run-local-ci-gha-quota`).
- Record: `benchmarks/data/latest/local-ci-results.json` when validating a PR number.

## Stale / parallel work — do not conflate

| Track | Branch | Owner |
|-------|--------|--------|
| **httpd M1** | `cursor/httpd-plan-loop-54aa` (#173) | Webserver agent |
| **httpd loop infra** | `cursor/httpd-plan-loop-goal-directed` (#172) | Merge to `main` when ready |
| **Ecosystem gaps** | `cursor/lic-ecosystem-plan-loop-54aa` | This loop |

Do not edit `runtime/li_rt_httpd.c`, `scripts/httpd-plan-loop.py`, or httpd plan YAML on the ecosystem branch unless fixing a **shared** gate (build/CI only).

## Phase 0 checklist

- [x] `algorithms-and-libraries-plan.md` on ecosystem branch
- [x] This baseline doc
- [x] Agent skill `run-local-ci-gha-quota` in roadmap agent-kit (+ `li-local-ci`)
- [ ] Local CI green on `cursor/lic-ecosystem-plan-loop-54aa` (`./scripts/local-ci.sh`)
- **Devbox needs:** LLVM 22 (`scripts/ci-install-llvm.sh` or apt.llvm.org), Lean 4 (`scripts/ci-install-lean.sh`, `PATH="$HOME/.elan/bin:$PATH"`), codegen fix for LLVM 22 intrinsics (`getOrInsertDeclaration`)
- [ ] PR opened; human `merge-approved` after review
- [ ] Phase 1: `lic-ecosystem-plan-loop.py` + `data/lic-ecosystem-plan-loop/state.json`

## Default queue head (phase 1+)

Per §7.7 — first implementation slices after gates green:

1. **P0** Wave A slices (2e/2f) — bounded, no domain kernel scale-up
2. **P0** AL-11 — `li-math` quaternions + `Mat4`; wire `li-scene`
3. **P1** AL-10 — `packages/linalg` scaffold + `math_linalg` tests

## Agent continuation

1. Read §12 handoff in [algorithms-and-libraries-plan.md](algorithms-and-libraries-plan.md).
2. Skill **`run-local-ci-gha-quota`** — run local CI before claiming done.
3. Work only on **`cursor/lic-ecosystem-plan-loop-54aa`**; PR-only; no self-merge.
4. Skip httpd todos and httpd-only files.
