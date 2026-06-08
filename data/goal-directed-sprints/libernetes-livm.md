---
workflow_repo: lic
branch: cursor/libernetes-livm
plan: docs/libernetes/master-plan.md
---

# libernetes livm — goal-directed sprint

**Branch:** `cursor/libernetes-livm`  
**Agent:** `code_implementer`

## Mission

Build **livm** VM runtime. Wave 0 **DONE**. Wave 1 adds KVM backend stub, multi-OS matrix doc, smoke tests.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-V0** | package scaffold | **DONE** | `check-libernetes-livm-scaffold-gate.sh` |
| **LB-V1** | hypervisor backend interface | **DONE** | `check-libernetes-livm-hypervisor-gate.sh` |
| **LB-V2** | VirtualMachine CRD yaml | **DONE** | `check-libernetes-livm-crd-gate.sh` |
| **LB-V3** | `src/hypervisor/kvm.li` | **DONE** | `check-libernetes-livm-wave1-gate.sh` |
| **LB-V4** | `docs/libernetes/multi-os-matrix.md` | **DONE** | same wave1 gate |
| **LB-V5** | `li-tests/smoke/builds.li` | **DONE** | same wave1 gate |

## Completion gate

```bash
bash scripts/check-libernetes-livm-gate.sh
```
