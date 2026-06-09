---
workflow_repo: lic
branch: cursor/libernetes-livm
plan: docs/libernetes/master-plan.md
---

# libernetes livm — goal-directed sprint

**Branch:** `cursor/libernetes-livm`  
**Agent:** `code_implementer`

## Mission

Build **livm** VM runtime on the **Li-native hypervisor** (`li-hypervisor` / LiOS ABI). KVM/QEMU/libvirt are **removed** from the target architecture — not a production or fallback backend.

Wave 0 **DONE**. Wave 1 **DONE**. Wave 2 adds disk/cloud-init modules, Li-native hypervisor probe, and Windows in multi-OS matrix.

> **Interim stubs:** Wave 1 delivered `src/hypervisor/kvm.li` as a scaffold filename only. Do not extend KVM/QEMU — retarget new work to `li-hypervisor` and delete kvm stubs once the native backend gate passes.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-V0** | package scaffold | **DONE** | `check-libernetes-livm-scaffold-gate.sh` |
| **LB-V1** | hypervisor backend interface | **DONE** | `check-libernetes-livm-hypervisor-gate.sh` |
| **LB-V2** | VirtualMachine CRD yaml | **DONE** | `check-libernetes-livm-crd-gate.sh` |
| **LB-V3** | `src/hypervisor/kvm.li` (legacy stub — **deprecated**) | **DONE** | `check-libernetes-livm-wave1-gate.sh` |
| **LB-V4** | `docs/libernetes/multi-os-matrix.md` | **DONE** | same wave1 gate |
| **LB-V5** | `li-tests/smoke/builds.li` | **DONE** | same wave1 gate |
| **LB-V6** | `src/disk/qcow2.li` | pending | `check-libernetes-livm-wave2-gate.sh` |
| **LB-V7** | `src/cloudinit/cloudinit.li` | pending | same wave2 gate |
| **LB-V8** | `src/hypervisor/li_native_probe.li` + Windows in matrix | pending | same wave2 gate |
| **LB-V9** | `src/hypervisor/li_native.li` — Li-native backend MVP | pending | wave3 gate (planned) |

## Completion gate

```bash
bash scripts/check-libernetes-livm-gate.sh
```
