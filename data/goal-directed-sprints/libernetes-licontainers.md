---
workflow_repo: lic
branch: cursor/libernetes-licontainers
plan: docs/libernetes/master-plan.md
---

# libernetes licontainers — goal-directed sprint

**Branch:** `cursor/libernetes-licontainers`  
**Agent:** `code_implementer`

## Mission

Build **licontainers** OCI/CRI runtime package on the **Li-native path**:

- **Production:** `LiOSBackend` — process/namespace/cgroup isolation via LiOS kernel ABI
- **OCI/CRI:** `li-cri` + `li-runtime` + `li-image` (native Li implementations)

Wave 0 scaffold **DONE**. Wave 1 **DONE**. Wave 2 adds OCI image pull + CRI lifecycle integration test.

> **Industry reference:** OCI image spec + CRI v1 gRPC protocol; compare pull/start latency vs containerd in `li-cluster-bench`.
>
> **Interim shim (dev-only):** `src/runtime/linux_backend.li` — cgroups v2 + namespaces on Linux hosts during LiOS bring-up. Not the production north star.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-C0** | package scaffold | **DONE** | `check-libernetes-licontainers-scaffold-gate.sh` |
| **LB-C1** | OCI spec stub | **DONE** | `check-libernetes-licontainers-oci-gate.sh` |
| **LB-C2** | CRI v1 stub | **DONE** | `check-libernetes-licontainers-cri-gate.sh` |
| **LB-C3** | `src/runtime/linux_backend.li` (interim shim — dev-only) | **DONE** | `check-libernetes-licontainers-wave1-gate.sh` |
| **LB-C4** | `li-tests/smoke/builds.li` + manifest | **DONE** | same wave1 gate |
| **LB-C5** | `src/oci/image.li` | **DONE** | `check-libernetes-licontainers-wave2-gate.sh` |
| **LB-C6** | `src/runtime/create.li` + `start.li` | **DONE** | same wave2 gate |
| **LB-C7** | `li-tests/integration/cri_lifecycle.li` | **DONE** | same wave2 gate |

## Completion gate

```bash
bash scripts/check-libernetes-licontainers-gate.sh
```
