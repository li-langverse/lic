# Release notes: 2026-05-25 — gap-close-checkbox tier0 plot

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/gap-close-checkbox  
**PH / REQ:** Phase 5b plotting slice (plan checkbox)  
**Author:** agent

---

## Summary (one sentence)

Wire `bench.py --tier 0` to emit `benchmarks/results/share/correctness_tier0.png` after `verify.py` writes `verify.csv`, resolve `verify.py` merge-marker corruption on `main`, and mark the plots-plan exit gate `[x]` with a harness contract test.

## Agent continuation (required)

1. Read: `benchmarks/data/latest/plan-completion-audit.json` (`LIC_ROOT` = lic); `docs/superpowers/plans/2026-05-14-plots-and-social.md` remaining open rows.
2. Run: `cd lic/benchmarks/harness && python3 -m unittest test_harness_contract.py`; with `lic` built, `python3 benchmarks/harness/bench.py --tier 0`.
3. Then: close plot gates needing `./scripts/plot_shareables.sh` or README link to `results/share/`; Tetris sub-plan rows remain (6 suppressed + board/rotate/soak).
4. Blocked on: human merge; #184 doc-only wave already merged — not repeated.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Harness | `emit_tier0_correctness_plot()` after `run_verify()` on `--tier 0` | `test_harness_contract.py::test_bench_tier0_pipeline_order` |
| Harness | Remove `<<<<<<<` conflict markers in `verify.py` docstring | `python3 benchmarks/harness/verify.py` parses |
| Plans | Plots exit gate `bench.py --tier 0` → `[x]` | `docs/superpowers/plans/2026-05-14-plots-and-social.md` |
| Audit honesty | **7** `open_plan_checkboxes` (was 8); **6** Tetris rows suppressed; **5** partial master tracker rows | `plan-completion-audit.py` |

## Not changed (scope fence)

- `./scripts/plot_shareables.sh` PNG set, 16:9 theme, README `results/share/` link — still `[ ]`.
- `examples/tetris/` rotate, `board.li`, 10-minute soak — unchanged.
- Tier-1 ≤1.2×, Tier-2 MD decorators, mkdocs rename — open per audit.
- `docs/verification/provability-gaps.md` — not edited.

## Breaking changes

None.

## Security

N/A — harness plotting only.

## Performance

N/A — one PNG on tier-0 runs.

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Re-run `plan-completion-audit.py` after merge |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Changed
- Plan checkbox (plots): `bench.py --tier 0` emits `correctness_tier0.png` after verify CSV — [2026-05-25-gap-close-checkbox-tier0-plot.md](docs/release-notes/2026-05-25-gap-close-checkbox-tier0-plot.md)
```
