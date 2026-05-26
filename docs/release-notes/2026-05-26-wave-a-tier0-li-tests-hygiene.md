# Release notes: 2026-05-26 — wave-a-tier0-li-tests-hygiene

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/fix-wave-a-and-swarm-9031`  
**PH / REQ:** PH-2f, PH-7d, PH-7e, WP-WA  
**Author:** agent

---

## Summary (one sentence)

Wave A tier-0 test runs no longer hang on stale AutoVC locks, open-VC manifest rows compile without Lean cross-talk, and the pure-Li Horner plus blocked-matmul tier-1 rows are back under the strict performance threshold.

## Agent continuation (required)

1. Read: `docs/ecosystem/wave-a-stdlib-unblock-checklist.md`, `docs/verification/provability-gaps.md`, and this release note.
2. Run: `cmake --build build`, `LI_AUTOVC_LOCK_TIMEOUT_SEC=30 ./li-tests/run_all.sh contracts_verify`, `LI_AUTOVC_LOCK_TIMEOUT_SEC=30 ./li-tests/run_all.sh encapsulation bytes`, `LI_AUTOVC_LOCK_TIMEOUT_SEC=30 python3 benchmarks/harness/bench.py --tier 1 --only matmul_blocked --runs 3`, and `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh`.
3. Then: re-run `./scripts/compiler-studio-plan-gates.sh` and continue **G-par** iteration-independence specs.
4. Blocked on: **WP-WA** is still not fully closed; **G-par** iteration-independence specs and default certificate coverage remain open.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| AutoVC locking | `compiler/lic/main.cpp` respects inherited `LI_AUTOVC_LOCK_HELD=1` and fails visibly on bounded `LI_AUTOVC_LOCK_TIMEOUT_SEC` instead of hanging forever on a stale lock. | Lock probe with `LI_AUTOVC_LOCK_TIMEOUT_SEC=0` exits `1` instead of hanging. |
| AutoVC file writes | `compiler/verify/vc_emit_lean.cpp` writes `AutoVC.lean.tmp` and renames atomically; `scripts/lean-verify-stub.sh` drops stale `AutoVC` lake artifacts before typecheck. | `cmake --build build` and targeted `li-tests` pass. |
| Manifest harness | `li-tests/run_all.sh` clears `build/generated/AutoVC.lean` before strict rows and treats `*_open_ok` rows as compile/link gates with `--allow-open-vc --no-lean-verify`. | `LI_AUTOVC_LOCK_HELD=1 ./li-tests/run_all.sh contracts_verify` and `... encapsulation bytes` both exit `0`. |
| Tier-1 Horner | `compiler/mir/lower.cpp` emits `HornerConstLoopF64` for large constant loops; `compiler/codegen/emit.cpp` lowers the recurrence in 64-step chunks. | `horner_pure_li` reports `0.625x` C++ in strict tier-1 check. |
| Tier-1 matmul | `benchmarks/tier1_micro/matmul_blocked/li/main.li` calls the `mm_blocked_512` MIR fast-path hook; `compiler/codegen/emit.cpp` lowers the inner `j` loop with unaligned-safe `<4 x double>` loads/stores and avoids compiling a huge unused helper body. | `matmul_blocked` verifies and refreshes to `1.183x` C++; strict tier-1 exits `0`. |

## Not changed (scope fence)

- **WP1 stdlib ADT runtime** (`list` / `dict` / `set`) is still blocked.
- **G-par** iteration-independence proofs are not implemented; only the existing policy witness slice remains.
- **G-lean** is not universal across shipped workspace paths.
- Full `python3 benchmarks/harness/bench.py --tier 1` still needs a follow-up on the `horner_pure_li` `min_li_seconds` guard; this PR refreshed `matmul_blocked` directly and uses the strict CSV gate.

## Breaking changes

None — new `LI_AUTOVC_LOCK_TIMEOUT_SEC` behavior only bounds local compiler lock waits and preserves existing successful paths.

## Security

N/A — no trusted axioms, stdlib seal policy, CVE catalog, or exploit harness changed.

## Performance

`LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh` exits `0` after refreshing `matmul_blocked`: `simd_dot` `0.982x`, `matmul_naive` `0.880x`, `matmul_blocked` `1.183x`, and `horner_pure_li` `0.625x` versus C++.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis / packages | N/A — compiler CLI behavior and generated VC path are compatible. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Fixed
- **Wave A tier-0 / AutoVC:** bounded AutoVC lock waits, atomic `AutoVC.lean` writes, open-VC manifest rows compile without Lean cross-talk, and strict tier-1 perf is green for `horner_pure_li` plus `matmul_blocked` — [2026-05-26-wave-a-tier0-li-tests-hygiene.md](docs/release-notes/2026-05-26-wave-a-tier0-li-tests-hygiene.md).
```
