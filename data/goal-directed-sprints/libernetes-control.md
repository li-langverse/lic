---
workflow_repo: lic
branch: cursor/libernetes-control
plan: docs/libernetes/master-plan.md
---

# libernetes control plane — goal-directed sprint (Wave 0 UX)

**Repos:** `lic` (primary)  
**Branch:** `cursor/libernetes-control`  
**Agent:** `code_implementer`

## Mission

Design and stub **libernetes init/join** UX, **WorkerProfile** CRD, node capability auto-discovery spec, and control-plane package layout (`li-apiserver`, `li-scheduler` stubs).

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| **LB-K0** | `docs/libernetes/easy-setup.md` + `docs/libernetes/heterogeneous-workers.md` (control sections) | `bash scripts/check-libernetes-control-docs-gate.sh` |
| **LB-K1** | `docs/libernetes/crd-workerprofile.yaml` + join flow sequence diagrams | `bash scripts/check-libernetes-control-crd-gate.sh` |
| **LB-K2** | `packages/li-libernetes-apiserver/` + `packages/li-libernetes-kubelet/` scaffolds | `bash scripts/check-libernetes-control-packages-gate.sh` |
| **LB-K3** | `scripts/libernetes-doctor.sh` stub (checks file presence) | included in completion gate |

## Progress gate

```bash
bash scripts/check-libernetes-control-progress-gate.sh
```

## Completion gate

```bash
bash scripts/check-libernetes-control-gate.sh
```
