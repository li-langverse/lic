---
workflow_repo: lic
ph_ids: [PH-DB-11]
predecessor: docs/superpowers/plans/ph-db-swarm-plan.md
tracker: docs/superpowers/plans/ph-db-execution-tracker.md
loop_state: data/ph-studio-plan-loop/state.json
implementation_repo: lis
implementation_path: data-studio-ui/
status: complete
---

# PH-DB-11 — Li Data Studio (Supabase Studio parity)

**Epic:** Browser console for the native Li data platform (`lidb` + `lis db`), aligned with [Supabase Studio](https://supabase.com/docs/guides/platform/studio) information architecture.

**Prerequisite (complete):** PH-DB swarm 13/13 — `lidb` on `main`, `lis` compose + `lis db start`, registry OLTP.

| Repo | Branch | Deliverable |
|------|--------|-------------|
| `lic` | `cursor/ph-db-11-li-data-studio` | Plans, plan-loop state, cross-links |
| `lis` | `feat/ph-db-11-data-studio-ui` | `data-studio-ui/` Next.js console |

## Workpackages (WP-S1 … WP-S5)

| WP | ID | Supabase Studio tab | Status |
|:--:|----|---------------------|--------|
| **S1** | `wp-s1-shell` | Shell + Database overview | complete |
| **S2** | `wp-s2-table-editor` | Database → Tables (read-only) | complete |
| **S3** | `wp-s3-sql-editor` | SQL Editor | complete |
| **S4** | `wp-s4-auth-studio` | Authentication | complete (registry-min) |
| **S5** | `wp-s5-realtime-logs-storage` | Realtime, Logs, Storage, Settings | complete |

## Exit gates

| WP | Gate | Result |
|----|------|--------|
| S1 | `npm run build`; `/database` status | pass |
| S2 | Catalog table list + row viewer | pass |
| S3 | SQL run + CSV export | pass |
| S4 | Registry health + packages | pass |
| S5 | Realtime/log/settings panels | pass |

## Plan loop

- State: [data/ph-studio-plan-loop/state.json](../../../data/ph-studio-plan-loop/state.json)
- Driver: [scripts/ph-studio-plan-loop.py](../../../scripts/ph-studio-plan-loop.py)

todos:
- id: wp-s1-shell
  content: "WP-S1 Studio shell, Supabase IA nav, Database status from lis db status"
  status: completed
- id: wp-s2-table-editor
  content: "WP-S2 Database table browser + row viewer"
  status: completed
- id: wp-s3-sql-editor
  content: "WP-S3 SQL editor with liorm-backed execution"
  status: completed
- id: wp-s4-auth-studio
  content: "WP-S4 Auth studio (providers, users stub)"
  status: completed
- id: wp-s5-realtime-logs-storage
  content: "WP-S5 Realtime, Logs, Storage, Settings panels"
  status: completed

---
