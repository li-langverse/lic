# libernetes architecture

## Control plane

- `li-apiserver`, `li-scheduler`, `li-controller-manager`, `li-etcd` client
- Unified workloads: **containers** (licontainers/CRI) + **VMs** (livm)
- **Industry reference:** K8s API parity matrix — libernetes implements native Li components with drop-in compat, not a Go control-plane fork

## Data plane

- `li-kubelet` dual sync: CRI + VM API
- `li-cni-*`, `li-kube-proxy`
- **Industry reference:** CNI spec for plugin protocol; bridge/macvlan patterns as learn-from during Wave 3

## Li-native first, industry-informed

Every subsystem ships a Li-native path. Foreign stacks appear as learn-from, API-compat, benchmark baseline, or interim dev shim — never as production north star. See [../libernetes-roadmap.md](../libernetes-roadmap.md#li-native-first-industry-informed).

### livm (VM runtime)

| | |
|---|---|
| **Li-native way** | `li-hypervisor` via LiOS ABI; `li-firmware` measured boot; `li-disk` CoW; `li-cloud-init` |
| **Industry reference** | KubeVirt API compat for CRDs; KVM/QEMU cold-boot baseline in `li-cluster-bench`; OVMF/UEFI cited for guest image compat only |
| **Interim shim** | `kvm.li` / `kvm_probe.li` Wave 1 stub filenames — dev-only, not production |

### licontainers (container runtime)

| | |
|---|---|
| **Li-native way** | `LiOSBackend` — process/namespace/cgroup isolation via LiOS kernel ABI |
| **Industry reference** | OCI image spec + CRI v1 gRPC; compare pull/start latency vs containerd in benchmarks |
| **Interim shim** | `linux_backend.li` — cgroups v2 + namespaces on Linux hosts during LiOS bring-up |

## Easy setup

- `libernetes init --profile homelab|ha`
- `libernetes worker join --profile auto`

See [easy-setup.md](easy-setup.md).
