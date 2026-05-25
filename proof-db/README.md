# Proof database — compiler release gate

| Artifact | Role |
|----------|------|
| [`index.json`](index.json) | Four registry rows |
| [`lean/ProofDB.lean`](lean/ProofDB.lean) | `lake build ProofDB` |
| [`baseline.jsonl`](baseline.jsonl) | Pinned JSONL export |

Regenerate baseline:

```bash
./scripts/build.sh
lic build li-tests/modules/greeter/greeter.li -o /dev/null
./scripts/export-proof-db.sh > proof-db/baseline.jsonl
```

| Variable | Effect |
|----------|--------|
| `LI_PROOF_DB_STRICT=0` | Advisory check (default) |
| `LI_PROOF_DB_STRICT=1` | Fail on drift |
| `PROOF_DB_SKIP=1` | Skip gate |

Local: `LI_PROOF_DB_STRICT=0 ./scripts/check-proof-db.sh`
