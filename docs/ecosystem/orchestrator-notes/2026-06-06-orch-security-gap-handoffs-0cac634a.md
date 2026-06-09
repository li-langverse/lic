# Orchestrator note — security gap handoffs (`swarm_coverage@security`)

**Date:** 2026-06-06  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai — secure pillar)  
**Supervisor worker:** `0cac634a`  
**Work item:** Reconcile security `plan_debt` gaps; route `sec-r1`–`sec-r3` via research lane

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded (recoverable)** — grade **C (73.6)**; `unattended_safe: false` |
| Security P0 | **19/25 Top25 CWEs** missing from `cve-catalog.json` |
| Security backlog | **`sec-r1`–`sec-r3` pending** — runner supervisor off since 2026-05-25 |
| Gap apply | **Green** — security todos patched in `security-research-backlog.md` |
| Ingest fix | **`BENCHMARKS_COMPETITIVE` Path fallback** + PyYAML in runner |
| Unattended? | **No** — human-gated catalog + CI wave + stopped security runner |

Programmatic prep: `lic/scripts/swarm-gap-ingest.py` + `lic/scripts/swarm-gap-apply-actions.py` @ 2026-06-06 (after ingest fix + `python3-yaml`).

---

## Security `plan_debt` reconciliation

| Registry id | Backlog todo | Apply patch | Handoff |
|-------------|--------------|-------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending in `security-research-backlog.md` | `security_auditor` / `offensive_security` |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | same |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | same |

Closed in registry: `gap-plan-pending-security-research-sec-r0-cwe-delta` (feed sync complete).

**CWE signal (not a registry row):** `benchmarks/data/latest/security-cwe-feed.json` — catalog has 15 CWEs; Top25 missing 19. Route to `security_auditor` + human PR on `lic/security/cve-catalog.json`.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `security_auditor` | `offensive_security` goal → execute `sec-r1-httpd-fuzz-smoke` (httpd fuzz / tier5 smoke) |
| `issue_planner` | Open issues for catalog gaps (19 CWE rows) with `security` label |
| `ci_maintainer` | Unblock metrics PR CI; 3 repos 404 in org audit |
| `gap_explorer` | 64 open registry rows after catalog PRs land |

Do **not** restart `security-research-plan-loop` systemd; use async swarm per `docs/ecosystem/swarm-architecture.md`.

---

## Scripts executed

```bash
apt-get install -y python3-yaml
cd lic
python3 scripts/swarm-gap-ingest.py    # registry 92 rows
python3 scripts/swarm-gap-apply-actions.py
# wrote benchmarks/data/latest/swarm-gap-actions.json
cd ../benchmarks
LI_CURSOR_AGENTS_ROOT=/app python3 scripts/ecosystem-quality-grade.py
```

---

## Human-only

- Expand `cve-catalog.json` for Top25 coverage (governance PR).
- Merge benchmarks metrics refresh PRs after CI green.
- Product fuzz harness changes in `lic` — review before merge.

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/data/goal-directed-agents/snapshot.json` (runner `security-research`)
- `/app/data/runs/swarm_observer-1780727084886.md`
- `lic/docs/research/swarm_coverage/security/2026-06-06-whitepaper.md`
