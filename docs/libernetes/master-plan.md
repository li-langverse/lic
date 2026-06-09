# libernetes master plan (Wave 0–9)

**Rendered roadmap (diagrams + wave table):** [../libernetes-roadmap.md](../libernetes-roadmap.md)

Canonical detailed plan: Cursor plan `libernetes_master_plan_bc3b669a.plan.md`.

## Delivery waves (K8s runners)

```mermaid
flowchart LR
  subgraph done [Merged]
    W0[Wave 0 specs]
    W1[Wave 1 scaffolds]
    W2[Wave 2 APIs]
  end

  subgraph dist [Distributed]
    W3[Wave 3 ACTIVE<br/>run-local stack]
    W4[Wave 4 join]
    W5[Wave 5 dispatch]
    W6[Wave 6 bench]
  end

  subgraph ops [Cluster ops]
    W7[Wave 7 self-heal]
    W8[Wave 8 persistence]
    W9[Wave 9 dashboard]
  end

  W10[Wave 10+ cutover]

  W0 --> W1 --> W2 --> W3 --> W4 --> W5 --> W6 --> W7 --> W8 --> W9 --> W10
```

| Wave | Focus | Active gate |
|------|-------|-------------|
| 0–2 | Docs, stubs, etcd/CRI/livm foundations | merged to `main` |
| 3 | Single-node runnable (`libernetes-run-local`, daemons, kubelet sync) | `check-libernetes-*-wave3-gate.sh` |
| 4 | Multi-node registry + worker join persistence | scripted, unwired |
| 5 | Scheduler + kubelet workload dispatch | scripted, unwired |
| 6 | `li-cluster-bench` + distributed e2e | scripted, unwired |
| 7 | ReplicaSet/Node self-healing (`self_heal.li`) | scripted, unwired |
| 8 | PV/PVC + etcd backup + reboot recovery | scripted, unwired |
| 9 | `li-metrics` + node conditions + dashboard | scripted, unwired |

## Pillars

1. **libernetes** — 100% Li Kubernetes control plane (containers + VMs)
2. **licontainers** — OCI/CRI runtime (`LiOSBackend` primary)
3. **livm** — multi-OS VM runtime via **Li-native hypervisor** (`li-hypervisor` / LiOS ABI)
4. **LiOS** — kernel ABI + native hypervisor (production path for VMs and containers)

## Li-native first, industry-informed

Every subsystem has a **Li-native production path**. Industry references (KVM, QEMU, OVMF/UEFI, containerd/runc, KubeVirt) are cited for learn-from, API-compat, benchmark baselines, or interim dev shims — not as the target architecture.

| Area | Li-native way | Industry reference |
|------|---------------|-------------------|
| Hypervisor | `li-hypervisor` / LiOS ABI | KVM/QEMU design patterns |
| Firmware | `li-firmware` measured boot | OVMF/UEFI guest-compat notes |
| Containers | `LiOSBackend` + licontainers | OCI/CRI spec; containerd API shape |
| Disk | `li-disk` CoW | qemu-img CoW patterns |
| CNI | `li-cni` native | CNI spec compat |
| API | `li-apiserver` | K8s API parity matrix |

> **Interim shim (dev-only):** Wave 1–2 scaffolds may still name `kvm.li` / `linux_backend.li` — not production backends.

## Target architecture

```mermaid
flowchart TB
  subgraph runtime [livm production]
    vapi[li-vm API]
    hypervisor[li-hypervisor]
    disk[li-disk CoW]
    firmware[li-firmware measured boot]
    cloudinit[li-cloud-init]
  end

  subgraph os [LiOS]
    lios[LiOS kernel ABI]
    hvabi[li-hypervisor syscall surface]
  end

  subgraph ref ["industry reference"]
    kvmref[KVM/QEMU learn-from]
    ovmfref[OVMF/UEFI compat]
  end

  kubelet[li-kubelet] --> vapi
  vapi --> hypervisor
  hypervisor --> disk
  hypervisor --> firmware
  hypervisor --> cloudinit
  hypervisor --> hvabi
  hvabi --> lios

  kvmref -.-> hypervisor
  ovmfref -.-> firmware
```

## Easy setup (product requirement)

```bash
libernetes init --profile homelab
libernetes worker join https://cp:6443 --token <token> --profile auto
```

Auto-discover: arch, `libernetes.io/hypervisor=li-native`, GPU, container/VM runtimes. See [easy-setup.md](easy-setup.md) and [heterogeneous-workers.md](heterogeneous-workers.md).

## Goal-directed workers

| Track | Branch | Goal file |
|-------|--------|-----------|
| platform | `cursor/libernetes-platform` | `data/goal-directed-sprints/libernetes-platform.md` |
| licontainers | `cursor/libernetes-licontainers` | `data/goal-directed-sprints/libernetes-licontainers.md` |
| livm | `cursor/libernetes-livm` | `data/goal-directed-sprints/libernetes-livm.md` |
| control | `cursor/libernetes-control` | `data/goal-directed-sprints/libernetes-control.md` |
