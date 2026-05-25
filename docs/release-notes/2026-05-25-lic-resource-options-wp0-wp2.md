# WP0/WP2 resource flags

## Summary
CLI `--build-dir` / `--jobs` via ResourceOptions; run_all uses per-worker `--build-dir`.

## Agent continuation
1. Read `compiler/common/include/li/resource_options.hpp`.
2. Run `./scripts/build.sh` and smoke scripts.
3. Next: WP1/WP3; integrator `ci.sh -j8`.

## Not changed
analyze/, OpenMP removal, benches.
