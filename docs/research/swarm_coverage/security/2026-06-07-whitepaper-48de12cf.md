# Swarm gap orchestration — security dimension

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `48de12cf`  
**Date:** 2026-06-07  
**north_star_fit:** Swarm gap orchestration — registry, backlog apply, handoffs — domains: ecosystem, ai  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`

---

## Abstract

This pass audits Li swarm health through a **security lens**: whether gap orchestration reliably routes offensive-security plan debt, whether the CWE catalog keeps pace with MITRE Top25, and whether control-plane tooling (ingest/apply/scorecard) can run unattended. Finding: **degraded posture (grade D)** driven by broken gap ingest, stale security runner, and 19 missing CWE catalog rows — all recoverable via existing swarm agents without new systemd loops.

---

## 1. CWE catalog coverage

| Metric | Value | Evidence |
|--------|-------|----------|
| MITRE Top25 synced | 25/25 | `security-cwe-feed.json` |
| Present in `cve-catalog.json` | 6/25 | same |
| Missing | **19** | `top25_missing_in_catalog` array |
| New since prior sync | 0 | `new_vs_previous_sync: 0` |

**Missing CWEs (sample):** CWE-79 (XSS), CWE-89 (SQLi), CWE-20 (input validation), CWE-352 (CSRF), CWE-798 (hard-coded credentials).

**Risk:** Security auditor and tier5 exploit gates cannot reference canonical catalog rows for the majority of OWASP/MITRE priority weaknesses.

**Recommendation:** Human-gated issue on `lic` to backfill catalog; dispatch `security_auditor` under `offensive_security` goal for delta mapping to `li-tests`.

---

## 2. Security plan_debt in gap registry

Three open `plan_debt` rows map to `security-research` runner todos:

1. **sec-r1-httpd-fuzz-smoke** — libFuzzer/AFL smoke vs li-httpd  
2. **sec-r2-tier5-gap-exploit** — close nginx_mitigations / tier5 row  
3. **sec-r3-runtime-surface** — parse/crypto/HTTP ASan slice  

Apply-actions patched all three to `docs/ecosystem/security-research-backlog.md` (status: pending).

**Runner state:** `security-research` **stopped** since 2026-05-25; `sec-r1` last iteration `agent_exit: 1`. Per swarm architecture, work routes via **`security_auditor`** + `offensive_security` research goal — not by restarting retired systemd plan loops.

---

## 3. Control-plane reliability (security impact)

| Failure | Security consequence | Status |
|---------|---------------------|--------|
| `swarm-gap-ingest.py` SyntaxError | Security gaps not ingested from snapshot | **Fixed** 2026-06-07 |
| Missing PyYAML | Apply-actions cannot patch backlogs | **Fixed** (apt); image bake pending |
| `runs_sampled=0` | Observer cannot detect security agent error streaks | Open — path alias needed |
| `--skip-slow` on `security_cwe_audit` | Stale CWE signals in fast preflight | Deferred |

Unreliable ingest directly delayed routing of httpd fuzz and tier5 exploit work — a **swarm security orchestration gap**, not a product vulnerability.

---

## 4. Dispatch order (proof → easy → secure)

Aligned with org roadmap pillars and briefing heap:

1. `pr_merger` — lip#52 (deps, low risk)  
2. `ci_maintainer` — 14 repos missing CI (supply-chain baseline)  
3. `security_auditor` — CWE catalog + sec-r1–r3 backlog  
4. `gap_explorer` — 64 open registry rows  

---

## 5. Conclusion

Swarm gap orchestration **can** route security plan debt when ingest/apply scripts run cleanly. Current **unattended_safe: false** reflects tooling fragility (ingest syntax, PyYAML, CP IPC) more than absent security agents. Fixing control-plane paths and dispatching `security_auditor` closes the highest-priority security gaps without disabling provability gates or merging governance PRs.

---

## References

- `benchmarks/data/latest/ecosystem-quality-report.json`
- `benchmarks/data/latest/security-cwe-feed.json`
- `lic/data/swarm-gap-registry/registry.yaml`
- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/docs/ecosystem/orchestrator-notes/2026-06-07-orch-r5-security-gap-handoffs-48de12cf.md`
- `docs/ecosystem/swarm-architecture.md`
