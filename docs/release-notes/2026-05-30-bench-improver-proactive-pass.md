# Release notes — bench_improver proactive pass (2026-05-30)

- **Fix:** `bench.py` verify DCE guard uses `TimingStats.mean` (was `TypeError`).
- **Revert:** `matmul_blocked/li/main.li` restores `mm_blocked_512` MIR hook; PR #524 tile harness failed verify (Li checksum `0`).
- **Evidence:** `docs/numerics/studies/2026-05-30-bench-improver-proactive-pass.md`
