---
workflow_repo: lic
ph_ids: [PH-DB-1, PH-DB-3, PH-DB-4, PH-DB-5, PH-DB-10]
tracker: docs/superpowers/plans/ph-db-execution-tracker.md
status_doc: roadmap/docs/ecosystem/ph-db-status.md
---

# PH-DB swarm plan (native Li data platform)

Cross-repo integration tracked for the **goal-directed agents canvas** (`goal-directed-agents-snapshot.py`).

| Repo | Branch | Tip (local 2026-05-30) |
|------|--------|-------------------------|
| `lidb` | `feat/ph-db-native-embed-wp-a` | native embed, JOIN, registry bench, WSL verify |
| `lis` | `feat/ph-db-3-lis-db-native` | `lis db` native, docker-compose, registry rows |
| `benchmarks` | `feat/ph-db-5-registry-compare` | compare manifest + nightly Postgres workflow |
| `li-cursor-agents` | `feat/ph-db-10-native-persist` | default `lidb`, bridge fix, e2e, self-unblock skills |

todos:
- id: wp-a-engine-native
  content: "WP-A lidb native embed + liorm.execute + security/bench harness (lidb feat/ph-db-native-embed-wp-a)"
  status: completed
- id: wp-b-lis-db
  content: "WP-B lis db native embed + LiormRegistryStore rows + docker-compose.ph-db.yml (lis feat/ph-db-3-lis-db-native)"
  status: completed
- id: wp-c-registry-bench
  content: "WP-C tier_db_registry lidb P95 harness + compare manifest (benchmarks feat/ph-db-5-registry-compare)"
  status: completed
- id: wp-e-control-plane
  content: "WP-E control-plane persist on lidb + test:e2e:lidb-engine 10/10 + agent-self-unblock skills (li-cursor-agents feat/ph-db-10-native-persist)"
  status: completed
- id: wp-g-ci-cross-repo
  content: "WP-G lidb-engine-e2e CI job on agents PR (partial — merge PR required)"
  status: pending
- id: wp-h-containers
  content: "WP-H docker-compose.ph-db.yml + Dockerfile.supervisor (on branch — compose smoke not in CI yet)"
  status: pending
- id: wp-k-postgres-nightly
  content: "WP-K nightly Postgres P95 compare GHA + honest ratio_vs_postgres (workflow on branch; needs merge + first green run)"
  status: pending
- id: wp-pr-merge-wave
  content: "Open PRs + merge four feat/ph-db-* branches across lidb/lis/benchmarks/li-cursor-agents"
  status: pending
- id: wp-h0-default-main
  content: "WP-H0 lidb default branch → main (lidb/scripts/set-default-branch-main.sh + gh admin)"
  status: pending
- id: wp-n3-realtime
  content: "WP-N3 merge lis#10 realtime changefeed WebSocket"
  status: pending
- id: wp-n5-security-bench
  content: "WP-N5 merge benchmarks#96 tier_db_security → lidb harness"
  status: pending
- id: wp-d-registry-v2
  content: "WP-D registry schema v2 + lip OpenAPI parity (PH-8d-v2 human sign-off)"
  status: pending
- id: wp-prod-lidb-default
  content: "Production flip LI_CONTROL_PLANE_STORE=lidb (human sign-off after Phase 3 gates)"
  status: pending

## Completion gate

```bash
# WSL verify (workspace root with sibling repos)
bash scripts/verify-ph-db-wsl.sh
test -f ../benchmarks/data/latest/tier-db-registry.json
grep -q '"engine_mode": "lidb' ../benchmarks/data/latest/tier-db-registry.json
# Human gates
# gh repo view li-langverse/lidb --json defaultBranchRef | jq -r '.defaultBranchRef.name' | grep -x main
```

---
