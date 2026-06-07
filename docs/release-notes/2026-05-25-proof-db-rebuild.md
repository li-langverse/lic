# Release notes: 2026-05-25 — proof-db rebuild pipeline

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (feat/proof-db-rebuild)  
**PH / REQ:** PH-2f (proof corpus)  
**Author:** agent

---

## Summary (one sentence)

Adds a brand-new `proof-db/` lemma inventory with `scripts/proof-db-rebuild.sh` that records per-lemma `proved|open_vc|compile_fail|lean_fail|discrepancy` status into versioned JSONL under `proof-db/results/`.

## Agent continuation (required)

1. Read: `proof-db/README.md`, `docs/verification/proof-corpus-roadmap.md` § proof database.
2. Run: `export LIC="$PWD/build/compiler/lic/lic"` then `./scripts/proof-db-rebuild.sh` and `tail proof-db/results/*.jsonl`.
3. Then: grow `proof-db/**/lemmas/` from `li-tests/contracts_verify/`; wire optional CI job when inventory exceeds math seed.
4. Blocked on: none.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `scripts/proof-db-rebuild.sh` | Walk `proof-db/**/lemmas/*.li`; `lic build` + `check-autovc-open-goals` logic + optional `--lake` | Local run: 3× `proved` on math seed |
| `proof-db/math/lemmas/*.li` | P-linalg seed specimens (dot, sum, loop dot) | Mirrors `contracts_verify` |
| `proof-db/README.md` | Operator docs, status table, JSONL schema | — |
| `docs/verification/proof-corpus-roadmap.md` | Link to proof-db rebuild | — |

## Not changed (scope fence)

- `lic` compiler VC emit / Lean kernel — **not** modified.
- `li-tests/run_all.sh` manifest — **not** wired to proof-db yet.
- Benchmarks / LLVM / httpd — **not** touched.

## Breaking changes

None.

## Security

N/A — read-only rebuild over local lemma files; no new trusted axioms.

## Performance

N/A — three-lemma local rebuild ~6s with existing `lic` binary.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

- **Proof database:** `proof-db/` math seed + `scripts/proof-db-rebuild.sh` JSONL pipeline.
