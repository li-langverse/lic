---
workflow_repo: lic
ph_ids: [PH-DB-1, PH-DB-3, PH-DB-4, PH-DB-5, PH-DB-10]
tracker: docs/superpowers/plans/ph-db-execution-tracker.md
status_doc: roadmap/docs/ecosystem/ph-db-status.md
---

# PH-DB swarm plan (native Li data platform)

| Repo | Branch | Tip (2026-05-31) |
|------|--------|------------------|
| `lidb` | `main` | native embed, JOIN, registry bench |
| `lis` | `main` | lis db native, docker-compose (#24) |
| `benchmarks` | `main` | nightly Postgres compare (#202) |
| `li-cursor-agents` | `main` | default lidb, e2e (#42) |

todos:
- id: wp-a-engine-native
  content: "WP-A lidb native embed + liorm.execute + security/bench harness"
  status: completed
- id: wp-b-lis-db
  content: "WP-B lis db native embed + LiormRegistryStore rows + docker-compose.ph-db.yml"
  status: completed
- id: wp-c-registry-bench
  content: "WP-C tier_db_registry lidb P95 harness + compare manifest"
  status: completed
- id: wp-e-control-plane
  content: "WP-E control-plane persist on lidb + test:e2e:lidb-engine 10/10"
  status: completed
- id: wp-g-ci-cross-repo
  content: "WP-G lidb-engine-e2e CI on li-cursor-agents#42"
  status: completed
- id: wp-h-containers
  content: "WP-H docker-compose.ph-db.yml + GHA compose smoke on lis"
  status: pending
- id: wp-k-postgres-nightly
  content: "WP-K nightly Postgres P95 compare GHA green"
  status: completed
- id: wp-pr-merge-wave
  content: "Merge feat/ph-db-* branches across repos"
  status: completed
- id: wp-h0-default-main
  content: "WP-H0 lidb default branch main"
  status: completed
- id: wp-n3-realtime
  content: "WP-N3 lis#10 realtime changefeed"
  status: completed
- id: wp-n5-security-bench
  content: "WP-N5 benchmarks#96 tier_db_security"
  status: completed
- id: wp-d-registry-v2
  content: "WP-D registry schema v2 + lip OpenAPI (human sign-off)"
  status: completed
- id: wp-prod-lidb-default
  content: "Production LI_CONTROL_PLANE_STORE=lidb (human sign-off)"
  status: pending

## Completion gate

```bash
bash scripts/verify-ph-db-wsl.sh
test -f ../benchmarks/data/latest/tier-db-registry.json
grep -q '"engine_mode": "lidb' ../benchmarks/data/latest/tier-db-registry.json
```

---
