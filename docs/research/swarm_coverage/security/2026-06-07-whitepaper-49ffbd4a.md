# Swarm gap orchestration — security dimension audit

**Goal:** `swarm_coverage`  
**Dimension:** `security`  
**Worker:** `49ffbd4a`  
**Date:** 2026-06-07  
**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/security/`  
**north_star_fit:** ecosystem, ai (secure pillar — proof-before-perf applies to security claims)

---

## Abstract

This whitepaper audits the Li agent swarm's **security orchestration posture** under the `swarm_coverage` research goal. We correlate the CWE feed, security-research plan debt, gap registry, and ecosystem quality scorecard to determine whether security work is routed correctly without human intervention. **Conclusion:** security signals are detected and enqueued, but **orchestration infra gaps** (PyYAML, control-plane persistence, GitHub rate limits) prevent unattended closure of security plan todos.

---

## 1. CWE catalog posture

| Signal | Value | Source |
|--------|-------|--------|
| CWE Top-25 tracked | 25 | `security-cwe-feed.json` |
| Rows in `cve-catalog.json` | 15 | same |
| Top-25 missing | **19** | `top25_missing_in_catalog` |
| New vs previous sync | 0 | feed delta stable |

**Interpretation:** The offensive-security research lane (`offensive_security` → `security_auditor`) has a standing P0 to expand the catalog. This is **human-gated** — catalog changes affect compliance narratives and must not auto-merge.

Missing examples include CWE-79 (XSS), CWE-89 (SQLi), CWE-22 (path traversal), CWE-918 (SSRF) — all relevant to `li-httpd` tier5 exploit suite.

---

## 2. Security-research plan debt

| Todo | Status | Tier5 / harness link |
|------|--------|----------------------|
| `sec-r0-cwe-delta` | completed | CWE feed sync |
| `sec-r1-httpd-fuzz-smoke` | **pending** | libFuzzer/AFL++ smoke for httpd parse (see `docs/security/studies/2026-05-27-offensive-r0-sota-survey.md`) |
| `sec-r2-tier5-gap-exploit` | **pending** | Close exploit rows in `benchmarks/vendor/lis-tier5/benchmarks/tier5_http/exploits/` |
| `sec-r3-runtime-surface` | **pending** | Li runtime + httpd attack surface inventory |

Gap registry rows map 1:1 to backlog todos. Apply-actions patched all three to `pending` on 2026-05-31 but **no research-lane dispatch** has completed them since.

**Recommended handoff:**

```
swarm_observer → security_auditor (offensive_security goal)
  north_star_fit: secure pillar, PH-httpd
  cite: sec-r1-httpd-fuzz-smoke
  evidence: tier5_http/exploits/*.toml, security-cwe-feed.json
```

---

## 3. Httpd exploit coverage (context)

The httpd goal-directed runner reports strong tier5 exploit progress (OWASP/CWE-class rows, nginx parity gates). Remaining httpd plan todos (`gap-phase2-perf-wrk-soak`, `gap-phase2-streaming-wrk`) are **performance**, not security — correctly classified as plan_debt under `httpd` runner, not security-research.

Security-research `sec-r2` should focus on **closing tier5 exploit gaps** where nginx mitigations exist but Li parity is unproven — distinct from perf soak work.

---

## 4. Orchestration blockers (security lens)

| Blocker | Security impact | Remediation |
|---------|-----------------|-------------|
| `swarm-gap-ingest.py` SyntaxError | Cannot ingest new security vertical signals | **Fixed** 2026-06-07 (Path fallback) |
| PyYAML missing in worker | Cannot run ingest/apply live | Bake `python3-yaml` in org-research image |
| No control-plane state | Observer cannot auto-retry `security_auditor` | Persist state each supervisor tick |
| GitHub API 403 | CI audit incomplete — hides repos without security workflows | Backoff + cache in `ensure-org-repo-ci.py` |
| `runs_sampled=0` | Cannot measure security agent error rate | Set `LI_CURSOR_AGENTS_ROOT=/app` |

---

## 5. Ecosystem grade (security-relevant dimensions)

| Dimension | Score | Security note |
|-----------|-------|---------------|
| Overall | 66.8 (D) | `unattended_safe: false` |
| briefing_health | 69.0 | `security_cwe_audit` skipped (`--skip-slow`) |
| gap_pressure | 60.0 | 64 open gaps including sec-r* |
| ecosystem_posture | 69.0 | 14 repos missing CI — no security workflow baseline |

---

## 6. Recommendations

1. **Dispatch `security_auditor`** on `sec-r1-httpd-fuzz-smoke` via research lane (priority 9, cadence 12h).
2. **Open human-gated issue** for 19 CWE catalog rows with mapping to tier5 exploit scenarios.
3. **Merge control-plane fixes** before expecting unattended security gap closure.
4. **Do not** add new lic systemd plan loops — route via `offensive_security` goal per `docs/ecosystem/swarm-architecture.md`.

---

## Evidence index

- `/workspace/benchmarks/data/latest/security-cwe-feed.json`
- `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`
- `/workspace/lic/docs/ecosystem/security-research-backlog.md`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `/app/data/runs/swarm_observer-1780849118559.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-07-swarm-coverage-security-49ffbd4a.md`

---

_Staged for publish to research-findings when repo mount available._
