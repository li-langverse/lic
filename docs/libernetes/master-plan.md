# libernetes master plan (Wave 0–9)

Canonical detailed plan: Cursor plan `libernetes_master_plan_bc3b669a.plan.md`.

## Status (2026-06-08)

| Milestone | State |
|-----------|--------|
| Wave 0–2 scaffolds | **Merged to `main`** |
| Waves 3–6 | Distributed stack → dispatch → benchmarks |
| **Waves 7–9** | **Self-healing, reboot persistence, monitoring + dashboard** |
| Live cluster | **Not running** — homelab on k3s; K8s runners on engine |

## K8s runner waves

| Wave | Theme |
|------|--------|
| 3 | Single-node runnable stack |
| 4 | Multi-node registry |
| 5 | Scheduler dispatch |
| 6 | Perf + e2e |
| **7** | ReplicaSet/Node controllers, restart policies |
| **8** | PV/PVC, etcd backup, reboot recovery |
| **9** | li-metrics, node conditions, dashboard |

See [distributed-workloads.md](distributed-workloads.md) and [cluster-operations.md](cluster-operations.md).

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
- [distributed-workloads.md](distributed-workloads.md)
- [cluster-operations.md](cluster-operations.md) — resilience, persistence, monitoring, dashboard
- [easy-setup.md](easy-setup.md)
- [heterogeneous-workers.md](heterogeneous-workers.md)
- [join-flow.md](join-flow.md)
- [multi-os-matrix.md](multi-os-matrix.md)
- [package-gap-register.md](package-gap-register.md)
