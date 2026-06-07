# libernetes master plan (Wave 0–3)

Canonical detailed plan: Cursor plan `libernetes_master_plan_bc3b669a.plan.md`.

## Pillars

1. **libernetes** — 100% Li Kubernetes control plane (containers + VMs)
2. **licontainers** — OCI/CRI runtime
3. **livm** — multi-OS VM runtime (KVM + LiOS hypervisor)
4. **LiOS** — kernel ABI + native hypervisor (parallel track)

## Easy setup (product requirement)

```bash
libernetes init --profile homelab
libernetes worker join https://cp:6443 --token <token> --profile auto
```

Auto-discover: arch, KVM, GPU, container/VM runtimes. See [easy-setup.md](easy-setup.md) and [heterogeneous-workers.md](heterogeneous-workers.md).

## Goal-directed workers

| Track | Branch | Goal file |
|-------|--------|-----------|
| platform | `cursor/libernetes-platform` | `data/goal-directed-sprints/libernetes-platform.md` |
| licontainers | `cursor/libernetes-licontainers` | `data/goal-directed-sprints/libernetes-licontainers.md` |
| livm | `cursor/libernetes-livm` | `data/goal-directed-sprints/libernetes-livm.md` |
| control | `cursor/libernetes-control` | `data/goal-directed-sprints/libernetes-control.md` |
