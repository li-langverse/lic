# livm

Multi-OS VM runtime for libernetes via the **Li-native stack**:

- `li-hypervisor` / LiOS ABI
- `li-firmware` measured boot
- `li-disk` CoW
- `li-cloud-init`

Wave 2 modules: `disk/qcow2.li`, `cloudinit/cloudinit.li`, `hypervisor/kvm_probe.li`.

Wave 3: `hypervisor/lios_probe.li` — LiOS native hypervisor probe (production path).

Wave 4: `runtime/remote.li` — cross-node VM runtime stub for multi-node registry.

> **Industry reference:** KubeVirt API compat; KVM/QEMU cold-boot baselines in `li-cluster-bench`; OVMF/UEFI for guest image compat notes only.
>
> **Interim shim (dev-only):** Wave 1 `kvm.li` stub filename — not a production backend.
