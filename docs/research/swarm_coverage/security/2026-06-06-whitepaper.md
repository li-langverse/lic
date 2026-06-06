# Swarm gap orchestration — security dimension

**Goal id:** `swarm_coverage`  
**Dimension:** `security`  
**Agent:** `swarm_observer`  
**Worker:** `4c4946a7`  
**Generated:** 2026-06-06  
**north_star_fit:** ecosystem, ai — secure multi-agent orchestration without weakening provability gates

---

## Abstract

This pass audits the Li agent swarm through a **security lens**: whether gap orchestration routes offensive-security work correctly, whether CWE/catalog signals reach the right agents, and whether control-plane failures create integrity or exhaustion risks. The swarm is **degraded** (grade D, not unattended-safe) primarily due to CI/merge debt and missing control-plane persistence—not SDK auth failure.

---

## 1. Threat model (swarm control plane)

| Risk | Observation | Mitigation |
|------|-------------|------------|
| **Silent audit loss** | No CP `state.json` / `latest-report.json`; grade `runs_sampled=0` | Persist observer artifacts offline; fix runs_dir resolution |
| **Retry exhaustion** | Historical org-research persist failures burned SDK slots | Circuit-break on persist failure; finalize runs on Job exit |
| **Gap pipeline fail-closed** | Ingest SyntaxError + missing PyYAML blocked registry refresh | Fixed Path/env; bake PyYAML in worker image |
| **Catalog drift** | 19/25 CWE Top25 absent from `cve-catalog.json` | `security_auditor` + human-gated catalog PR |
| **Supply chain (deps)** | `lip#52` actions/deploy-pages bump queued | `pr_merger` with gate checks |

---

## 2. Security gap registry reconcile

Open **plan_debt** rows with security handoff:

| Todo | Title | Target backlog | Agent |
|------|-------|----------------|-------|
| `sec-r1-httpd-fuzz-smoke` | httpd fuzz smoke | `security-research-backlog.md` | `security_auditor` |
| `sec-r2-tier5-gap-exploit` | tier-5 gap exploit study | same | `security_auditor` |
| `sec-r3-runtime-surface` | runtime attack surface | same | `security_auditor` |

Research goal **`offensive_security`** (`security_auditor`, cadence 12h, priority 9) is the canonical lane—**not** a new lic systemd loop.

---

## 3. CWE / catalog posture

Source: `/workspace/benchmarks/data/latest/security-cwe-feed.json`

- Top25 baseline: 25 CWEs tracked
- Catalog entries: 15
- **Missing in catalog: 19** (includes CWE-79, CWE-89, CWE-20, CWE-352, CWE-798, …)

Briefing aligns: `security_auditor` is P0 with reason "Top25 missing in catalog=19". Preflight `security_cwe_audit` was skipped (`--skip-slow`)—recommend enabling when auditor is P0.

---

## 4. Swarm health vs security priorities

| Signal | Value | Security implication |
|--------|-------|---------------------|
| `failed_prs` | 38 | CI integrity; includes benchmarks dashboard UX fixes |
| `repos_missing_ci_main` | 12 | Weaker org-wide assurance |
| `open_gaps` | 64 | Backlog pressure; security rows are routed |
| `preflight_failed` | 2 | `org_ci_audit`, `org_agent_kit_audit` |
| `workspace_dirty` | 0 | No uncommitted sibling drift |

Recommended dispatch: **`pr_merger`** (lip#52) → **`ci_maintainer`** → **`security_auditor`** (sec-r1).

---

## 5. Conclusions

1. **Gap orchestration for security plan_debt is wired** — apply script patches sec-r1/2/3; handoff queue is clear.
2. **Catalog completeness is the top security deliverable gap** — requires human-gated `lic` PR, not swarm auto-merge.
3. **Control-plane observability gaps** inflate risk — without persisted observer state, auto-heal cannot run; meta-audits repeat infra fixes.
4. **Unattended operation is not safe** until CI debt drops, CP persistence works, and CWE catalog backfill lands.

---

## References

- `lic/docs/ecosystem/security-research-backlog.md`
- `lic/data/swarm-gap-registry/registry.yaml`
- `benchmarks/data/latest/swarm-gap-actions.json`
- `benchmarks/data/latest/ecosystem-quality-report.json`
- `li-cursor-agents/config/research-goals.yaml` (`swarm_coverage`, `offensive_security`)

**Publish target (when mounted):** `research-findings/whitepapers/2026-06/swarm_coverage/security/`
