# libernetes architecture

## Control plane

- `li-apiserver`, `li-scheduler`, `li-controller-manager`, `li-etcd` client
- Unified workloads: **containers** (licontainers/CRI) + **VMs** (livm)

## Data plane

- `li-kubelet` dual sync: CRI + VM API
- `li-cni-*`, `li-kube-proxy`

## Easy setup

- `libernetes init --profile homelab|ha`
- `libernetes worker join --profile auto`

See [easy-setup.md](easy-setup.md).
