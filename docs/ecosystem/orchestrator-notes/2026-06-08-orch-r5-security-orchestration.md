# Orchestrator note — `orch-r5-security-orchestration`

**Date:** 2026-06-08  
**Agent:** `swarm_observer`  
**Research goal:** `swarm_coverage` (north_star_fit: ecosystem, ai)  
**Dimension:** `security`  
**Worker:** `6e6c35b8`  
**Work item:** Reconcile security plan_debt gaps; route CWE catalog + offensive_security handoffs

---

## Executive summary

| Field | Value |
|-------|-------|
| Swarm posture | **Degraded** — grade **D** (66.3); `unattended_safe: false` |
| Security gaps (open) | **3** plan_debt (`sec-r1`…`sec-r3`) + **1** ph-db (`wp-n5-security-bench`) |
| CWE catalog | **19/25** Top-25 missing in `cve-catalog.json` (feed sync OK @ 2026-06-08) |
| Gap apply pipeline | **Blocked** — ingest syntax fixed; PyYAML missing in runner |
| Unattended? | **No** — security_auditor + human catalog review required |

Evidence: `benchmarks/data/latest/ecosystem-quality-report.json`, `security-cwe-feed.json`, `swarm-gap-actions.json`.

---

## Security plan_debt reconciliation

| Registry id | Backlog todo | Apply patch | Handoff |
|-------------|--------------|-------------|---------|
| `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` | `sec-r1-httpd-fuzz-smoke` | pending in `security-research-backlog.md` | `security_auditor` |
| `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` | `sec-r2-tier5-gap-exploit` | pending | `security_auditor` |
| `gap-plan-pending-security-research-sec-r3-runtime-surface` | `sec-r3-runtime-surface` | pending | `security_auditor` |
| `gap-plan-pending-ph-db-wp-n5-security-bench` | `wp-n5-security-bench` | deferred (no runner backlog mapping) | `issue_planner` |

**Completed in registry:** `sec-r0-cwe-delta` (CWE feed sync baseline).

Related httpd security todos (`gap-phase2-mitigation-exploits`, tier5 exploit rows) are **completed** on httpd runner per snapshot — sec-r2 extends remaining nginx_mitigations.toml rows.

---

## CWE Top-25 → catalog gap matrix (summary)

Feed: `benchmarks/data/latest/security-cwe-feed.json`  
Catalog: `lic/security/cve-catalog.json` (15 CWE classes represented)

| Priority | CWE classes (sample) | Li surface | Action |
|----------|---------------------|------------|--------|
| P0 | CWE-79, CWE-89, CWE-20 | httpd parse, SQL-adjacent APIs | Map to tier5 + catalog rows |
| P0 | CWE-22, CWE-434, CWE-502 | file/path ingest, upload limits | httpd body limits + parser gates |
| P1 | CWE-352, CWE-287, CWE-306 | session/auth headers | httpd auth middleware audit |
| P1 | CWE-119, CWE-77, CWE-94 | runtime C surface | sec-r3 runtime surface study |

**Do not** disable provability gates when closing sec-r3 — runtime audits must cite PH ids and defer `trusted.lean` to human issues.

---

## Scripts status

```bash
cd lic
python3 scripts/swarm-gap-ingest.py    # SyntaxError line 229 FIXED 2026-06-08
python3 scripts/swarm-gap-apply-actions.py  # BLOCKED: PyYAML required
```

Prior apply snapshot @ 2026-05-31 still authoritative for backlog patches until re-run succeeds.

---

## Swarm routing (no new systemd loops)

| Next agent | Reason |
|------------|--------|
| `security_auditor` | Goal `offensive_security`; execute sec-r1…sec-r3 from backlog |
| `issue_planner` | Open lic issues for 19 CWE catalog gaps + ph-db security bench |
| `pr_merger` | lip#52 deps bump (gate-ready) |
| `ci_maintainer` | 12 repos missing CI — platform hygiene blocks security workflow rollout |
| `gap_explorer` | Re-ingest after PyYAML bake; competitor/security stub honesty |

Research goals unchanged in `li-cursor-agents/config/research-goals.yaml`:
- `swarm_coverage` → `swarm_observer` (this note)
- `offensive_security` → `security_auditor` (execution lane)

---

## Registry plan-debt row

Add to `swarm-observer-plan-backlog.md`:

```yaml
- id: orch-r5-security-orchestration
  content: "Reconcile sec-r1…sec-r3 + CWE catalog gaps; handoff security_auditor"
  status: completed
```

Close `gap-plan-pending-swarm-observer-orch-r5-security-orchestration` on next ingest after snapshot records completion.

---

## Human-only

- CVE catalog expansion merges require security review — no auto-merge.
- httpd fuzz + tier5 exploit benches may touch runtime — proof certificate must remain green.
- lis registry PRs (#40–42) failing CI — blocks edge security smoke.

---

## Evidence paths

- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/security-research-backlog.md`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `li-cursor-agents/data/runs/swarm_observer-1780885450088.md`
- `lic/docs/research/swarm_coverage/security/2026-06-08-whitepaper-6e6c35b8.md`
