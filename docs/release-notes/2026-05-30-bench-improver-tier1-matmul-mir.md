# Release notes: tier-1 matmul MIR fast paths (2026-05-30)

## Benchmarks

- **`matmul_naive`**: pure-Li driver calls `mm_naive_256` so codegen skips redundant C zero-fill and uses blocked IKJ+FMA for 256³.
- **`matmul_blocked`**: restore `mm_blocked_512` MIR hook (BK=64) instead of naive `@` on 512³.
- **`num_gmres`**: unchanged shared-C driver; dashboard red likely stale (local parity ~1.0×).

## Compiler (PH-7e)

- `ArrayMatMul2DF64`: square matrices with n≥256 and n divisible by 64 lower to cache-blocked IKJ (`emit_matmul2d_blocked_ijk`).

## Evidence

- Study: `docs/numerics/studies/2026-05-30-bench-improver-tier1-matmul-mir.md`
