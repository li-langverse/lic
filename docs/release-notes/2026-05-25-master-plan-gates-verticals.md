# Master plan gates: vertical alignment + gap queue

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** chore/master-plan-gates-verticals  
**PH / REQ:** PH-HW, PH-UX, PH-AGENT, PH-SIM (vertical stubs); CI gate hygiene  

---

## Summary (one sentence)

Align `check-master-plan-gates.sh` with shipped PH-HW/Studio/MCP vertical stubs, add `GAP_CLOSURE_QUEUE.md` with open-issue mapping, fix `resource_options_invalid` link error blocking `lic check` builds, and correct `li-gpu` → `lig` manifest drift.

## Agent continuation (required)

1. **Read:** `docs/verification/GAP_CLOSURE_QUEUE.md`, `scripts/check-master-plan-vertical-gates.sh`, master plan v1 gate row in `docs/superpowers/plans/2026-05-14-li-master-plan.md`.
2. **Run:** `./scripts/build.sh` then `./scripts/check-master-plan-vertical-gates.sh` (or full `./scripts/check-master-plan-gates.sh` when lake/benches available).
3. **Then:** Merge stacked vertical PRs (#288 readback, #283 MCP server) and refresh the open PR map in `GAP_CLOSURE_QUEUE.md`; close org issues only when tracker + gates move together.
4. **Blocked on:** Human merge; full gate run needs LLVM 22 + optional lake on PATH.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Gap queue | `docs/verification/GAP_CLOSURE_QUEUE.md` — prioritized gaps + issue ↔ queue table | Agent dispatch doc |
| Vertical gates | `scripts/check-master-plan-vertical-gates.sh` — required lig parity + present tick; advisory composable/MCP until #287/#290 | Wired in `check-master-plan-gates.sh` |
| Gate drift | Drop duplicate `check-mir-parallel-decorator.sh` top-level run (still in `contracts_discharge_corpus.sh`) | Decorator corpus unchanged |
| CI build | `resource_options_invalid()` declared + invalid `--cores`/`--threads` flags | `compiler/common/resource_options.*`, `check_cmd.cpp` |
| Manifest | `import_render_wgpu_fps.li` packages `li-gpu` → `lig` | `li-tests/manifest.toml` |

## Not changed (scope fence)

- Master plan tracker partial rows (2i, 7d, 7e, 8p, Vision-LLM) — still open.
- Tier-0 bench thresholds and `benchmarks/harness/verify.py` tier-2 gates.
- Full `lis` HTTP MCP stdio server (`feat/studio-mcp-lis-server`); in-tree gate uses `studio_mcp_*.li` smokes only.
- wgpu GPU readback / honest MP4 capture (Studio **#2** still P1 in queue).

## Breaking changes

N/A.

## Security

N/A — gate wiring and manifest path only.

## Performance

N/A — `bench-lig-kernel-parity.sh` pilot gate unchanged (validity advisory semantics).

## Downstream

| Repo | Action |
|------|--------|
| benchmarks | Re-run `plan-completion-audit.py` with `LIC_ROOT` after merge |
| li-cursor-agents | Preflight `agent-briefing.json` picks up queue path |

## CHANGELOG entry (paste into Unreleased)

- **Master plan vertical gates:** `GAP_CLOSURE_QUEUE.md`, `check-master-plan-vertical-gates.sh`, gate dedupe, `resource_options_invalid` CI fix, manifest `lig` path — [2026-05-25-master-plan-gates-verticals.md](docs/release-notes/2026-05-25-master-plan-gates-verticals.md).
