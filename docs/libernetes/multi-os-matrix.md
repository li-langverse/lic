# livm multi-OS matrix

Support matrix for **livm** VM runtime backends. Wave 1 ships stubs and scheduling labels; full probes and launch paths follow in Wave 2.

## Backends

| Backend | Module | Tag (`backend.li`) | Host signal |
|---------|--------|--------------------|-------------|
| KVM (Linux) | `packages/livm/src/hypervisor/kvm.li` | `1` | `/dev/kvm` → `libernetes.io/kvm=true` |
| LiOS native | `packages/livm/src/hypervisor/backend.li` | `2` | LiOS kernel → `libernetes.io/os=lios` |

## Host OS × architecture

| Host OS | Arch | Hypervisor | Worker label | Wave 1 status |
|---------|------|------------|--------------|-----------------|
| Linux | amd64 | KVM | `libernetes.io/arch=amd64` | stub (`kvm_probe_signal` → 0) |
| Linux | arm64 | KVM | `libernetes.io/arch=arm64` | stub |
| LiOS | amd64 | native | `libernetes.io/os=lios` | planned |
| LiOS | arm64 | native | `libernetes.io/os=lios` | planned |
| macOS | arm64 | — | — | out of scope (Wave 3) |
| Windows | amd64 | — | — | out of scope (Wave 3) |

## Scheduling

- **RuntimeClass** values: `vm`, `microvm` (see [heterogeneous-workers.md](heterogeneous-workers.md)).
- Scheduler matches `WorkerProfile` capabilities (`kvm`, `gpu`) and node labels to `VirtualMachine` specs.
- KVM workers require `libernetes.io/kvm=true`; LiOS workers use the native hypervisor path when `libernetes.io/os=lios`.

## Verification

```bash
bash scripts/check-libernetes-livm-wave1-gate.sh
bash scripts/check-libernetes-livm-gate.sh
```
