# livm multi-OS matrix

Support matrix for **livm** VM runtime backends. Wave 1 shipped stubs and scheduling labels; Wave 2 adds qcow2 disk, cloud-init, KVM probe, and Windows guest stubs.

## Backends

| Backend | Module | Tag (`backend.li`) | Host signal |
|---------|--------|--------------------|-------------|
| KVM (Linux) | `packages/livm/src/hypervisor/kvm.li` | `1` | `/dev/kvm` → `libernetes.io/kvm=true` |
| LiOS native | `packages/livm/src/hypervisor/backend.li` | `2` | LiOS kernel → `libernetes.io/os=lios` |

## Host OS × architecture

| Host OS | Arch | Hypervisor | Worker label | Wave 2 status |
|---------|------|------------|--------------|-----------------|
| Linux | amd64 | KVM | `libernetes.io/arch=amd64` | probe stub (`kvm_probe.li`) |
| Linux | arm64 | KVM | `libernetes.io/arch=arm64` | probe stub |
| LiOS | amd64 | native | `libernetes.io/os=lios` | planned |
| LiOS | arm64 | native | `libernetes.io/os=lios` | planned |
| macOS | arm64 | — | — | out of scope (Wave 3) |
| Windows | amd64 | — | — | host out of scope (Wave 3) |

## Guest OS (KVM workers)

| Guest OS | Arch | Disk | Cloud-init module | Wave 2 status |
|----------|------|------|-------------------|-----------------|
| Linux | amd64, arm64 | qcow2 (`disk/qcow2.li`) | NoCloud (`cloudinit/cloudinit.li`) | stub |
| Windows | amd64 | qcow2 | ConfigDrive | stub (Wave 2) |

Windows guests run on Linux KVM workers via qcow2 backing images and ConfigDrive cloud-init; full launch paths follow in Wave 3.

## Scheduling

- **RuntimeClass** values: `vm`, `microvm` (see [heterogeneous-workers.md](heterogeneous-workers.md)).
- Scheduler matches `WorkerProfile` capabilities (`kvm`, `gpu`) and node labels to `VirtualMachine` specs.
- KVM workers require `libernetes.io/kvm=true`; LiOS workers use the native hypervisor path when `libernetes.io/os=lios`.

## Verification

```bash
bash scripts/check-libernetes-livm-wave1-gate.sh
bash scripts/check-libernetes-livm-wave2-gate.sh
bash scripts/check-libernetes-livm-gate.sh
```
