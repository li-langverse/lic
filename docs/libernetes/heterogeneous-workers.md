# Heterogeneous worker registration

Workers register capabilities on join — no manual `kubectl label` for defaults.

## WorkerProfile CRD

See [crd-workerprofile.yaml](crd-workerprofile.yaml).

```yaml
apiVersion: libernetes.io/v1
kind: WorkerProfile
metadata:
  name: vm-gpu-pool
spec:
  capabilities: [hypervisor, gpu]
  architectures: [amd64]
  runtimes: [vm, container]
```

Join: `libernetes worker join ... --profile vm-gpu-pool`

## Auto-discovery

| Signal | Label |
|--------|-------|
| `uname -m` | `libernetes.io/arch` |
| LiOS + `li-hypervisor` | `libernetes.io/hypervisor=li-native` |
| cgroups v2 | `libernetes.io/container=true` |
| GPU/VFIO | `libernetes.io/gpu=true` |
| LiOS kernel | `libernetes.io/os=lios` |

VM workloads schedule only onto nodes with `libernetes.io/hypervisor=li-native`. KVM/QEMU capability labels are deprecated and not registered.

## Scheduling

- `RuntimeClass`: `container`, `vm`, `microvm`
- Scheduler matches WorkerProfile + node labels to pod/VM spec
