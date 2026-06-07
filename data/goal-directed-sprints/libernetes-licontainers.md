---
workflow_repo: lic
branch: cursor/libernetes-licontainers
plan: docs/libernetes/master-plan.md
---

# libernetes licontainers — goal-directed sprint (Wave 1 prep)

**Repos:** `lic` (primary)  
**Branch:** `cursor/libernetes-licontainers`  
**Agent:** `code_implementer`

## Mission

Scaffold **licontainers** in Li: OCI spec types, CRI v1 API surface, package layout, smoke tests. Linux backend implementation follows in later loops.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| **LB-C0** | `packages/licontainers/` + `li.toml`, README, traceability | `bash scripts/check-libernetes-licontainers-scaffold-gate.sh` |
| **LB-C1** | OCI runtime spec parser stub (`src/oci/spec.li`) + unit smoke | `bash scripts/check-libernetes-licontainers-oci-gate.sh` |
| **LB-C2** | CRI v1 proto/codegen plan + `src/cri/v1.li` interface stubs | `bash scripts/check-libernetes-licontainers-cri-gate.sh` |
| **LB-C3** | `li-tests/smoke/builds.li` compiles package | included in completion gate |

## Progress gate

```bash
bash scripts/check-libernetes-licontainers-progress-gate.sh
```

## Completion gate

```bash
bash scripts/check-libernetes-licontainers-gate.sh
```
