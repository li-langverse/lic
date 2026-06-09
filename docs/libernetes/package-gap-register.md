# Package gap register (libernetes Wave 0)

| Package | Status | Needed for |
|---------|--------|------------|
| li-etcd | stub | apiserver persistence |
| li-grpc | stub | CRI, webhooks |
| li-watch | stub | informers |
| li-workqueue | stub | controllers |
| li-oci | stub | licontainers |
| li-hypervisor | missing | livm Li-native VM backend (LiOS ABI) |
| li-firmware | missing | livm measured boot (Li-native; OVMF/UEFI compat notes only) |
| li-disk | missing | livm CoW disk (qemu-img patterns as reference) |
| licontainers | scaffold | containers (LiOSBackend primary) |
| livm | scaffold | VMs |
| li-libernetes-core | scaffold | shared types |

Update this file as stubs land.
