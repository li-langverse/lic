# Release notes: 2026-05-25 — fuzz-decorator-corpus-seeds

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (open on `feat/checkbox-impl-slice`)  
**PH / REQ:** PH-7d (execution decorators)  
**Author:** agent

---

## Summary (one sentence)

Committed parser-fuzz seeds for stacked `@` decorators and reserved/typosquat `decorator def` names, with a `lic parse` smoke script wired into `scripts/ci.sh`.

## Agent continuation (required)

1. Read: `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md` (7d exit gate); remaining open: Tier 2 MD `@` on `def`, Tier 1 perf advisory.
2. Run: `./li-tests/tooling/fuzz_decorator_corpus_seeds.sh`; `LIC_ROOT=../lic python3 ../benchmarks/scripts/plan-completion-audit.py`.
3. Then: Tier 2 `md_lennard_jones` decorator-on-`def` driver or tier-1 perf investigation — pick one checkbox per PR.
4. Blocked on: none for this slice.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Fuzz corpus | `seed_decorator_stack`, `seed_reserved_typosquat` | `compiler/fuzz/corpus/` |
| CI smoke | `fuzz_decorator_corpus_seeds.sh` | `scripts/ci.sh` phase |
| Plan | 7d fuzz checkbox `[x]` | `docs/superpowers/plans/2026-05-14-phase-07-native-hpc.md` |

- `compiler/fuzz/corpus/seed_decorator_stack` — `@cpu` + `@parallel` + `@vectorized` on `def`, scoped `@vectorized` on `for`.
- `compiler/fuzz/corpus/seed_reserved_typosquat` — `decorator def parallel` and `my_paralell` parse seeds.
- `li-tests/tooling/fuzz_decorator_corpus_seeds.sh` — requires three seeds; `lic parse` must not crash.

## Not changed (scope fence)

- Tier 2 MD driver decorator elaboration — not in this PR.
- Tier 1 perf ≤1.2× C++ — not in this PR.
- libFuzzer nightly corpus merge / new crashes — not in this PR.

## Breaking changes

None.

## Security

N/A — parse-only seeds; policy/typecheck failures are expected for some inputs; harness asserts no crash on `lic parse`.

## Performance

N/A.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis / packages | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **PH-7d:** Parser fuzz corpus seeds for decorator stacks and reserved/typosquat names; `fuzz_decorator_corpus_seeds.sh` in CI.
```
