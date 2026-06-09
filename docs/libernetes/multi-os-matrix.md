# livm multi-OS matrix

Support matrix for **livm** VM runtime. Li-native hypervisor and firmware are the production path; industry stacks cited for learn-from and guest-compat only.

## Li-native production path

| Component | Li-native way | Industry reference |
|-----------|---------------|-------------------|
| Hypervisor | `li-hypervisor` / LiOS ABI (`backend.li` tag `2`) | KVM/QEMU design patterns |
| Firmware | `li-firmware` measured boot (no OVMF blobs) | OVMF/UEFI for guest image compat notes |
| Disk | `li-disk` CoW (`disk/qcow2.li`) | qemu-img CoW as reference |
| Config | `li-cloud-init` (NoCloud / ConfigDrive) | cloud-init, Ignition subsets |
| API | `VirtualMachine` CRD (`kubevirt.io/v1` shape) | KubeVirt API compat |

## Host OS × architecture

| Host OS | Arch | Hypervisor | Worker label | Status |
|---------|------|------------|--------------|--------|
| LiOS | amd64 | `li-hypervisor` native | `libernetes.io/hypervisor=li-native` | production target |
| LiOS | arm64 | `li-hypervisor` native | `libernetes.io/hypervisor=li-native` | production target |
| Linux | amd64 | — (no KVM production path) | `libernetes.io/container=true` | container-only until LiOS node |
| macOS | arm64 | — | — | out of scope (Wave 3) |
| Windows | amd64 | — | — | host out of scope (Wave 3) |

> **Interim shim (dev-only):** Wave 1 `kvm.li` stub exists for gate compatibility — not a production backend. Do not extend.

## Guest OS (Li-native hypervisor workers)

| Guest OS | Arch | Boot | Config injection | Status |
|----------|------|------|------------------|--------|
| Linux | amd64, arm64 | Li-native firmware | NoCloud (`cloudinit/cloudinit.li`) | Wave 2 stub |
| Windows | amd64 | Li-native firmware | ConfigDrive | Wave 2 stub |
| FreeBSD / BSD | amd64 | Li-native firmware | cloud-init subset | planned |
| LiOS guest | amd64, arm64 | LiOS hypervisor ABI | native | LiOS M2+ |

Guests boot via **Li-native firmware** + measured boot — not UEFI+OVMF as the primary framing. Cloud-init remains for first-boot config injection.

## Scheduling

- **RuntimeClass** values: `vm`, `microvm` (see [heterogeneous-workers.md](heterogeneous-workers.md))
- Scheduler matches `WorkerProfile` capabilities (`hypervisor`, `gpu`) and `libernetes.io/hypervisor=li-native`
- **Industry reference:** KubeVirt instancetype/preference patterns for VM sizing

## Verification

```bash
bash scripts/check-libernetes-livm-wave1-gate.sh
bash scripts/check-libernetes-livm-wave2-gate.sh
bash scripts/check-libernetes-livm-gate.sh
```
