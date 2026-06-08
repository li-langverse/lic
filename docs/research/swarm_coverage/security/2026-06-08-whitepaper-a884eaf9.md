# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `a884eaf9`  
**Date:** 2026-06-08  
**north_star_fit:** ecosystem, ai — secure, provable swarm control plane  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`

---

## Abstract

This pass audits swarm gap orchestration through a **security lens**: whether security-related plan debt is routed, whether CWE/catalog signals reach agents, and whether gap-ingest tooling is trustworthy. The swarm is **degraded** (grade D); security work is **queued but not executing** because ingest is blocked and `security_cwe_audit` was skipped in preflight.

---

## 1. CWE catalog vs MITRE Top-25

**Source:** `/workspace/benchmarks/data/latest/security-cwe-feed.json` (synced 2026-06-08T22:18Z)

| Metric | Value |
|--------|-------|
| Catalog CWE count | 15 |
| Top-25 tracked | 25 |
| Missing in catalog | **19** |
| New vs previous sync | 0 |

Representative gaps: CWE-79 (XSS), CWE-89 (SQLi), CWE-20 (input validation), CWE-352 (CSRF), CWE-798 (hard-coded credentials).

**Implication:** Briefing correctly elevates `security_auditor` (P0). Catalog expansion is a **human-governed** issue set — not auto-mergeable. Route to `issue_planner` with labels `security`, `cwe-top25`.

---

## 2. Security-research plan_debt

**Backlog:** `/workspace/lic/docs/ecosystem/security-research-backlog.md`

| Todo | Status | Gap registry id |
|------|--------|-----------------|
| `sec-r0-cwe-delta` | completed | closed in registry |
| `sec-r1-httpd-fuzz-smoke` | pending | `gap-plan-pending-security-research-sec-r1-httpd-fuzz-smoke` |
| `sec-r2-tier5-gap-exploit` | pending | `gap-plan-pending-security-research-sec-r2-tier5-gap-exploit` |
| `sec-r3-runtime-surface` | pending | `gap-plan-pending-security-research-sec-r3-runtime-surface` |

Apply pipeline patched these rows on 2026-05-31 (`swarm-gap-actions.json`), but runner `security-research` is not live in the current snapshot (`agents_live: 0`). **Swarm goal `offensive_security`** is the control-plane replacement for the retired systemd loop.

---

## 3. HTTPD / tier5 security parity

Snapshot runner `httpd` shows tier5 exploit work largely **completed**; two perf soak todos remain pending (`gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk`). Security-research `sec-r2` explicitly targets tier5 gap exploits — coordinate with httpd plan state to avoid duplicate exploit rows.

**Cross-gap:** `gap-plan-pending-ph-db-wp-n5-security-bench` (ph-db) has no backlog mapping; defer to `issue_planner` for ph-db security bench spec.

---

## 4. Gap-ingest integrity (supply chain)

**Finding:** `lic/scripts/swarm-gap-ingest.py` contained a syntax error on the `verticals.toml` fallback path, preventing registry refresh. Same fix proposed in **lic#1504** (CI failing).

**Risk:** Stale registry (updated 2026-05-31) means security handoffs may not reflect current snapshot or briefing. For unattended operation, ingest/apply must run every briefing cycle with:

- Valid Python syntax on all fallback paths
- `PyYAML` available in CI/container
- `benchmarks/competitive/verticals.toml` on main (gap `gap-infra-verticals-toml-missing-benchmarks-main`)

---

## 5. Recommendations

1. **Unblock ingest** — merge lic#1504 after CI green; add `python3-yaml` to preflight image.
2. **Enable `security_cwe_audit`** on observer cadence (remove from `--skip-slow` set for security dimension runs).
3. **Dispatch `security_auditor`** on `offensive_security` for sec-r1..r3; cite PH-secure pillar.
4. **Open catalog issues** for 19 missing CWEs (batched by OWASP class).
5. **Do not** disable tier5 exploit gates or `trusted.lean` policy for velocity.

---

## Evidence index

- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/benchmarks/data/latest/agent-briefing.json`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/app/data/runs/swarm_observer-1780954994406.md`
