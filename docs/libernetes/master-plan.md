# libernetes master plan (Wave 0–6)

Canonical detailed plan: Cursor plan `libernetes_master_plan_bc3b669a.plan.md`.

## Status (2026-06-08)

| Milestone | State |
|-----------|--------|
| Wave 0–2 scaffolds | **Merged to `main`** (PRs #1254, #1257, #1258, #1270) |
| Live libernetes cluster | **Not running** — homelab still on k3s |
| K8s implementation workers | **Running** on engine (`li-swarm`) |
| Distributed workloads | **Wave 3 active** — see [distributed-workloads.md](distributed-workloads.md) |

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

## K8s runner waves (distributed focus)

| Wave | Goal | Key gates |
|------|------|-----------|
| **0–2** | Docs, stubs, init/join scripts, Wave 2 APIs | `check-libernetes-*-wave2-gate.sh` |
| **3** | Single-node runnable stack (daemons, sync, run-local) | `*-wave3-gate.sh` |
| **4** | Multi-node registry + worker join config | `*-wave4-gate.sh` |
| **5** | Scheduler dispatch + kubelet workload sync | `*-wave5-gate.sh` |
| **6** | `li-cluster-bench` + pod churn + distributed e2e | `*-wave6-gate.sh` |

After Wave 6: CNCF conformance subset, homelab k3s cutover (Phase 7).

## Goal-directed workers

| Track | Branch | Goal file |
|-------|--------|-----------|
| platform | `cursor/libernetes-platform` | `data/goal-directed-sprints/libernetes-platform.md` |
| licontainers | `cursor/libernetes-licontainers` | `data/goal-directed-sprints/libernetes-licontainers.md` |
| livm | `cursor/libernetes-livm` | `data/goal-directed-sprints/libernetes-livm.md` |
| control | `cursor/libernetes-control` | `data/goal-directed-sprints/libernetes-control.md` |

Deploy / restart: [implementation-workers.md](implementation-workers.md).

## Docs index

- [architecture.md](architecture.md)
- [distributed-workloads.md](distributed-workloads.md) — **new: multi-node + dispatch roadmap**
- [easy-setup.md](easy-setup.md)
- [heterogeneous-workers.md](heterogeneous-workers.md)
- [join-flow.md](join-flow.md)
- [multi-os-matrix.md](multi-os-matrix.md)
- [package-gap-register.md](package-gap-register.md)
