---
workflow_repo: lic
branch: cursor/libernetes-livm
plan: docs/libernetes/master-plan.md
---

# libernetes livm — goal-directed sprint

**Branch:** `cursor/libernetes-livm`  
**Agent:** `code_implementer`

## Mission

Build **livm** VM runtime. Wave 0 **DONE**. Wave 1 **DONE**. Wave 2 adds disk/cloud-init modules, KVM probe, and Windows in multi-OS matrix.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-V0** | package scaffold | **DONE** | `check-libernetes-livm-scaffold-gate.sh` |
| **LB-V1** | hypervisor backend interface | **DONE** | `check-libernetes-livm-hypervisor-gate.sh` |
| **LB-V2** | VirtualMachine CRD yaml | **DONE** | `check-libernetes-livm-crd-gate.sh` |
| **LB-V3** | `src/hypervisor/kvm.li` | **DONE** | `check-libernetes-livm-wave1-gate.sh` |
| **LB-V4** | `docs/libernetes/multi-os-matrix.md` | **DONE** | same wave1 gate |
| **LB-V5** | `li-tests/smoke/builds.li` | **DONE** | same wave1 gate |
| **LB-V6** | `src/disk/qcow2.li` | **DONE** | `check-libernetes-livm-wave2-gate.sh` |
| **LB-V7** | `src/cloudinit/cloudinit.li` | **DONE** | same wave2 gate |
| **LB-V8** | `src/hypervisor/kvm_probe.li` + Windows in matrix | **DONE** | same wave2 gate |

## Completion gate

```bash
bash scripts/check-libernetes-livm-gate.sh
```
