# Release note: matmul_naive uses `@` codegen path (PH-7e)

**2026-05-29** — Tier-1 `matmul_naive` hot loop is now `C = A @ B`, lowering to `ArrayMatMul2DF64` with FMA instead of scalar source loops. Local harness: Li wall time ~1.0× cpp (was ~1.33× on dashboard ingest). Study: `docs/numerics/studies/2026-05-29-matmul-naive-at-codegen.md`.
