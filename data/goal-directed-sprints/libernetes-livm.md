---
workflow_repo: lic
branch: cursor/libernetes-livm
plan: docs/libernetes/master-plan.md
---

# libernetes livm — goal-directed sprint

**Branch:** `cursor/libernetes-livm`  
**Agent:** `code_implementer`

## Mission

Build **livm** VM runtime on the **Li-native stack**:

- **Hypervisor:** `li-hypervisor` / LiOS ABI (production)
- **Firmware:** `li-firmware` measured boot (production)
- **Disk:** `li-disk` CoW
- **Config:** `li-cloud-init`

Wave 0 **DONE**. Wave 1 **DONE**. Wave 2 adds disk/cloud-init modules, Li-native hypervisor probe, and Windows in multi-OS matrix.

> **Industry reference:** KubeVirt API compat for CRDs; KVM/QEMU cold-boot baselines in `li-cluster-bench`; OVMF/UEFI cited for guest image compat only — not production firmware.
>
> **Interim shim (dev-only):** Wave 1 `src/hypervisor/kvm.li` is a stub filename for gate compatibility. Retarget new work to `li-hypervisor`; delete kvm stubs once native backend gate passes.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-V0** | package scaffold | **DONE** | `check-libernetes-livm-scaffold-gate.sh` |
| **LB-V1** | hypervisor backend interface | **DONE** | `check-libernetes-livm-hypervisor-gate.sh` |
| **LB-V2** | VirtualMachine CRD yaml | **DONE** | `check-libernetes-livm-crd-gate.sh` |
| **LB-V3** | `src/hypervisor/kvm.li` (interim shim — dev-only) | **DONE** | `check-libernetes-livm-wave1-gate.sh` |
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
