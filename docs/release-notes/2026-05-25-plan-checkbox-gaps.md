# Plan checkbox gaps — evidence-backed closes

## Summary

Close **17** stale sub-plan exit-gate checkboxes in `lic` where implementation already exists; add parser fuzz seeds for decorator stacks; document **9** remaining open gates with reasons (perf dashboard, plots pipeline, mkdocs rename, P-linalg loop Lean).

## Agent continuation

1. **Read** `benchmarks/data/latest/plan-completion-audit.json` after merge; `docs/superpowers/plans/2026-05-14-plots-and-social.md` open rows.
2. **Run** `cd benchmarks && LIC_ROOT=../lic python3 scripts/plan-completion-audit.py`; locally `./scripts/plot_shareables.sh` when closing plot gates.
3. **Then** Tier-2 MD driver decorators or tier-0 plot wiring in a focused PR; do not mark perf/P-linalg loop gates `[x]` without bench/Lean evidence.
4. **Blocked on** human mkdocs/GitHub Pages rename `li-language` → `lic` for governance mkdocs gate.

## Changed

| Area | Evidence |
|------|----------|
| Phase 2 exit gate | `li-tests/manifest.toml` typecheck + borrow rows |
| Governance / Pkg exit gates | `official-packages.md`, `check-traceability.sh`, `li_new_package_smoke.sh`, skills |
| Phase 7d fuzz | `compiler/fuzz/corpus/seed_decorator_stack`, `seed_reserved_typosquat` |
| Plan honesty | `**Open:**` notes on perf, plots, P-linalg loop, Tier-2 MD decorators |
| Audit | `plan-completion-audit.py` before **26** → after **9** open plan checkboxes |

## Not changed

- Master plan tracker partial rows (2i, 7d, 7e, 8p, Vision-LLM) — still `[ ]` by design.
- `docs/verification/provability-gaps.md` **G-*** Partial/Missing rows.
- Tetris phase-05 implementation tasks (phase 5 not complete in tracker).
- `benchmarks` catalog path gaps (`tier0_stability`, `rate_limit_429`).

## Breaking

N/A — documentation and fuzz corpus seeds only.

## Security

N/A — fuzz seeds are parse-only corpus inputs; no trusted.lean change.

## Performance

N/A — tier-1 ≤1.2× gate left open with dashboard reference.

## Downstream

Re-run `plan-completion-audit.py` in **benchmarks** CI or agent preflight after merge.
