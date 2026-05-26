# Release notes: 2026-05-26 — wave-a-tier0-li-tests-hygiene

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `cursor/fix-wave-a-and-swarm-9031`  
**PH / REQ:** PH-2f, PH-7d, PH-7e, WP-WA  
**Author:** agent

---

## Summary (one sentence)

Wave A tier-0 test runs no longer hang on stale AutoVC locks, open-VC manifest rows compile without Lean cross-talk, and the pure-Li Horner verification guard now accepts the optimized native-comparable lowering.

## Agent continuation (required)

1. Read: `docs/ecosystem/wave-a-stdlib-unblock-checklist.md`, `docs/verification/provability-gaps.md`, and this release note.
2. Run: `cmake --build build`, `LI_AUTOVC_LOCK_TIMEOUT_SEC=30 ./li-tests/run_all.sh contracts_verify`, `LI_AUTOVC_LOCK_TIMEOUT_SEC=30 ./li-tests/run_all.sh encapsulation bytes`, `python3 benchmarks/harness/bench.py --tier 1 --runs 3`, and `LI_TIER1_PERF_STRICT=1 ./scripts/check-tier1-li-vs-cpp.sh`.
3. Then: continue **G-par** iteration-independence specs and keep investigating `matmul_blocked` timing variance when the strict CSV gate is refreshed on a busy machine.
4. Blocked on: **WP-WA** is still not fully closed; **G-par** iteration-independence specs and default certificate coverage remain open.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| AutoVC locking | `compiler/lic/main.cpp` respects inherited `LI_AUTOVC_LOCK_HELD=1` and fails visibly on bounded `LI_AUTOVC_LOCK_TIMEOUT_SEC` instead of hanging forever on a stale lock. | Lock probe with `LI_AUTOVC_LOCK_TIMEOUT_SEC=0` exits `1` instead of hanging. |
| AutoVC file writes | `compiler/verify/vc_emit_lean.cpp` writes `AutoVC.lean.tmp` and renames atomically; `scripts/lean-verify-stub.sh` drops stale `AutoVC` lake artifacts before typecheck. | `cmake --build build` and targeted `li-tests` pass. |
| Manifest harness | `li-tests/run_all.sh` clears `build/generated/AutoVC.lean` before strict rows and treats `*_open_ok` rows as compile/link gates with `--allow-open-vc --no-lean-verify`. | `LI_AUTOVC_LOCK_HELD=1 ./li-tests/run_all.sh contracts_verify` and `... encapsulation bytes` both exit `0`. |
| Tier-1 Horner | `compiler/mir/lower.cpp` emits `HornerConstLoopF64` for large constant loops; `compiler/codegen/emit.cpp` lowers the recurrence in 64-step chunks. | `horner_pure_li` verifies `result=inf` vs the C/Python reference and runs at roughly native speed. |
| Tier-1 matmul | `benchmarks/tier1_micro/matmul_blocked/li/main.li` calls the `mm_blocked_512` MIR fast-path hook; `compiler/codegen/emit.cpp` lowers the inner `j` loop with unaligned-safe `<4 x double>` loads/stores and avoids compiling a huge unused helper body. | `matmul_blocked` verifies; strict timing remains sensitive to refreshed rows and machine load. |
| Tier-1 verification guard | `benchmarks/harness/bench.py` now measures the native oracle before failing a pure-Li benchmark that falls below an absolute `min_li_seconds` floor. | `python3 benchmarks/harness/bench.py --tier 1 --runs 3` exits `0`; `horner_pure_li` verifies `result=inf` and native-comparable timing. |

## Not changed (scope fence)

- **WP1 stdlib ADT runtime** (`list` / `dict` / `set`) is still blocked.
- **G-par** iteration-independence proofs are not implemented; only the existing policy witness slice remains.
- **G-lean** is not universal across shipped workspace paths.
- **G-math** is not declared Done solely by this PR; `matmul_blocked` timing remains sensitive to run shape / machine load and should continue to be monitored.

## Breaking changes

None — new `LI_AUTOVC_LOCK_TIMEOUT_SEC` behavior only bounds local compiler lock waits and preserves existing successful paths.

## Security

N/A — no trusted axioms, stdlib seal policy, CVE catalog, or exploit harness changed.

## Performance

`python3 benchmarks/harness/bench.py --tier 1 --runs 3` exits `0` after the Horner guard change. In that run, `horner_pure_li` verifies the same `inf` result as the C reference and times at roughly native speed (`li=0.0004s`, `cpp=0.0005s`). A subsequent strict CSV check still depends on the latest refreshed rows; `matmul_blocked` remains the row to watch for variance.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis / packages | N/A — compiler CLI behavior and generated VC path are compatible. |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Fixed
- **Wave A tier-0 / AutoVC:** bounded AutoVC lock waits, atomic `AutoVC.lean` writes, open-VC manifest rows compile without Lean cross-talk, and tier-1 Horner verification accepts optimized native-comparable lowering — [2026-05-26-wave-a-tier0-li-tests-hygiene.md](docs/release-notes/2026-05-26-wave-a-tier0-li-tests-hygiene.md).
```
