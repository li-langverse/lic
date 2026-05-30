# Swarm observer report — `orch-r2-competitor-stubs`

> `swarm_observer` · research goal `swarm_coverage` · run `swarm_observer-1780114481045` · 2026-05-30

## Executive summary

- **Posture: degraded.** Ecosystem grade **D** (69.8); `unattended_safe: false`.
- **Gap orchestration:** 30 `competitor_feature` rows; apply-actions patched 12 vertical stub rows (`benchmarks/data/latest/swarm-gap-actions.json`).
- **Swarm execution:** 5502 errors / 24h; 19 `running` — GraphQL rate limit + SDK premature end (`tools=0`).
- **Goal drift:** Briefing heap = numerics/governance; async swarm also runs UX/PR agents.
- **Programmatic observer:** No retries; stale healthy report (2026-05-25).
- **Benchmarks:** 6 red tier-1 rows — handoff `bench_improver`, `numerics_researcher`.
- **Unattended?** **No.**

## Findings

| Agent / area | Symptom | Evidence | Severity |
|--------------|---------|----------|----------|
| Swarm (async) | Error burst + stuck `running` | Supabase `agent_runs`; `ecosystem-quality-report.json` | critical |
| `workspace_sweeper` | GraphQL push fail | `workspace_sweeper-1780113491850.json` | high |
| Goal-directed | 6 runners stopped | `goal-directed-agents/snapshot.json` | high |
| Control plane | Stale healthy | `control_plane_reports` | medium |
| Gap infra | verticals.toml not on benchmarks main | `registry.yaml` | low |

## Self-heal actions taken

- Observer: no retries, no stopped agents
- Meta pass: ingest + apply-actions re-run (idempotent)

## Recommended control-plane fixes

See `docs/ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md`.

## Human-only blockers

GraphQL quota; governance merges; benchmarks verticals.toml land.

## Agent deliverable checklist

- [x] Ingest + apply-actions
- [x] orch-r2 closed
- [x] Orchestrator note + this report
- [x] Benchmarks digest `swarm_observer-1780114481045.md`

**Dashboard:** `benchmarks/data/runs/swarm_observer-1780114481045.md`
