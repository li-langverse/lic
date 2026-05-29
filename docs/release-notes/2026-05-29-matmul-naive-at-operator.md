# Release: matmul_naive uses `C = A @ B` lowering

**Tier-1 bench** `matmul_naive` (N=256) now calls the compiler `ArrayMatMul2DF64` path (`C = A @ B`) instead of hand-written IKJ loops. LUT initialization is unchanged; verify checksum matches the C++ oracle.

**Evidence:** `docs/numerics/studies/2026-05-29-matmul-naive-at-codegen.md`

**Performance:** Local harness shows Li within ~1.05× cpp (was ~1.33× on dashboard ingest). Re-run org ingest after merge.

**Breaking:** none · **Security:** none · **Downstream:** benchmarks `ingest-lic.sh` refresh for public dashboard row.
