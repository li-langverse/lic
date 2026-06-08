---
workflow_repo: lic
branch: cursor/libernetes-licontainers
plan: docs/libernetes/master-plan.md
---

# libernetes licontainers — goal-directed sprint

**Branch:** `cursor/libernetes-licontainers`  
**Agent:** `code_implementer`

## Mission

Build **licontainers** OCI/CRI runtime package. Wave 0 scaffold **DONE**. Wave 1 **DONE**. Wave 2 adds OCI image pull + CRI lifecycle integration test.

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-C0** | package scaffold | **DONE** | `check-libernetes-licontainers-scaffold-gate.sh` |
| **LB-C1** | OCI spec stub | **DONE** | `check-libernetes-licontainers-oci-gate.sh` |
| **LB-C2** | CRI v1 stub | **DONE** | `check-libernetes-licontainers-cri-gate.sh` |
| **LB-C3** | `src/runtime/linux_backend.li` | **DONE** | `check-libernetes-licontainers-wave1-gate.sh` |
| **LB-C4** | `li-tests/smoke/builds.li` + manifest | **DONE** | same wave1 gate |
| **LB-C5** | `src/oci/image.li` | **DONE** | `check-libernetes-licontainers-wave2-gate.sh` |
| **LB-C6** | `src/runtime/create.li` + `start.li` | **DONE** | same wave2 gate |
| **LB-C7** | `li-tests/integration/cri_lifecycle.li` | **DONE** | same wave2 gate |

## Completion gate

```bash
bash scripts/check-libernetes-licontainers-gate.sh
```
