# li-parallel killer loop — iteration log

## 2026-06-06 — Gate hardening (human session)

- Removed `LIPAR_KILLER_SKIP_FULL` escape hatch from killer gate
- Added sub-gates: docs, compile-smoke, catalog audit, distributed, FL, comm, hetero, xfer, proofs, chip boundaries
- Created canonical goal `li-parallel-killer-package.md` with honest Phases 5–99 **PENDING**
- Fixed benchmarks PR #370 CI: restored `data/latest/summary.json` from main (bad ph-ml ingest had 1 green row)
- Scaled K8s `li-li-parallel` to 0; ConfigMap goal → killer package

**Blocker:** killer gate fails at `check-li-parallel-docs-gate.sh` (expected until WP-PAR-50+ land).
