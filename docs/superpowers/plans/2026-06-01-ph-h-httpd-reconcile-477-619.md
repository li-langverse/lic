---
name: PH-H httpd phase2 reconcile (#477 / #619)
workflow_repo: lic
ph_ids: [PH-H, PH-H-httpd]
tracker: docs/superpowers/plans/2026-05-16-li-httpd-plan.md
master_plan: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#619, li-langverse/lic#477, li-langverse/lic#471, li-langverse/lic#436]
north_star_fit: "Web/agent gateway (PH-H) — proof-before-perf; tier5 wrk gates are the perf bar after exploit parity"
status: draft
---

# PH-H httpd: reconcile snapshot, registry, and #477 (phase2 wrk gates)

**Date:** 2026-06-01  
**Kind:** Orchestration / master-plan-gap reconcile (not new product surface)  
**Parent plan:** [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md)  
**Blocks:** Closing #619, #477; unblocks `swarm_observer` registry honesty

## Problem (corrected evidence)

Issue #619 reported snapshot **10/10** todos `completed` while #477 and registry rows still tracked phase2 wrk gates as pending. **On `lic` main @ 2026-05-30** the truth is:

| Source | State |
|--------|--------|
| `data/goal-directed-agents/snapshot.json` → runner `httpd` | **8/10** completed; `plan_pending`: `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| `state.history` | Both pending todos ran with **`agent_exit: 124`** (timeout), **`gates_ok: false`** |
| `data/swarm-gap-registry/registry.yaml` | Canonical + deduped `gap-plan-pending-httpd-*` rows are **`status: closed`** (stale — closed without gate pass) |
| `benchmarks/data/latest/swarm-gap-actions.json` | **0** open httpd phase2 actions (apply pipeline out of sync with snapshot) |
| #477 | Open — correctly tracks the two pending wrk-timing gates |

**Root cause:** Three-way drift between (1) plan-loop todo status, (2) ingest reconcile (`completed_ids` / premature dedupe close), and (3) gate logs. Perf pillar work (#619) must not close until **gate scripts pass** with `HTTPD_BENCH_SKIP_TIMING=0`.

## Vision / philosophy check

- **Pass** — aligns with proof → easy → fast; phase2 gates enforce perf **after** exploit/nginx parity (no threshold weakening).
- **Not in scope:** weakening `threshold_ratio_cpp`, skipping timing, or marking todos complete without gate logs.
- **Defer to human:** none; this is registry + gate verification hygiene on existing PH-H track.

## Scope

### In scope

1. Gate verification for the two pending phase2 todos
2. Issue + registry reconcile (#477, #619)
3. Ingest reconcile fix (#471) — honor `todos[].status` **and** require `gates_ok` / gate script pass before closing `plan_debt`
4. Confirm ingest script path on main (#436 — present; verify registry YAML parses)

### Out of scope

- New httpd features beyond passing existing gates
- M1 `.li` gateway (separate PH-H M1 track)
- Self-merge; product code unless gates fail and loop assigns fix todos

## Implementation phases

### Phase 0 — Preflight (read-only)

| Step | Command / check | Pass criteria |
|------|-----------------|---------------|
| 0.1 | `./scripts/build-li-httpd.sh` | `build/li-httpd` executable |
| 0.2 | `python3 scripts/swarm-gap-ingest.py --dry-run` | Exit 0; registry YAML valid |
| 0.3 | Confirm nginx + wrk on PATH | Required for timing gates (document skip env if CI lacks deps) |
| 0.4 | Read snapshot httpd block | Record `plan_pending`, `history`, `active_todo_id` |

### Phase 1 — Gate verification (truth source)

Run with **`HTTPD_BENCH_SKIP_TIMING=0`** (gates set this internally):

```bash
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC=30   # default in check-tier5-perf-wrk-soak.sh
./scripts/check-tier5-perf-wrk-soak.sh      # gap-phase2-perf-wrk-soak
./scripts/check-tier5-streaming-soak.sh     # gap-phase2-streaming-wrk
```

| Outcome | Action |
|---------|--------|
| **Both green** | Mark todos `completed` in httpd plan YAML; close #477; close #619; re-ingest → registry rows stay closed |
| **Either fails** | Keep todos `pending`; attach gate log to #477; **reopen** wrongly-closed registry rows; restart `httpd-plan-loop` on failing todo only |
| **Exit 124 (timeout)** | Treat as fail — investigate nginx/wrk soak duration, runner resources; do **not** mark complete |

Optional full loop gate: `HTTPD_RUN_PHASE2_GATES=1 ./scripts/httpd-plan-gates.sh` (runs phase2 hooks).

### Phase 2 — Ingest reconcile (#471)

Extend `scripts/swarm-gap-ingest.py`:

1. **`reconcile_snapshot_completed`:** Close `plan_debt` only when todo id is in `todos[]` with `status: completed` **or** `done`, **and** last history entry for that todo has `gates_ok: true` (or no history — require explicit gate run in implement PR).
2. **`ingest_snapshot_plan_pending`:** If `plan_pending` non-empty, ensure matching registry row is **`open`** (reopen if wrongly closed).
3. **`dedupe_plan_pending_gaps`:** Keep single canonical row per `(runner_id, normalized plan_todo_id)`; preserve `open` if snapshot still pending.

Re-run:

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
```

Handoff **`swarm_observer`** with ingest stats + `benchmarks/data/latest/swarm-gap-actions.json` diff.

### Phase 3 — Issue hygiene

| Issue | When to close |
|-------|----------------|
| **#477** | Both phase2 gates green + plan todos marked completed |
| **#619** | #477 closed + ingest shows 0 open httpd phase2 `plan_debt` + snapshot `plan_pending: []` |
| **#471** | Reconcile patch merged + sim/studio stale rows verified on re-ingest |
| **#436** | Registry parses; ingest runs on main (close if already true) |

Cross-link: add comment on #619 → this plan; on close, reference gate log artifact path under `data/httpd-plan-loop/`.

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **PH-H** | Proved agent HTTP gateway | [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md) phase2 todos |
| **PH-H-httpd** | Perf after proof — wrk vs nginx | `check-tier5-perf-wrk-soak.sh`, `check-tier5-streaming-soak.sh` |
| **REQ-httpd-phase2-timing** | ≥30s wrk soak, no skip timing | `HTTPD_BENCH_SKIP_TIMING=0` in gate scripts |
| **G-swarm-plan-debt** | Registry matches snapshot | `swarm-gap-ingest.py` reconcile + `plan-completion-audit.json` |
| **Bench** | tier5_http parity + streaming | `benchmarks/tier5_http/` scenarios via regression gate |

## Files touched (implement pass)

| Path | Change |
|------|--------|
| `scripts/swarm-gap-ingest.py` | Reconcile logic (#471) |
| `data/swarm-gap-registry/registry.yaml` | Re-ingest output |
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | Todo status only if gates green |
| `data/goal-directed-agents/snapshot.json` | Updated by plan-loop / snapshot script |
| `docs/release-notes/2026-06-01-httpd-phase2-reconcile.md` | If gate pass closes phase2 |

## Learned from

1. [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md) — phase2 todo definitions and gate names
2. [2026-05-24-httpd-gap-phase2.md](../../release-notes/2026-05-24-httpd-gap-phase2.md) — phase2 gate wiring
3. [2026-05-25-orch-r1-plan-debt-sync.md](../../ecosystem/orchestrator-notes/2026-05-25-orch-r1-plan-debt-sync.md) — plan_debt dedupe lessons
4. [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — proof before perf pillar order

## Acceptance criteria (plan-approved → implement)

- [ ] Gate logs archived for both phase2 scripts with `HTTPD_BENCH_SKIP_TIMING=0`
- [ ] Snapshot `httpd.plan_pending` empty **iff** gates passed
- [ ] #477 closed or explicitly kept open with failing log (no silent drift)
- [ ] Ingest reconcile honors `todos[].status` + `gates_ok` (#471)
- [ ] `swarm-gap-actions.json` has no stale open httpd phase2 rows after apply
- [ ] `swarm_observer` handoff posted with north_star_fit: **web/agent gateway, PH-H, PH-H-httpd**

## Handoffs

| Agent | Trigger |
|-------|---------|
| `code_implementer` | Gate failure requires httpd/runtime fix |
| `swarm_observer` | After Phase 2 ingest + apply-actions |
| `plan_verifier` | Re-audit snapshot vs registry post-merge |
