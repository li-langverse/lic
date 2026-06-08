# Swarm gap orchestration — API coverage audit

**Goal:** `swarm_coverage` · **Dimension:** `api-coverage` · **Date:** 2026-06-05  
**Author:** `swarm_observer` (worker `6d6eae2d`)  
**north_star_fit:** ecosystem orchestration APIs must be complete and honest before unattended swarm operation (ai-first agent JSON, provable audit trails).

**Publish target:** `research-findings/whitepapers/2026-06/swarm_coverage/api-coverage/` (staged in lic until repo mounted).

---

## Abstract

This pass audits **API coverage** across the Li agent swarm control plane: briefing preflight JSON outputs, gap registry ingest/apply scripts, ecosystem quality scorecard inputs, security CWE catalog completeness, and partial Vision-LLM agent diagnostics. The swarm is **degraded** (grade D, 64.8) primarily because gap pipeline APIs are broken (ingest syntax + missing PyYAML), control-plane observer state is absent on disk, and external GitHub REST APIs hit rate limits during CI audit.

---

## 1. Scope — what “api-coverage” means here

Per org-research supervisor dimensions, **api-coverage** for `swarm_coverage` evaluates:

1. **Machine-readable orchestration APIs** — JSON artifacts agents and supervisors consume (`agent-briefing.json`, `ecosystem-quality-report.json`, `swarm-gap-actions.json`, control-plane reports).
2. **Agent-facing product APIs** — Li compiler diagnostics JSON (`lic check --format=json`, `lic diagnose`) per master-plan Vision-LLM partial.
3. **Security catalog APIs** — CWE Top25 coverage in org catalog feeds.
4. **Ingest path APIs** — env vars and file paths (`BENCHMARKS_COMPETITIVE`, `verticals.toml`) that gap scripts use to merge registry rows.

Not in scope: HTTP REST product APIs (li-httpd) — covered by `server_platform` / httpd plan loops.

---

## 2. Scorecard and briefing API posture

| Artifact | Generated | Key API fields | Coverage gap |
|----------|-----------|----------------|--------------|
| `ecosystem-quality-report.json` | 2026-06-05T05:21Z | `overall_score: 64.8`, `unattended_safe: false` | `runs_sampled: 0` |
| `agent-briefing.json` | 2026-06-05T05:21Z | `recommended_agents: 2` | Drift vs scorecard (6 agents) |
| `swarm-gap-actions.json` | 2026-05-31 | `open_gaps: 64`, `patches: 23` | Stale 5 days |
| `security-cwe-feed.json` | 2026-06-05 | `missing_in_catalog: 19` | 76% Top25 uncovered |
| Control-plane disk | — | `swarm_health`, `retry_counts` | **Missing files** |

**Evidence:** `/workspace/benchmarks/data/latest/ecosystem-quality-report.json`, `/workspace/benchmarks/data/latest/agent-briefing.json`.

---

## 3. Gap registry ingest API — failure mode and fix

### 3.1 Syntax failure (remediated)

`lic/scripts/swarm-gap-ingest.py` line 229 contained an unterminated string when building the fallback path for `verticals.toml`:

```python
# Before (SyntaxError)
Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(...))/verticals.toml"

# After (this pass)
Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))) / "verticals.toml"
```

### 3.2 Dependency failure (open)

Both ingest and apply require PyYAML. Org-research Job container lacks `python3-yaml`, `pip`, and `ensurepip`. Until baked into the image, **every supervisor gap tick fails** after syntax fix.

### 3.3 Env API — `BENCHMARKS_COMPETITIVE`

When unset, fallback resolves to `benchmarks/workloads/competitive/verticals.toml`. Row `gap-infra-verticals-toml-missing-benchmarks-main` remains open because `benchmarks/competitive/verticals.toml` is not on `main` (blocked by catalog PR stack #353–#357).

---

## 4. Vision-LLM agent JSON API (plan_debt)

Registry row `gap-plan-debt-lic-master-plan-vision-llm-llm-first-agent-json-*` tracks partial implementation:

- Present: `lic check --format=json`, `lic diagnose`, diagnostic hooks
- Missing: full agent JSON schema parity for LLM-first workflows

**Handoff:** `issue_planner` — proof-gated; no `trusted.lean` auto-merge.

---

## 5. Security catalog API coverage

`security-cwe-feed.json` reports **19 of 25** MITRE Top25 CWEs missing from the org catalog. Briefing correctly elevates `security_auditor` on this signal; heap currently under-dispatches relative to scorecard.

**Handoff:** `security_auditor` → human-gated catalog PR.

---

## 6. Recommendations (orchestration only)

1. **Merge ingest fix PR on `lic`** — unblocks vertical stub ingest API.
2. **Bake PyYAML** in org-research / agent preflight image.
3. **Persist control-plane JSON** on supervisor tick when Supabase MCP unavailable.
4. **Align `runs_dir`** in quality grader with `/app/data/runs` container mount.
5. **Merge briefing + scorecard dispatch** in heap task queue.
6. **Unblock benchmarks catalog CI** before refreshing gap actions on main.

---

## 7. Conclusion

API coverage for swarm gap orchestration is **insufficient for unattended operation**. The ingest path syntax is fixed, but dependency and persistence gaps prevent the registry apply pipeline from running. Product-side agent JSON (Vision-LLM) and security catalog APIs remain partial. Priority: infrastructure fixes on `li-cursor-agents` and `lic`, then re-run full ingest/apply cycle.

---

## References

- `/app/data/runs/swarm_observer-1780635377855.md`
- `/workspace/lic/docs/ecosystem/orchestrator-notes/2026-06-05-orch-api-coverage-6d6eae2d.md`
- `/workspace/lic/data/swarm-gap-registry/registry.yaml`
- `/workspace/benchmarks/data/latest/swarm-gap-actions.json`
- `docs/ecosystem/research-verticals.md` — `swarm_coverage` goal definition
