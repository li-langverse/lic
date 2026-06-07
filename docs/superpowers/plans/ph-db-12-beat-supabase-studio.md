---
workflow_repo: lic
ph_ids: [PH-DB-12]
predecessor: docs/superpowers/plans/ph-db-11-li-data-studio.md
tracker: docs/superpowers/plans/ph-db-execution-tracker.md
loop_state: data/ph-studio-beat/state.json
implementation_repo: lis
implementation_path: data-studio-ui/
status: in_progress
---

# PH-DB-12 — Beat Supabase Studio

**Epic:** Go beyond Supabase Studio parity with agent-native, proof-first, keyboard-first Li Data Studio.

**Prerequisite (complete):** PH-DB-11 — `lis/data-studio-ui` S1–S5 merged (lis#36).

| Repo | Branch | Deliverable |
|------|--------|-------------|
| `lic` | `cursor/ph-db-12-beat-supabase-studio` | Plan, beat loop state |
| `lis` | `feat/ph-db-12-beat-supabase-studio` | B1/B2/B4/B6 shipped; B3/B5 planned |

## Beat differentiators vs Supabase Studio

1. **Agent-native command center** — live trace + cancel path (B2)
2. **Proof-first actions** — lic check / gate status inline (B3)
3. **Cross-link runs ↔ code ↔ PRs** — run drawer (B5)
4. **Keyboard-first ⌘K palette** — studio-wide (B1)
5. **Unified ops home** — status cards like Supabase project home (B6)
6. **Control-plane table browser** — agent_runs, events (B4)
7. **Honest degraded modes** — recovery steps when dashboard/lidb down
8. **Local-first** — auto-connect when lis db native

## Workpackages (WP-B1 … WP-B6)

| WP | ID | Feature | Status |
|:--:|----|---------|--------|
| **B1** | `wp-b1-command-palette` | ⌘K command palette + keyboard nav | **complete** |
| **B2** | `wp-b2-agent-trace` | Agent trace panel (proxy :9477) | **complete** (lite) |
| **B3** | `wp-b3-proof-gate` | Proof gate banner on settings/actions | planned |
| **B4** | `wp-b4-control-plane` | Control-plane table browser | **complete** |
| **B5** | `wp-b5-run-drawer` | Run drawer: PR URL, briefing hash, diff links | planned |
| **B6** | `wp-b6-home-dashboard` | Unified project home status cards | **complete** |

## Exit gates

| WP | Gate | Result |
|----|------|--------|
| B1 | ⌘K opens palette; arrow keys + Enter navigate | pass |
| B2 | `/agents` shows live runs or degraded recovery | pass |
| B4 | Control-plane tables filter + read-only rows | pass |
| B6 | `/` home cards for db/registry/realtime/agents | pass |
| all | `npm run build` in data-studio-ui | pass |

## Plan loop

- State: [data/ph-studio-beat/state.json](../../../data/ph-studio-beat/state.json)
- Predecessor loop: [data/ph-studio-plan-loop/state.json](../../../data/ph-studio-plan-loop/state.json)

todos:
- id: wp-b1-command-palette
  content: "WP-B1 ⌘K command palette + keyboard nav"
  status: completed
- id: wp-b2-agent-trace
  content: "WP-B2 Agent trace panel via dashboard proxy"
  status: completed
- id: wp-b3-proof-gate
  content: "WP-B3 Proof gate banner (lic build/check status)"
  status: pending
- id: wp-b4-control-plane
  content: "WP-B4 Control-plane table browser (agent_runs, events)"
  status: completed
- id: wp-b5-run-drawer
  content: "WP-B5 Run drawer with PR URL, briefing hash, diff links"
  status: pending
- id: wp-b6-home-dashboard
  content: "WP-B6 Unified home dashboard status cards"
  status: completed

---
