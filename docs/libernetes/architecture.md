# libernetes architecture

## Control plane

- `li-apiserver`, `li-scheduler`, `li-controller-manager`, `li-etcd` client
- Unified workloads: **containers** (licontainers/CRI) + **VMs** (livm)

## Data plane

- `li-kubelet` dual sync: CRI + VM API
- `li-cni-*`, `li-kube-proxy`

## livm (Li-native hypervisor only)

- **Production path:** `li-hypervisor` via LiOS ABI — hardware virtualization without KVM/QEMU/libvirt
- **Removed from target:** KVM, QEMU, libvirt, KubeVirt-style Linux backends
- **Interim stubs:** Wave 1–2 scaffolds may still name `kvm.li` / `kvm_probe.li`; these are legacy placeholders, not the shipping architecture

## Easy setup

- `libernetes init --profile homelab|ha`
- `libernetes worker join --profile auto`

See [easy-setup.md](easy-setup.md).
