# RAJA execution policy telemetry (lic#109)

Adds `mir_parallel_policy=static_chunk` to `lic verify` when proved `OmpParallelFor` sites exist, plus `parallel_no_silent_serial` gate ensuring `@parallel` lowers to `li_parallel_for_i64` (not silent serial).

Normative policy matrix: `docs/superpowers/specs/2026-06-07-li-raja-policy-portability-rubric.md`.

**Gates:** `scripts/check-mir-parallel-policy.sh`, `li-tests/parallel_codegen/parallel_no_silent_serial.li`.
