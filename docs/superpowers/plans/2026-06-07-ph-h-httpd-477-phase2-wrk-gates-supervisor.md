---
name: PH-H httpd phase2 wrk gates (#477)
workflow_repo: lic
ph_ids: [PH-H, PH-H-httpd]
tracker: docs/superpowers/plans/2026-05-16-li-httpd-plan.md
master_plan: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#477]
related_plans:
  - docs/superpowers/plans/2026-06-01-ph-h-httpd-reconcile-477-619.md
north_star_fit: "Web/agent gateway (PH-H) — proof-before-perf; tier5 wrk soak gates are the perf bar after exploit/nginx parity"
status: draft
---

# PH-H httpd #477: phase2 wrk gates + supervisor restart

**Date:** 2026-06-07  
**Kind:** Master-plan-gap closure — gate verification + orchestrator hygiene  
**Parent plan:** [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md)  
**Related:** [2026-06-01-ph-h-httpd-reconcile-477-619.md](2026-06-01-ph-h-httpd-reconcile-477-619.md) (registry ingest reconcile, #471)  
**Blocks:** Closing #477; unblocks master-plan Phase H partial row update (human merge only)

## Problem

Plan verifier **2026-05-30** and nightly CI **2026-06-05** show the httpd plan loop is **stuck**:

| Signal | State |
|--------|--------|
| `data/goal-directed-agents/snapshot.json` → runner `httpd` | **8/10** todos completed; **2 pending** |
| Pending todos | `gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk` |
| `state.history` | Both ran with **`agent_exit: 124`** (timeout), **`gates_ok: false`** |
| Supervisor | `httpd-plan-until-deadline.sh` log **~26k s stale** (`status_note: supervisor idle`) |
| Branch | `cursor/httpd-plan-continue` @ `fbc69f07` — 8/10 done, gates not green |
| Registry | `gap-plan-pending-httpd-gap-phase2-*` rows reconciled open (#846/#865); close only after gates pass |
| Nightly | `httpd-phase2-nightly` run **26987188234** failed pre-soak |

**Root cause:** Orchestrator idle while timing gates remain red. Perf pillar (PH-H phase2) must not close until gate scripts pass with **`HTTPD_BENCH_SKIP_TIMING=0`**. No threshold weakening.

## Vision / philosophy check

- **Pass** — aligns with proof → easy → fast; wrk soak is perf verification **after** exploit/nginx parity (8/10 prior todos green).
- **Reject:** lowering `HTTPD_BENCH_RPS_RATIO_MIN`, skipping timing via env in CI, or marking todos complete without gate logs.
- **Human-only:** master-plan Phase H partial row merge; `trusted.lean` changes.

## Scope

### In scope

1. **Supervisor restart** — unstick `httpd-plan-until-deadline.sh` / `httpd-plan-loop.sh` on httpd worktree targeting the two pending todos only.
2. **Gate verification** — run and archive logs for both phase2 wrk scripts.
3. **Plan todo closure** — mark `gap-phase2-perf-wrk-soak` and `gap-phase2-streaming-wrk` `completed` in httpd plan YAML **iff** gates green.
4. **Registry + issue hygiene** — re-ingest; close #477; hand off `swarm_observer`.
5. **Master-plan note** — draft partial-row update for Phase H (human PR; do not self-merge).

### Out of scope

- New httpd product features beyond passing existing gates
- Registry ingest reconcile logic (#471 — tracked separately; required before final close)
- M1 `.li` gateway blocked-by plan (separate PH-H track)
- Product code unless gate failure assigns fix todos to `code_implementer`

## Implementation phases

### Phase 0 — Preflight (read-only)

| Step | Command / check | Pass criteria |
|------|-----------------|---------------|
| 0.1 | `./scripts/build-li-httpd.sh` | `build/li-httpd` executable |
| 0.2 | Confirm `nginx` + `wrk` on PATH | Required for timing gates |
| 0.3 | Read snapshot httpd block | Record `plan_pending`, `active_todo_id`, last `history` exit codes |
| 0.4 | `python3 scripts/swarm-gap-ingest.py --dry-run` | Exit 0; registry YAML valid |
| 0.5 | Verify branch `cursor/httpd-plan-continue` head | Matches or supersedes `fbc69f07` evidence |

### Phase 1 — Supervisor restart (orchestrator)

Unstick the plan loop so it targets **only** the two pending phase2 todos:

```bash
export LIC_ROOT="$(pwd)"
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-../benchmarks}"
export HTTPD_PLAN_PR_BRANCH=cursor/httpd-plan-continue
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_RUN_PHASE2_GATES=1
export LI_HTTPD_PLAN_AGENT=code_implementer
export LI_HTTPD_PLAN_AGENT_TIMEOUT_SEC=5400   # wrk soak needs headroom vs 124 timeout

# Option A: single batch targeting pending todos
./scripts/httpd-plan-loop.sh --max 2 --todo gap-phase2-perf-wrk-soak
./scripts/httpd-plan-loop.sh --max 2 --todo gap-phase2-streaming-wrk

# Option B: until-deadline driver (overnight)
./scripts/httpd-plan-until-deadline.sh
```

| Check | Pass criteria |
|-------|---------------|
| Supervisor log freshness | `data/httpd-plan-loop/` log updated within last batch window |
| `state.json` / snapshot | `active_todo_id` advances or completes; no perpetual `supervisor idle` |
| Exit 124 | Treat as **fail** — increase timeout or fix gate hang; do not mark complete |

Gate-only path (no agent) when infra is ready:

```bash
export HTTPD_BENCH_SKIP_TIMING=0
export HTTPD_BENCH_DURATION_SEC=30
./scripts/check-tier5-perf-wrk-soak.sh
./scripts/check-tier5-streaming-soak.sh
```

Optional full hook: `HTTPD_RUN_PHASE2_GATES=1 ./scripts/httpd-plan-gates.sh`

### Phase 2 — Gate verification (truth source)

Run with **`HTTPD_BENCH_SKIP_TIMING=0`** (gate scripts set this internally):

| todo_id | Gate script | Scenarios |
|---------|-------------|-----------|
| `gap-phase2-perf-wrk-soak` | `check-tier5-perf-wrk-soak.sh` | parity + parity_streaming + nextjs; ≥30s wrk vs nginx |
| `gap-phase2-streaming-wrk` | `check-tier5-streaming-soak.sh` | SSE `sse_long_stream` + WS `ws_fanout` with timing |

| Outcome | Action |
|---------|--------|
| **Both green** | Mark todos `completed` in [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md); archive logs under `data/httpd-plan-loop/` |
| **Either fails** | Keep todos `pending`; attach gate log to #477; assign `code_implementer` if runtime fix needed |
| **Pre-soak fail** (nightly pattern) | Fix nginx/wrk/benchmarks harness before re-run; do not skip timing |

### Phase 3 — Registry + issue close

After gates green:

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
```

| Artifact | Expected |
|----------|----------|
| Snapshot `httpd.plan_pending` | `[]` |
| Registry `gap-plan-pending-httpd-gap-phase2-*` | `status: closed` |
| Issue **#477** | Closed with gate log links |
| `benchmarks/data/latest/swarm-gap-actions.json` | 0 open httpd phase2 `plan_debt` |

Handoff **`swarm_observer`** with ingest stats + north_star_fit.

### Phase 4 — Master-plan partial row (human merge)

Draft only — **do not self-merge**:

- Update Phase H row in [2026-05-14-li-master-plan.md](2026-05-14-li-master-plan.md): note phase2 wrk gates green, 10/10 httpd todos complete.
- Reference gate log artifact paths and nightly workflow green run.
- Separate human PR after #477 close.

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **PH-H** | Proved agent HTTP gateway | [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md) phase2 todos |
| **PH-H-httpd** | Perf after proof — wrk vs nginx | `check-tier5-perf-wrk-soak.sh`, `check-tier5-streaming-soak.sh` |
| **REQ-httpd-phase2-timing** | ≥30s wrk soak, no skip timing | `HTTPD_BENCH_SKIP_TIMING=0` |
| **G-net** | tier5 harness parity | `benchmarks/tier5_http/` via regression gate |
| **G-swarm-plan-debt** | Registry matches snapshot | ingest + apply-actions after gate pass |
| **CI** | Nightly phase2 | `.github/workflows/httpd-phase2-nightly.yml` |

## Files touched (implement pass)

| Path | Change |
|------|--------|
| `docs/superpowers/plans/2026-05-16-li-httpd-plan.md` | Todo status → `completed` if gates green |
| `data/goal-directed-agents/snapshot.json` | Updated by plan-loop |
| `data/swarm-gap-registry/registry.yaml` | Re-ingest output |
| `data/httpd-plan-loop/*.log` | Gate + supervisor logs (archived) |
| `docs/superpowers/plans/2026-05-14-li-master-plan.md` | Phase H partial row (human PR) |

## Learned from

1. [2026-05-16-li-httpd-plan.md](2026-05-16-li-httpd-plan.md) — phase2 todo definitions (`gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk`)
2. [2026-05-24-httpd-gap-phase2.md](../../release-notes/2026-05-24-httpd-gap-phase2.md) — phase2 gate wiring and nightly workflow
3. [2026-06-01-ph-h-httpd-reconcile-477-619.md](2026-06-01-ph-h-httpd-reconcile-477-619.md) — registry/snapshot drift lessons (#619, #471)
4. [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — proof before perf pillar order

## Acceptance criteria (plan-approved → implement)

- [ ] Supervisor log fresh; loop advances or completes both pending todos
- [ ] Gate logs archived with `HTTPD_BENCH_SKIP_TIMING=0` for both scripts
- [ ] Snapshot `httpd.plan_pending` empty **iff** gates passed
- [ ] #477 closed with evidence or kept open with failing log (no silent drift)
- [ ] Registry rows closed via ingest after gate pass
- [ ] `swarm_observer` handoff with **north_star_fit:** web/agent gateway, PH-H, PH-H-httpd
- [ ] Master-plan Phase H draft prepared; merged by human only

## Handoffs

| Agent | Trigger |
|-------|---------|
| `code_implementer` | Gate failure requires httpd/runtime or harness fix |
| `swarm_observer` | After ingest + apply-actions post-gate |
| `plan_verifier` | Re-audit snapshot vs registry after close |
