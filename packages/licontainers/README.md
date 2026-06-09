# licontainers

OCI runtime + CRI v1 for libernetes.

**Li-native way:** `LiOSBackend` — process/namespace/cgroup isolation via LiOS kernel ABI.

> **Industry reference:** OCI image spec + CRI v1 gRPC; compare vs containerd in `li-cluster-bench`.
>
> **Interim shim (dev-only):** `linux_backend.li` — cgroups v2 + namespaces on Linux hosts during LiOS bring-up.
