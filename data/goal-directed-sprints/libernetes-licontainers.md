---
workflow_repo: lic
branch: cursor/libernetes-licontainers
plan: docs/libernetes/master-plan.md
---

# libernetes licontainers — goal-directed sprint

**Branch:** `cursor/libernetes-licontainers`  
**Agent:** `code_implementer`

## Mission

Build **licontainers** OCI/CRI runtime. **Wave 0–2 DONE on `main`.** Active: **Wave 3** (CRI serve stub + local Unix socket for single-node stack).

## Phase checklist

| Phase | Deliverable | Status | Gate |
|-------|-------------|--------|------|
| **LB-C0–C4** | scaffold, OCI, CRI, linux backend, smoke | **DONE** | wave0–1 gates |
| **LB-C5–C7** | image pull, create/start, cri lifecycle test | **DONE** | `check-libernetes-licontainers-wave2-gate.sh` |
| **LB-C8** | `src/cri/serve.li` | pending | `check-libernetes-licontainers-wave3-gate.sh` |
| **LB-C9** | `src/runtime/cri_socket.li` | pending | same wave3 gate |
| **LB-C10** | `li-tests/integration/cri_socket_smoke.li` | pending | same wave3 gate |

## Later waves

| Wave | Focus | Gate |
|------|-------|------|
| 4 | Remote CRI stub | `check-libernetes-licontainers-wave4-gate.sh` |
| 5 | Distributed workload exec | `check-libernetes-licontainers-wave5-gate.sh` |
| 6 | CRI ops benchmark | `check-libernetes-licontainers-wave6-gate.sh` |
| 7 | Container restart policy | `check-libernetes-licontainers-wave7-gate.sh` |
| 8 | Volume persist across reboot | `check-libernetes-licontainers-wave8-gate.sh` |
| 9 | CRI metrics stub | `check-libernetes-licontainers-wave9-gate.sh` |

## Completion gate

```bash
bash scripts/check-libernetes-licontainers-gate.sh
```
