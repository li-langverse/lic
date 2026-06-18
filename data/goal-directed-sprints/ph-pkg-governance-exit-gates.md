---
workflow_repo: lic
branch: cursor/ph-pkg-governance-exit-gates
plan: data/goal-directed-sprints/ph-pkg-governance-exit-gates.md
---

# PH-Pkg governance exit gates — goal-directed sprint

**Status:** Implementation complete (#476); gates verified via `scripts/ph-pkg-governance-gates.sh`.  
**Scope:** Close remaining gates in [2026-05-16-li-ecosystem-governance.md](../docs/superpowers/plans/2026-05-16-li-ecosystem-governance.md) per [2026-06-07-ph-pkg-governance-exit-gates.md](../docs/superpowers/plans/2026-06-07-ph-pkg-governance-exit-gates.md).  
**Honesty:** Checking governance boxes ≠ PH-Pkg master tracker completion; audit uses file evidence.

## Iteration rules

1. Work **Gov-3** (mkdocs/Pages alignment) first — only open audit checkbox.
2. Then **Gov-7** (li-demo `PUBLISH.md` traceability block).
3. Re-run **Gov-5** (`check-traceability.sh`) after any package doc touch.
4. One sub-phase or logical chunk per iteration; commit + push to feature branch.
5. Do not mark sprint done until `scripts/ph-pkg-governance-gates.sh` exits 0.

## Sub-phase queue

| Order | Sub | Owner | Notes |
|-------|-----|-------|-------|
| 1 | Gov-3 | code_implementer | Replace stale `li-language` repo home refs; verify lic Pages |
| 2 | Gov-7 | code_implementer | Add `## Traceability` to `packages/li-demo/PUBLISH.md` |
| 3 | Gov-5 | code_implementer | Confirm CI runs `check-traceability.sh` if not already |
| 4 | Gov-6 | agent_kit_maintainer | Sync create-li-package skill if drift vs lic |
| 5 | Gov-1 | human | Post `gh api orgs/li-langverse` ack on #476 if agent token lacks org scope |

## Completion gate

```bash
bash scripts/ph-pkg-governance-gates.sh
```

## K8s handoff (optional — human applies)

Homelab engine worker pattern mirrors PH-SCI:

```bash
cd li-cursor-agents
export KUBECONFIG=~/.kube/config-homelab
export GH_TOKEN=... CURSOR_API_KEY=...
# Apply ConfigMap with:
#   LI_PROOF_EXPLORER_GOAL_FILE=data/goal-directed-sprints/ph-pkg-governance-exit-gates.md
#   LI_PROOF_EXPLORER_WORKFLOW_REPO=lic
#   LI_PROOF_EXPLORER_AGENT=code_implementer
./scripts/goal-directed-loop.sh \
  --goal-file ../lic/data/goal-directed-sprints/ph-pkg-governance-exit-gates.md \
  --workflow-repo lic --cwd ../lic
```

## Cross-references

| Doc | Relevance |
|-----|-----------|
| [2026-06-07-ph-pkg-governance-exit-gates.md](../docs/superpowers/plans/2026-06-07-ph-pkg-governance-exit-gates.md) | Normative sub-phase table |
| [2026-05-16-li-ecosystem-governance.md](../docs/superpowers/plans/2026-05-16-li-ecosystem-governance.md) | Parent sub-plan exit gate section |
| [official-packages.md](../docs/ecosystem/official-packages.md) | PKG- registry |
| [plan-completion-audit.py](https://github.com/li-langverse/benchmarks/blob/main/scripts/plan-completion-audit.py) | Audit regression |
