# Security research backlog (offensive + CWE)

**Status:** Active  
**Agent:** `security_auditor`  
**Goal:** `offensive_security`  
**Branch:** `cursor/security-research-loop`  
**Plan:** [2026-06-06-security-research-sec-r1-r3-plan.md](../superpowers/plans/2026-06-06-security-research-sec-r1-r3-plan.md) · **Issue:** [#521](https://github.com/li-langverse/lic/issues/521)

---

todos:

- id: sec-r0-cwe-delta
  content: "CWE Top 25 feed sync vs cve-catalog.json — map new CWEs to catalog_gaps and li-tests"
  status: completed
  study_only: true

- id: sec-r1-httpd-fuzz-smoke
  content: "httpd fuzz table — libFuzzer http_parse_fuzz smoke + tier5 exploit smoke vs live li-httpd (3-row pr profile)"
  status: pending
  study_only: true
  plan_ref: docs/superpowers/plans/2026-06-06-security-research-sec-r1-r3-plan.md#A--sec-r1-httpd-fuzz-smoke-study-only-gate

- id: sec-r2-tier5-gap-exploit
  content: "Close one Top25 CWE tier5 row (CWE-20 or CWE-862) — catalog + exploit TOML + live stricter-or-equal vs nginx"
  status: pending
  plan_ref: docs/superpowers/plans/2026-06-06-security-research-sec-r1-r3-plan.md#B--sec-r2-tier5-gap-exploit-live-parity

- id: sec-r3-runtime-surface
  content: "Runtime attack surface — parse/crypto/HTTP native cores; ASan slice on touched *_core.c"
  status: pending
  plan_ref: docs/superpowers/plans/2026-06-06-security-research-sec-r1-r3-plan.md#C--sec-r3-runtime-surface-asan-slice

---

## Agent instructions

- One todo per loop iteration (`security-research-plan-loop.py`).
- Agent: `security_auditor` (`LI_SECURITY_PLAN_AGENT`).
- Gates: `./scripts/security-research-gates.sh`.
- Deliverable: `docs/security/studies/YYYY-MM-DD-<todo-id>.md` (see `security-research-grading.md`).
- Survey todos (`study_only: true`): gates require study file; benches optional unless code changes.
- Push branch `cursor/security-research-loop` every iteration.
- **No codegen** until issue #521 has label `plan-approved` and plan link on issue.
