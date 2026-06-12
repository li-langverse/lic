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

**Waves 0–4 DONE.** Active: **Wave 5** (distributed VM exec).

> **Industry reference:** KubeVirt API compat for CRDs; KVM/QEMU cold-boot baselines in `li-cluster-bench`; OVMF/UEFI cited for guest image compat only — not production firmware.
>
> **Interim shim (dev-only):** Wave 1 `src/hypervisor/kvm.li` is a stub filename for gate compatibility. Retarget new work to `li-hypervisor`; delete kvm stubs once native backend gate passes.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-V0–V5** | scaffold, KVM, matrix, smoke | **DONE** | wave0–1 gates |
| **LB-V6–V8** | qcow2, cloud-init, kvm probe, Windows | **DONE** | `check-libernetes-livm-wave2-gate.sh` |
| **LB-V9** | `src/hypervisor/lios_probe.li` | **DONE** | `check-libernetes-livm-wave3-gate.sh` |
| **LB-V10** | LiOS row in `multi-os-matrix.md` | **DONE** | same wave3 gate |
| **LB-V11** | `li-tests/smoke/lios_probe_smoke.li` | **DONE** | same wave3 gate |
| **LB-V12** | `src/runtime/remote.li` | **DONE** | `check-libernetes-livm-wave4-gate.sh` |
| **LB-V13** | `li-tests/integration/remote_vm.li` | **DONE** | same wave4 gate |

## Later waves (unwired until Wave 5 passes)

| Wave | Focus | Gate |
|------|-------|------|
| 5 | Distributed VM exec | `check-libernetes-livm-wave5-gate.sh` |
| 6 | VM boot benchmark | `check-libernetes-livm-wave6-gate.sh` |
| 7 | VM restart policy | `check-libernetes-livm-wave7-gate.sh` |
| 8 | Disk persist across reboot | `check-libernetes-livm-wave8-gate.sh` |
| 9 | VM metrics stub | `check-libernetes-livm-wave9-gate.sh` |

## Iteration rules

1. Implement **LB-V14/V15** (Wave 5) until completion gate passes.
2. Commit + push every iteration.

## Completion gate

```bash
bash scripts/check-libernetes-livm-gate.sh
```
