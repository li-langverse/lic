# Release notes: P-float corpus gate + #185 dedupe (gap2-proof)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**Branch:** feat/gap2-proof  
**PH / REQ:** PH-2f, P-float, G-test-verify (#185)  
**Author:** agent

---

## Summary (one sentence)

Wires **P-float** `sqrt_open_bound` into `contracts_discharge_corpus.sh` via `discharge_sqrt_open_lean.sh` and dedupes **#185** / G-test-verify follow-up work (stale “intentionally open” corpus check removed).

## Agent continuation (required)

1. Read: `docs/semantics/Discharge.lean` (`sqrt_open_bound_spec_proved`); `li-tests/tooling/discharge_sqrt_open_lean.sh`.
2. Run: `LI_REPO_ROOT=$PWD ./li-tests/tooling/contracts_discharge_corpus.sh` and `./li-tests/run_all.sh contracts_verify`.
3. Then: **P-refine** guarded call-sites (`refinement_guard_ok`, open PR **#266**).
4. Blocked on: **#185** is **Done** — do not re-implement `prove_lean_ok` manifest split.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-tests/tooling/contracts_discharge_corpus.sh` | Run `discharge_sqrt_open_lean.sh`; drop stale “expect open sqrt” check | P-float closed on `main` |
| `docs/verification/proof-corpus-roadmap.md` | `sqrt_open_bound` + corpus rows | Corpus honesty |
| `CHANGELOG.md` | **#185** dedupe entry | Agent hygiene |

## Not changed (scope fence)

- **G-test-verify** `prove_lean_ok` machinery — already Done (**#185**).
- **P-refine** VC emit — **#266** / follow-up.
- **compiler/** C++ — no emit changes.
- **lip** / **lit** / **li-cursor-agents**.

## Breaking changes

None.

## Security

N/A.

## Performance

N/A.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |
