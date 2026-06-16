---
name: Ship swarm-gap-ingest on lic main (#473)
workflow_repo: lic
ph_ids: []
tracker: docs/superpowers/plans/2026-05-14-li-master-plan.md
issues: [li-langverse/lic#473, li-langverse/lic#436, li-langverse/lic#471]
north_star_fit: "Governance / swarm orchestration — enables plan_verifier → swarm_observer backlog sync that upholds proof-before-perf tracking (no PH phase; infra debt)"
status: draft
---

# Ship `swarm-gap-ingest.py` on `lic` main for `plan_verifier`

**Date:** 2026-06-07  
**Kind:** Swarm infra / master-plan-gap (orchestration, not language surface)  
**Blocks:** `plan_verifier` post-audit ingest; `swarm_observer` apply-actions pipeline

## Problem (corrected evidence)

Issue #473 reported `lic/scripts/swarm-gap-ingest.py` **absent on main**. **On `lic` main @ 2026-06-07** the truth is:

| Source | State |
|--------|--------|
| `scripts/swarm-gap-ingest.py` | **Present** (10.8 KB) but **`SyntaxError` at L229** — `ingest_verticals_stubs` Path fallback has unterminated string |
| `scripts/swarm-gap-apply-actions.py` | **Present**; `python3 -m py_compile` passes |
| `data/swarm-gap-registry/registry.yaml` | **Present**; YAML parses; **0** `<<<<<<<` conflict markers |
| `plan_verifier` prompt | Requires ingest after audit ([`prompts/plan-verifier.md`](https://github.com/li-langverse/li-cursor-agents/blob/main/prompts/plan-verifier.md) step 6) |
| Open fix PRs | #788, #812, #840, #851, #912, #963, … — same L229 fix, none merged |

**Root cause:** Script landed on main with a broken fallback line; `plan_verifier` and `swarm_observer` cannot run ingest until compile + smoke pass. Worktrees (e.g. `lic-vulkan-spirv-5b3a`) had working copies — main did not.

## Vision / philosophy check

- **Pass** — swarm ingest is governance hygiene; it keeps PH / G-* plan debt honest without weakening proof or benchmark gates.
- **Not in scope:** weakening `threshold_ratio_cpp`, `trusted.lean` edits, new org repos.
- **Defer:** Full `todo.status=completed` reconcile (#471) — separate implement pass after ingest runs; do not block ship on #471 logic.

## Scope

### In scope

1. Fix L229 syntax so `swarm-gap-ingest.py` compiles and runs `--dry-run`
2. Confirm `registry.yaml` loads without merge conflicts (#436)
3. Document env vars for agent checkouts (`BENCHMARKS_ROOT`, `LI_LANGVERSE_ROOT`, registry override)
4. Add smoke gate callable from `plan_verifier` / CI docs
5. Verify `swarm-gap-apply-actions.py` dry-run after ingest

### Out of scope

- #471 reconcile logic (`todos[].status` vs `completed_ids`) — follow-up issue after ship
- Merging competing fix PRs (#788–#963) — supersede with single implement PR post-approval
- Product/compiler features; benchmark threshold changes

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `LI_LANGVERSE_ROOT` | `lic` repo parent (`ROOT.parent`) | Sibling repo resolution |
| `BENCHMARKS_ROOT` | `$LI_LANGVERSE_ROOT/benchmarks` | Read `data/latest/ecosystem-explorer.json`, `plan-completion-audit.json` |
| `BENCHMARKS_COMPETITIVE` | `$BENCHMARKS_ROOT/workloads/competitive` | `verticals.toml` stub ingest (`ingest_verticals_stubs`) |
| `--registry` CLI | `data/swarm-gap-registry/registry.yaml` | Override registry path |

**Minimal checkout (lic only):**

```bash
export LI_LANGVERSE_ROOT=/path/to/langverse   # parent of lic + benchmarks
export BENCHMARKS_ROOT="${BENCHMARKS_ROOT:-$LI_LANGVERSE_ROOT/benchmarks}"
python3 scripts/swarm-gap-ingest.py --dry-run
```

## Implementation phases

### Phase 0 — Syntax fix (blocking)

Repair `ingest_verticals_stubs` L229:

```python
# Before (broken — missing closing paren/quote):
vert = Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(LANGVERSE / "benchmarks/workloads/competitive"))/verticals.toml"

# After:
default_comp = LANGVERSE / "benchmarks/workloads/competitive"
vert = Path(os.environ.get("BENCHMARKS_COMPETITIVE", str(default_comp))) / "verticals.toml"
```

**Pass:** `python3 -m py_compile scripts/swarm-gap-ingest.py` exit 0.

### Phase 1 — Smoke test (plan_verifier gate)

```bash
cd lic
python3 scripts/swarm-gap-ingest.py --dry-run
python3 scripts/swarm-gap-apply-actions.py --dry-run
```

| Check | Pass criteria |
|-------|---------------|
| Ingest dry-run | Exit 0; prints `registry gaps: N` stats |
| Registry YAML | `yaml.safe_load` on `data/swarm-gap-registry/registry.yaml` — no conflict markers |
| Apply dry-run | Exit 0; JSON payload with `open_gaps` count |
| Missing benchmarks | Graceful empty ingest when `$BENCHMARKS_ROOT/data/latest/` absent (no crash) |

### Phase 2 — Documentation

Add short section to one of:

- `docs/ecosystem/swarm-observer-plan-backlog.md` (preferred — already references ingest), or
- `scripts/README-swarm-gap.md` (new, linked from AGENTS.md)

Content: env table above + `plan_verifier` / `swarm_observer` invocation sequence.

### Phase 3 — Issue hygiene

| Issue | Action after implement |
|-------|------------------------|
| **#473** | Close when L229 fixed + smoke green + docs land |
| **#436** | Close if registry parses (already true on main); comment with evidence |
| **#471** | Keep open; implement reconcile in separate PR |

### Phase 4 — Registry refresh (post-merge)

```bash
python3 scripts/swarm-gap-ingest.py
python3 scripts/swarm-gap-apply-actions.py --dry-run
# Human reviews diff; live apply only when swarm_observer cycle expects it
```

Handoff **`swarm_observer`** with ingest stats + `benchmarks/data/latest/swarm-gap-actions.json` diff.

## PH / REQ / G / test mapping

| ID | Requirement | Verification |
|----|-------------|--------------|
| **G-swarm-ingest** | Ingest script runnable on main | `py_compile` + `--dry-run` |
| **G-swarm-plan-debt** | Registry canonical for plan_verifier | Ingest writes valid YAML; #471 extends reconcile |
| **REQ-plan-verifier-ingest** | Post-audit ingest step | `plan_verifier` prompt step 6 succeeds |
| **REQ-swarm-observer-apply** | apply-actions after ingest | `--dry-run` on `swarm-gap-apply-actions.py` |

No **PH-*** phase — infra debt enabling master-plan honesty.

## Files touched (implement pass)

| Path | Change |
|------|--------|
| `scripts/swarm-gap-ingest.py` | L229 Path fallback fix |
| `docs/ecosystem/swarm-observer-plan-backlog.md` | Env vars + invocation |
| `data/swarm-gap-registry/registry.yaml` | Re-ingest output (if live run) |

## Learned from

1. [swarm-observer-plan-backlog.md](../../ecosystem/swarm-observer-plan-backlog.md) — ingest + apply-actions sequence
2. [2026-05-30-orch-r2-competitor-stubs.md](../../ecosystem/orchestrator-notes/2026-05-30-orch-r2-competitor-stubs.md) — programmatic prep pattern
3. [2026-06-01-ph-h-httpd-reconcile-477-619.md](2026-06-01-ph-h-httpd-reconcile-477-619.md) — ingest reconcile lessons (#471)
4. [vision-and-roadmap.md](https://github.com/li-langverse/roadmap/blob/main/docs/ecosystem/vision-and-roadmap.md) — proof → easy → fast pillar order

## Acceptance criteria (plan-approved → implement)

- [ ] `python3 -m py_compile scripts/swarm-gap-ingest.py` passes
- [ ] `python3 scripts/swarm-gap-ingest.py --dry-run` exit 0 on lic-only checkout with env defaults
- [ ] `python3 scripts/swarm-gap-apply-actions.py --dry-run` exit 0 after ingest dry-run
- [ ] Env vars documented (`BENCHMARKS_ROOT`, `LI_LANGVERSE_ROOT`, `--registry`)
- [ ] #436 closed or commented (registry conflict-free)
- [ ] `plan_verifier` can run step 6 without worktree workaround
- [ ] No duplicate merge of open fix PRs — one canonical implement PR

## Handoffs

| Agent | When | Payload |
|-------|------|---------|
| `code_implementer` | After `plan-approved` | L229 fix + docs + smoke evidence |
| `swarm_observer` | Post-implement ingest | `registry.yaml` diff + `swarm-gap-actions.json` |
| `plan_verifier` | Next audit cycle | Confirm step 6 green |

**north_star_fit:** Governance / swarm orchestration — proof-before-perf tracking via honest plan_debt registry (no PH id).
