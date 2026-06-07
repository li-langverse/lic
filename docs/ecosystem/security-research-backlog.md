# Security research backlog (offensive + CWE)

**Status:** Active  
**Agent:** `security_auditor`  
**Goal:** `offensive_security`  
**Branch:** `cursor/security-research-loop`

---

todos:

- id: sec-r0-cwe-delta
  content: "CWE Top 25 feed sync vs cve-catalog.json — map new CWEs to catalog_gaps and li-tests"
  status: completed
  study_only: true

- id: sec-r1-httpd-fuzz-smoke
  content: "security-research: pending plan todo sec-r1-httpd-fuzz-smoke — gap orchestrator"
  status: pending
  study_only: true

- id: sec-r2-tier5-gap-exploit
  content: "security-research: pending plan todo sec-r2-tier5-gap-exploit — gap orchestrator"
  status: pending

- id: sec-r3-runtime-surface
  content: "security-research: pending plan todo sec-r3-runtime-surface — gap orchestrator"
  status: pending

---

## Agent instructions

- One todo per loop iteration (`security-research-plan-loop.py`).
- Agent: `security_auditor` (`LI_SECURITY_PLAN_AGENT`).
- Gates: `./scripts/security-research-gates.sh`.
- Deliverable: `docs/security/studies/YYYY-MM-DD-<todo-id>.md` (see `security-research-grading.md`).
- Survey todos (`study_only: true`): gates require study file; benches optional unless code changes.
- Push branch `cursor/security-research-loop` every iteration.
