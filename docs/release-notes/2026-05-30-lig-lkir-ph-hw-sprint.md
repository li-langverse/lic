# PH-HW WP2–WP4 — LKIR catalog honesty + matmul CPU pilot

## Summary

Closes the governance gap between `lig-kernels.toml` and on-disk LKIR modules. Adds minimal `.lkir` / `.li` stubs for every registry path, implements `li_rt_lig_kernel_run` dispatch for `lig.kernel.matmul_f32` (kid=1) with CPU reference vs tiled parity, and makes `bench-lig-kernel-parity.sh` execute the matmul smoke binary instead of faking `validity_ratio=1.0` on compile-only success.

## North star fit

- **Domain:** GPU kernels / HPC (PH-HW)
- **PH ids:** PH-HW WP2 (LKIR on disk), WP3 (runtime dispatch), WP4 (bench + smokes)

## Verification

```bash
./scripts/build.sh
./scripts/bench-lig-kernel-parity.sh
for smoke in packages/lig/li-tests/smoke/*.li; do
  ./build/compiler/lic/lic build --allow-open-vc "$smoke" -o /dev/null
done
```
