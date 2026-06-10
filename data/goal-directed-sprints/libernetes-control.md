---
workflow_repo: lic
branch: cursor/libernetes-control
plan: docs/libernetes/master-plan.md
---

# libernetes control plane — goal-directed sprint

**Branch:** `cursor/libernetes-control`  
**Agent:** `code_implementer`

## Mission

Control plane UX and distributed orchestration. **Wave 0–2 DONE on `main`.** Active: **Wave 3** (local runnable stack + kubelet sync stub).

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-K0–K5** | docs, CRDs, init/join, join-flow | **DONE** | wave0–1 gates |
| **LB-K6–K8** | scheduler scaffold, apiserver serve, doctor | **DONE** | `check-libernetes-control-wave2-gate.sh` |
| **LB-K9** | `scripts/libernetes-run-local.sh` | pending | `check-libernetes-control-wave3-gate.sh` |
| **LB-K10** | `packages/li-libernetes-kubelet/src/sync.li` | pending | same wave3 gate |
| **LB-K11** | `libernetes init` invokes run-local | pending | same wave3 gate |
| **LB-K12** | `docs/libernetes/distributed-workloads.md` | pending | same wave3 gate |
| **LB-K13** | `apiserver/src/informer_sync.li` + serve wiring | pending | same wave3 gate |

## Later waves

| Wave | Focus | Gate |
|------|-------|------|
| 4 | Multi-node join + `cluster_state.li` | `check-libernetes-control-wave4-gate.sh` |
| 5 | Scheduler dispatch + pod sync | `check-libernetes-control-wave5-gate.sh` |
| 6 | Pod churn bench + distributed e2e | `check-libernetes-control-wave6-gate.sh` |

## Completion gate

```bash
bash scripts/check-libernetes-control-gate.sh
```
