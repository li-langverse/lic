# Proof database (lemma rebuild)

Operator-facing inventory of `.li` lemmas checked against the same gates as `li-tests/contracts_verify` (`lic build`, `check-autovc-open-goals.sh`, optional `lake build AutoVC`).

**Lean bridge:** `proof-db/index.json` + `proof-db/lean/ProofDB.lean` — build with `cd docs/semantics && lake build ProofDB`.

## Layout

| Path | Purpose |
|------|---------|
| `**/lemmas/*.li` | Lemma sources (one module per file) |
| `**/lemmas/*.expected.json` | Optional expected `status` for discrepancy detection |
| `results/<run-key>.jsonl` | Append-only rebuild output (local/CI; not committed) |

**Run key** (`<run-key>`): `lic --version` (sanitized) or short git SHA when version is unavailable. Override with `PROOF_DB_RUN_KEY=my-run`.

## Rebuild

From repo root (built `lic` required — `./scripts/build.sh` or devbox):

```bash
chmod +x scripts/proof-db-rebuild.sh
./scripts/proof-db-rebuild.sh              # strict build + AutoVC scan
./scripts/proof-db-rebuild.sh --lake       # also lake build AutoVC per lemma
./scripts/proof-db-rebuild.sh --dry-run    # print JSONL lines, no file write
```

Environment:

- `LIC` — path to compiler (default: `scripts/resolve-lic.sh`)
- `PROOF_DB_RUN_KEY` — output filename stem

## JSONL record

Each line is one object:

| Field | Meaning |
|-------|---------|
| `lemma_id` | Path under `proof-db/` without `lemmas/` segment (e.g. `math/linalg_dot4_int_closed`) |
| `status` | `proved` \| `open_vc` \| `compile_fail` \| `lean_fail` \| `discrepancy` |
| `autovc_open_count` | Open Prop obligations in generated `AutoVC.lean` |
| `notes` | Human-readable detail (build tail, gate message, expected vs actual) |
| `recorded_at` | UTC ISO-8601 timestamp |

### Status semantics

| Status | When |
|--------|------|
| `proved` | `lic build` ok, `autovc_open_count == 0`, and `lake build AutoVC` ok when `--lake` |
| `open_vc` | Build emitted AutoVC but open goals remain |
| `compile_fail` | `lic build` failed or AutoVC missing |
| `lean_fail` | Closed AutoVC but `lake build AutoVC` failed (`--lake` only) |
| `discrepancy` | Optional `*.expected.json` `status` differs from actual |

## Math seed (worked examples)

Three P-linalg specimens mirrored from `li-tests/contracts_verify/`:

| Lemma | Expected |
|-------|----------|
| `math/lemmas/linalg_dot4_int_closed.li` | `proved` |
| `math/lemmas/linalg_sum4_int_closed.li` | `proved` |
| `math/lemmas/linalg_dot4_int_loop_open.li` | `proved` (loop witness + `Li.Discharge.dot4_int_loop_eval_spec`) |

Example session:

```bash
export LIC="$PWD/build/compiler/lic/lic"
./scripts/proof-db-rebuild.sh
tail -3 proof-db/results/*.jsonl
```

## Adding lemmas

1. Place `your-area/lemmas/my_lemma.li` under `proof-db/`.
2. Optionally add `my_lemma.expected.json` beside the `.li` file.
3. Run `./scripts/proof-db-rebuild.sh` and inspect `proof-db/results/`.

Corpus policy: prefer copying proven specimens from `li-tests/contracts_verify/` until the proof-db grows its own discharge tooling.

## Related docs

- [Proof corpus roadmap](../docs/verification/proof-corpus-roadmap.md)
- `scripts/check-autovc-open-goals.sh`
- `li-tests/run_all.sh` — `prove_lean_ok` outcome
