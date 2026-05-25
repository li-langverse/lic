# Check-cache security hardening

## Summary

Harden `lic check` incremental cache and resource CLI against poisoning, oversized entries, symlink escape, and fork/memory DoS.

## Agent continuation

1. Read `docs/security/check-cache-threat-model.md`, `compiler/cache/check_cache.cpp`, `compiler/common/resource_options.cpp`.
2. Run `./scripts/build.sh && ./scripts/ci-security.sh` (includes `li-tests/cache_exploits/check_cache_exploits.sh`).
3. Next: integrator flag-only `ci.sh` pool (Wave 2); cache hardening already on `main` via #228/#236.
4. Blocked: none.

## Changed

- `compiler/cache/check_cache.cpp` — `v=1` format, 1 MiB entry cap, canonical cache root, path containment, no symlink I/O, LRU + `cache-max-mb` cap (max 4096).
- `compiler/cache/include/li/check_cache.hpp` — documented limits.
- `compiler/types/import_resolve.cpp` — `hash_direct_import_graph()` for cache keys.
- `compiler/common/resource_options.cpp` — cap `--jobs` (256), `--max-memory` (65536 MiB), `--threads` (256).
- `compiler/lic/check_cmd.cpp` — import graph + output mode in key; `normalize_check_cache_options`.
- `li-tests/cache_exploits/check_cache_exploits.sh` — exploit harness.
- `scripts/ci-security.sh` — runs cache exploit script.
- `docs/security/check-cache-threat-model.md` — trusted vs untrusted.

## Not changed

- Tier5 CVE catalog thresholds; `race_shared_memory` / `decorator_exploits` suites.
- `lic build` Lean/MIR cache (check diagnostics only).

## Breaking

N/A — cache format `v=1` invalidates prior cache files (safe miss).

## Security

Evidence: `./li-tests/cache_exploits/check_cache_exploits.sh` (also in `ci-security.sh`).

## Performance

N/A — extra hashing of direct imports on cache lookup (streaming FNV).

## Downstream

Merged via #228 (WP3) + #236; this note documents `ci-security.sh` wiring on `main`.
