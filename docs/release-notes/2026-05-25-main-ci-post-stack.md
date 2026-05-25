# Release notes: main CI post-stack fixes

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** fix/main-ci-post-stack  
**PH / REQ:** N/A (CI unblock)  
**Author:** agent

---

## Summary (one sentence)

Unblocks `main` CI by aligning `typosquat_paralell` manifest expectations with compile-time W0403 diagnostics and discharging `bounds_refinement_release_ok` AutoVC goals for literal refinement and array-init witnesses.

## Agent continuation (required)

1. Read: `li-tests/manifest.toml` (decorator_exploits + contracts_verify rows), `compiler/verify/call_requires.cpp`, `compiler/verify/vc_witness.cpp`.
2. Run: `./scripts/build.sh`, `./li-tests/run_all.sh`, `li-tests/tooling/check_release_bounds_ir.sh` (with lake on CI).
3. Then: merge PR when `build-and-test` + `lake-build` are green; stacked PRs #265/#261/#257 can rebase.
4. Blocked on: **none** for this slice.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-tests/manifest.toml` | `typosquat_paralell.li` → `compile_fail` + `expected_substr = W0403` (invalid `decorator def` syntax still rejects; typosquat is warning before parse error) | `./li-tests/run_all.sh` PASS |
| `compiler/verify/call_requires.cpp` | Track `a[i]` const stores; fold index reads; `expr_statically_true` for `and` chains | bounds refinement call-site VC |
| `compiler/verify/vc_witness.cpp` | Witness `read_at(a, lit)` ensures via known `a[lit]` init | `bounds_refinement_release_ok.li` `verify_ok` |
| `compiler/lic/check_cmd.cpp` | Drop calls to missing `resource_options_invalid()` (link fix on current `main`) | `ninja lic` link green |

## Not changed (scope fence)

- No WP feature / studio / sim product code.
- No weakening of `prove_reject`, CVE, or open-VC gates.
- No `Discharge.lean` lemma additions (literal goals close via existing trivial / static witnesses).

## Breaking changes

None.

## Security

N/A — test/manifest + VC witness alignment only.

## Performance

N/A — compile-time proof folding only.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

### Fixed

- Main CI: `typosquat_paralell` manifest (`compile_fail` + W0403), `bounds_refinement_release_ok` AutoVC discharge, `lic check` link without `resource_options_invalid`.
