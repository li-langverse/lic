# livm

Multi-OS VM runtime for libernetes via the **Li-native stack**:

- `li-hypervisor` / LiOS ABI
- `li-firmware` measured boot
- `li-disk` CoW
- `li-cloud-init`

> **Industry reference:** KubeVirt API compat; KVM/QEMU cold-boot baselines in `li-cluster-bench`; OVMF/UEFI for guest image compat notes only.
>
> **Interim shim (dev-only):** Wave 1 `kvm.li` stub filename — not a production backend.
