# Security research — grading contract

**Status:** Active  
**Audience:** `security_auditor` in the security-research plan loop  
**Related:** [httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) (fuzz + tier5 exploits)

---

## Axes

| Axis | Primary evidence | Hard gate? |
|------|------------------|------------|
| **Posture validity** | No weakened `li_stricter`; exploit rows pass; CVE catalog honest | **Yes** |
| **CWE freshness** | `security-cwe-feed-sync.py` ≤7d old (or `SECURITY_CWE_FEED_SKIP=1`) | **Yes** for non-study-only |
| **Fuzz coverage** | Documented libFuzzer/AFL paths or N/A in study | No — document tradeoff |
| **Tier5 parity** | Live `li-httpd` vs nginx on assigned exploit row | Yes when todo targets tier5 |
| **ASan / native** | `li-tests` security slice when `*_core.c` touched | Fail when native touched and slice fails |

**Security posture is never traded** for fuzz throughput or bench speed unless a human approves in the study with explicit locked axes.

---

## Tradeoff documentation (required in every study)

Each `docs/security/studies/YYYY-MM-DD-<slug>.md` must end with:

```markdown
## Grade matrix
| Axis | Result | vs prior | Notes |
|------|--------|----------|-------|
| Posture validity | pass/fail | … | … |
| CWE freshness | pass/skip | … | … |
| Fuzz coverage | … | … | … |
| Tier5 parity | pass/skip/N/A | … | … |
| ASan / native | pass/skip/N/A | … | … |

## Tradeoffs
- Locked: security posture (exploit expectations, li_stricter)
- Improved: …
- Regressed (if any): … — justified or rejected
```

---

## Enforcement

```bash
./scripts/security-research-gates.sh
```

Writes `data/security-research-loop/grade.json` for the live agents canvas.
