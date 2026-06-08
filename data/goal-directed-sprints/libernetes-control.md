---
workflow_repo: lic
branch: cursor/libernetes-control
plan: docs/libernetes/master-plan.md
---

# libernetes control plane — goal-directed sprint

**Branch:** `cursor/libernetes-control`  
**Agent:** `code_implementer`

## Mission

Control plane UX and package scaffolds. Wave 0 **DONE**. Wave 1 adds `libernetes init/join` scripts and join-flow doc.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-K0** | easy-setup + heterogeneous-workers docs | **DONE** | `check-libernetes-control-docs-gate.sh` |
| **LB-K1** | WorkerProfile CRD yaml | **DONE** | `check-libernetes-control-crd-gate.sh` |
| **LB-K2** | apiserver + kubelet scaffolds | **DONE** | `check-libernetes-control-packages-gate.sh` |
| **LB-K3** | `scripts/libernetes-init.sh` | **DONE** | `check-libernetes-control-wave1-gate.sh` |
| **LB-K4** | `scripts/libernetes-worker-join.sh` | **DONE** | same wave1 gate |
| **LB-K5** | `docs/libernetes/join-flow.md` | **DONE** | same wave1 gate |

## Completion gate

```bash
bash scripts/check-libernetes-control-gate.sh
```
