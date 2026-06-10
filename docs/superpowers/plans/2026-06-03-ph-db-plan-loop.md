---
name: PH-DB cross-repo plan loop
overview: Autonomous supervisor for Wave 3 PH-DB workpackages (CI, containers, merges, prod gates) across lidb, lis, benchmarks, and li-cursor-agents. Proof-before-perf; no fake-green bench rows.
workflow_repo: lic
ph_ids: [PH-DB, PH-DB-1, PH-DB-3, PH-DB-4, PH-DB-5, PH-DB-10]
req_ids: [REQ-db-registry, REQ-control-plane-lidb]
gap_ids: [G-proof-db]
tracker: docs/superpowers/plans/ph-db-execution-tracker.md
battle_plan: docs/superpowers/plans/ph-db-battle-plan.md
ci_hosting: docs/superpowers/plans/ph-db-ci-hosting-plan.md
swarm_canvas: docs/superpowers/plans/ph-db-swarm-plan.md
orchestrator: docs/ecosystem/orchestrator-notes/2026-06-03-orch-ph-db-backlog-mapping.md
branch: cursor/ph-db-plan-loop
gates_script: scripts/ph-db-plan-gates.sh
loop_script: scripts/ph-db-plan-loop.py
state_dir: data/ph-db-plan-loop
isProject: false
todos:
  - id: wp-a-engine-native
    content: "WP-A lidb native embed + liorm.execute + security/bench harness"
    status: completed
    owner_agent: code_implementer
    workflow_repo: lidb
  - id: wp-b-lis-db
    content: "WP-B lis db native embed + LiormRegistryStore + registry-min profile"
    status: completed
    owner_agent: code_implementer
    workflow_repo: lis
  - id: wp-c-registry-bench
    content: "WP-C tier_db_registry lidb P95 harness + honest compare manifest"
    status: completed
    owner_agent: bench_improver
    workflow_repo: benchmarks
  - id: wp-e-control-plane
    content: "WP-E control-plane persist on lidb + test:e2e:lidb-engine green"
    status: completed
    owner_agent: code_implementer
    workflow_repo: li-cursor-agents
  - id: wp-g-ci-cross-repo
    content: "WP-G cross-repo CI — lidb-engine-e2e on agents PRs + lidb/lis smoke signals"
    status: completed
    owner_agent: ci_maintainer
    workflow_repo: li-cursor-agents
  - id: wp-h-containers
    content: "WP-H docker-compose.ph-db.yml + GHA compose smoke on lis"
    status: pending
    owner_agent: code_implementer
    workflow_repo: lis
  - id: wp-k-postgres-nightly
    content: "WP-K nightly Postgres P95 compare GHA + honest ratio_vs_postgres"
    status: completed
    owner_agent: ci_maintainer
    workflow_repo: benchmarks
  - id: wp-pr-merge-wave
    content: "Merge remaining feat/ph-db-* PRs across sibling repos"
    status: completed
    owner_agent: pr_merger
    workflow_repo: lic
  - id: wp-h0-default-main
    content: "WP-H0 lidb default branch → main (gh admin + set-default-branch-main.sh)"
    status: completed
    owner_agent: ci_maintainer
    workflow_repo: lidb
  - id: wp-n3-realtime
    content: "WP-N3 lis realtime changefeed (lis#10) merged"
    status: completed
    owner_agent: code_implementer
    workflow_repo: lis
  - id: wp-n5-security-bench
    content: "WP-N5 benchmarks tier_db_security → lidb harness"
    status: completed
    owner_agent: bench_improver
    workflow_repo: benchmarks
  - id: wp-d-registry-v2
    content: "WP-D registry schema v2 + lip OpenAPI parity (PH-8d-v2 human sign-off)"
    status: completed
    owner_agent: issue_planner
    workflow_repo: lidb
  - id: wp-prod-lidb-default
    content: "Production LI_CONTROL_PLANE_STORE=lidb (human sign-off after Phase 3 gates)"
    status: pending
    owner_agent: human
    workflow_repo: li-cursor-agents
---

# PH-DB plan loop (supervisor YAML)

**Issue:** [lic#576](https://github.com/li-langverse/lic/issues/576) · **Related:** [lic#423](https://github.com/li-langverse/lic/issues/423) (battle-plan gate audit)

**North star fit:** Database / control-plane pillar under **PH-DB** — provable agent read paths (`liq`), embedded **lidb** for registry + control-plane, honest **tier_db_registry** vs Postgres oracle. Pillar order: proof (security harness, schema parity) → easy (`lis db`) → fast (P95 compare only after measured).

## Problem (2026-05-30 verifier)

`goal-directed-agents/snapshot.json` runner **ph-db** reported nine `plan_pending` todos and `state.note: no YAML plan-loop yet` because:

1. Canvas todos lived only in [ph-db-swarm-plan.md](./ph-db-swarm-plan.md) without a **supervisor plan-loop** doc + runner script on `main`.
2. `swarm-gap-apply-actions.py` had **no `ph-db` backlog mapping**, so `gap-plan-pending-ph-db-wp-*` registry rows could not auto-patch todos.
3. Ad-hoc `data/ph-db-plan-loop/` overnight runs referenced missing `scripts/ph-db-plan-gates.sh`.

This document is the **canonical YAML plan-loop** for the ph-db runner. [ph-db-swarm-plan.md](./ph-db-swarm-plan.md) remains the dashboard canvas; keep both in sync when closing todos.

## Supervisor wiring

| Component | Path |
|-----------|------|
| Plan loop (this file) | `docs/superpowers/plans/2026-06-03-ph-db-plan-loop.md` |
| Loop script | `scripts/ph-db-plan-loop.py` |
| Gates | `scripts/ph-db-plan-gates.sh` |
| WSL / local verify wrapper | `scripts/verify-ph-db-wsl.sh` |
| State | `data/ph-db-plan-loop/state.json` |
| Snapshot runner id | `ph-db` in `scripts/goal-directed-agents-snapshot.py` |
| Async swarm goal | `li-cursor-agents/config/implement-goals.yaml` → `ph_db_sprint` |
| Gap apply backlog | `swarm-gap-apply-actions.py` → `RUNNER_BACKLOGS["ph-db"]` |

**Do not** install retired `li-ph-db-plan-loop.service` systemd units. Use async swarm + `goal-directed-loop.sh` per [swarm-architecture.md](../../ecosystem/swarm-architecture.md).

## Agent routing (wp-* → owner)

| todo_id | Owner agent | workflow_repo | Branch / issue | Registry id |
|---------|-------------|---------------|----------------|-------------|
| wp-g-ci-cross-repo | `ci_maintainer` | `li-cursor-agents` | `cursor/wp-g-ph-db-ci-cross-repo` | `gap-plan-pending-ph-db-wp-g-ci-cross-repo` |
| wp-h-containers | `code_implementer` | `lis` | `cursor/wp-h-ph-db-containers` | `gap-plan-pending-ph-db-wp-h-containers` |
| wp-k-postgres-nightly | `ci_maintainer` | `benchmarks` | `cursor/wp-k-ph-db-bench-postgres-ci` | `gap-plan-pending-ph-db-wp-k-postgres-nightly` |
| wp-pr-merge-wave | `pr_merger` | `lic` (coordination) | open feat/ph-db-* PRs | `gap-plan-pending-ph-db-wp-pr-merge-wave` |
| wp-h0-default-main | `ci_maintainer` | `lidb` | `scripts/set-default-branch-main.sh` | `gap-plan-pending-ph-db-wp-h0-default-main` |
| wp-n3-realtime | `code_implementer` | `lis` | [lis#10](https://github.com/li-langverse/lis/issues/10) | `gap-plan-pending-ph-db-wp-n3-realtime` |
| wp-n5-security-bench | `bench_improver` | `benchmarks` | [benchmarks#96](https://github.com/li-langverse/benchmarks/issues/96) | `gap-plan-pending-ph-db-wp-n5-security-bench` |
| wp-d-registry-v2 | `issue_planner` + **human** | `lidb`, `lip` | PH-8d-v2 sign-off | `gap-plan-pending-ph-db-wp-d-registry-v2` |
| wp-prod-lidb-default | **human only** | `li-cursor-agents` | after Phase 3 exit | `gap-plan-pending-ph-db-wp-prod-lidb-default` |

Completed engine WPs (A, B, C, E) stay **completed**; do not re-open unless regression.

## Open work (2 todos)

1. **wp-h-containers** — `lis/docker/Dockerfile.supervisor`, root `docker-compose.ph-db.yml`, GHA job `compose-smoke` (no new `schedule:` cron; use `workflow_dispatch` + PR path filters).
2. **wp-prod-lidb-default** — human flip `LI_CONTROL_PLANE_STORE=lidb` in production profiles after WP-H + WP-K + security bench verified on `main`.

## Completion gate

```bash
bash scripts/ph-db-plan-gates.sh
# Optional full cross-repo (WSL/Linux siblings):
bash scripts/verify-ph-db-wsl.sh
```

Registry hygiene after each todo closes:

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
python3 scripts/swarm-gap-apply-actions.py
python3 scripts/goal-directed-agents-snapshot.py
```

## Learned from

- [ph-db-battle-plan.md](./ph-db-battle-plan.md) — parallel WP-A…F engine execution
- [ph-db-ci-hosting-plan.md](./ph-db-ci-hosting-plan.md) — Wave 3 CI/containers/hosting ladder
- [lidb-migration-control-plane.md](https://github.com/li-langverse/li-cursor-agents/blob/main/docs/plans/lidb-migration-control-plane.md) — PH-DB-10 store/MCP/security gates
- [2026-05-25-orch-r1-plan-debt-sync.md](../../ecosystem/orchestrator-notes/2026-05-25-orch-r1-plan-debt-sync.md) — plan_debt → backlog patch pattern

## Tests / benches / PH tracker

| Artifact | When updated |
|----------|----------------|
| `PH-DB` row in [2026-05-14-li-master-plan.md](./2026-05-14-li-master-plan.md) | Human after wp-prod-lidb-default |
| `tier_db_registry` ingest | WP-C / WP-K — honest `unknown` until Postgres oracle |
| `lidb/tests/security/run_all.sh` | WP-A / WP-N5 |
| `li-cursor-agents` `test:e2e:lidb-engine` | WP-E / WP-G |
| **G-proof-db** | Partial until prod store flip + battle-plan gates close ([#423](https://github.com/li-langverse/lic/issues/423)) |

---
