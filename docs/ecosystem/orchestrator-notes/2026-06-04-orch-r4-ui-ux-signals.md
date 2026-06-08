# Orchestrator note — `orch-r4-ui-ux-signals`

**Date:** 2026-06-04  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` @ dimension **ux** (worker `01e42b45`)  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — ecosystem grade **D** (68.3); `unattended_safe: false` |
| `orch-r4` | **Completed this pass** — UX signals documented; ingest/apply unblocked |
| Registry UX drift | **2 stale open rows** (`studio-ux-16`, `studio-ux-17`) — loop `state.json` shows **done** |
| Snapshot | **Stale** (`generated_at` 2026-05-30) — blocks `reconcile_snapshot_completed` |
| Handoffs | `gui_ux_tester` (`ui_ux_quality`), `plan_verifier` (snapshot refresh), `gap_explorer` |

Programmatic prep: `lic/scripts/swarm-gap-ingest.py` + `lic/scripts/swarm-gap-apply-actions.py` @ 2026-06-04T01:27:43Z (after ingest syntax + `BENCHMARKS_COMPETITIVE` default fix).

---

## UX dimension findings

### Studio UI/UX loop (evidence)

| Source | Signal |
|--------|--------|
| `lic/data/studio-ui-ux-plan-loop/state.json` | `studio-ux-16` … `studio-ux-24` in `completed_ids`; native palette 14ms; agent chrome 12ms |
| `lic/data/goal-directed-agents/snapshot.json` | Still lists `studio-ux-16/17` as **pending**; `completed_ids` stops at `studio-ux-15` |
| `registry.yaml` | `gap-plan-pending-studio-ui-ux-studio-ux-16-*` and `-17-*` remain **open** |

**Root cause:** goal-directed snapshot not refreshed after 2026-05-30 loop iterations → ingest cannot auto-close plan_debt rows.

### Operator UX (control plane)

| Symptom | Evidence |
|---------|----------|
| Empty disk CP mirrors | `ENOENT` `/app/data/control-plane/{state,latest-report}.json` |
| MCP DB down | `connect ECONNREFUSED 127.0.0.1:54322` |
| Scorecard blind to runs | `runs_sampled: 0` in fresh `ecosystem-quality-report.json` |
| Preflight partial | 8 scripts `--skip-slow`; `org_ci_audit` / `org_agent_kit_audit` exit 1 |

### `ui_ux` gap taxonomy (this pass)

| `gap_kind` | Open (UX-relevant) | Action |
|------------|-------------------|--------|
| `plan_debt` | 2 studio-ui rows (stale) | Close after snapshot refresh |
| `plan_debt` | `orch-r4-ui-ux-signals` | Close on merge of this note |
| `ui_ux` (discoverer) | Route via `gui_ux_tester` / `ui_ux_quality` goal | No new registry ids |

Apply skipped studio wave-4 patches: backlog path missing in container (`lic-studio-ui` plan loop doc not mounted).

---

## Reconciliation actions (orchestration only)

1. **P0:** Run `goal-directed-agents-snapshot.py` on host (needs `systemctl`) → re-run ingest → expect `snapshot_completed` ≥ 2 for studio-ui-ux.
2. **Handoff:** `gui_ux_tester` — run `ui_ux_quality` goal; file issues for any regression vs `studio-ui.toml` gates.
3. **Handoff:** `plan_verifier` — align `swarm-observer` plan todo `orch-r4` with registry closure.
4. **Do not** install `install-goal-plan-loop-systemd.sh` for studio-ui — use agents control plane per `docs/ecosystem/swarm-architecture.md`.

---

## Scripts executed

```bash
export LIC_ROOT=/workspace/lic BENCHMARKS_ROOT=/workspace/benchmarks
python3 scripts/swarm-gap-ingest.py    # registry 92 rows; 62 open after ingest
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json (open_gaps=62)
cd /workspace/benchmarks && python3 scripts/ecosystem-quality-grade.py  # grade D 68.3
```

**Fixes applied (lic):** `scripts/swarm-gap-ingest.py` — `verticals.toml` Path fallback + `BENCHMARKS_COMPETITIVE` default.

---

## Related

- Prior: `2026-05-31-orch-r3-missing-package-sweep.md`
- Report: `li-cursor-agents/data/runs/swarm_observer-1780535476039.md`
- Whitepaper (deferred): `research-findings/whitepapers/2026-06/swarm_coverage/ux/`
