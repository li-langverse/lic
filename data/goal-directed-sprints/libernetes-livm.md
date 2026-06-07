---
workflow_repo: lic
branch: cursor/libernetes-livm
plan: docs/libernetes/master-plan.md
---

# libernetes livm — goal-directed sprint (Wave 1 prep)

**Repos:** `lic` (primary)  
**Branch:** `cursor/libernetes-livm`  
**Agent:** `code_implementer`

## Mission

Scaffold **livm** VM runtime: hypervisor backend interface, disk/firmware/cloud-init package layout, KubeVirt-compatible CRD YAML specs in docs.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| **LB-V0** | `packages/livm/` scaffold + README | `bash scripts/check-libernetes-livm-scaffold-gate.sh` |
| **LB-V1** | `src/hypervisor/backend.li` dual-backend interface (Linux KVM + LiOS stub) | `bash scripts/check-libernetes-livm-hypervisor-gate.sh` |
| **LB-V2** | `docs/libernetes/crd-virtualmachine.yaml` + multi-OS matrix doc | `bash scripts/check-libernetes-livm-crd-gate.sh` |
| **LB-V3** | Package smoke build | included in completion gate |

## Progress gate

```bash
bash scripts/check-libernetes-livm-progress-gate.sh
```

## Completion gate

```bash
bash scripts/check-libernetes-livm-gate.sh
```
