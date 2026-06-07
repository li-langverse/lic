# Release notes: 2026-05-27 — workspace-resource-gate

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** (supersedes #299)  
**PH / REQ:** security / execution resources  
**Author:** agent

---

## Summary (one sentence)

`lic check --workspace` now exits 1 when resource CLI flags are invalid, matching single-file `lic check` and unblocking `execution_exploits` workspace paths.

## Agent continuation (required)

1. Read: `compiler/lic/workspace_check.cpp`, `compiler/lic/check_cmd.cpp`, `li-tests/execution_exploits/run.sh`
2. Run: `LI_REPO_ROOT=$PWD cmake --build build && ./li-tests/execution_exploits/run.sh`
3. Then: merge PR; close #299 as superseded
4. Blocked on: none

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| workspace check | `resource_options_invalid()` gate after `finalize_resource_options` | `compiler/lic/workspace_check.cpp` |
| single-file check | Already gated in `check_cmd.cpp` (#296) | unchanged |

## Not changed (scope fence)

- Tier-0 bench script changes from old #299 stack — already on `main` via other PRs
- ProofDB lemmas, studio verticals, wgpu readback

## Breaking

N/A — stricter exit on invalid flags only.

## Security

Aligns workspace check with execution resource exploit harness expectations (invalid `--cores` / `--threads`).

## Performance

N/A

## Downstream

N/A
