---
workflow_repo: lic
branch: cursor/libernetes-platform
plan: docs/libernetes/master-plan.md
---

# libernetes platform — goal-directed sprint (Wave 0)

**Repos:** `lic` (primary)  
**Branch:** `cursor/libernetes-platform`  
**Agent:** `code_implementer` (`LI_SWARM_EXTERNAL=1`)

## Mission

Wave 0 **platform foundation** for libernetes: specs, package scaffolding, foundation-package stubs, and easy-setup / heterogeneous-worker documentation. See plan: `docs/libernetes/master-plan.md`.

## Iteration rules

1. Implement one phase row per loop; commit + push every iteration.
2. Run **Progress gate** before ending each iteration.
3. Do not mark done until **Completion gate** passes.
4. Append rows to `data/libernetes-platform/iteration-log.md`.

## Phase checklist

| Phase | Deliverable | Gate |
|-------|-------------|------|
| **LB-P0** | `docs/libernetes/` tree (architecture, easy-setup, heterogeneous-workers, package-gap-register) | `bash scripts/check-libernetes-platform-docs-gate.sh` |
| **LB-P1** | `packages/li-libernetes-core/` scaffold + `li.toml` workspace entry | `bash scripts/check-libernetes-platform-package-gate.sh` |
| **LB-P2** | Foundation stubs: `li-watch`, `li-workqueue`, `li-etcd` package dirs + README traceability | `bash scripts/check-libernetes-foundation-stubs-gate.sh` |
| **LB-P3** | `scripts/libernetes-wave0-specs-gate.sh` aggregates all Wave 0 platform checks | included in completion gate |

## Do not

- Skip contracts on new `def` in package stubs.
- Weaken gates or mark phases DONE without green gate output.
- Share workspace PVC with other libernetes workers (K8s isolation).

## Progress gate

```bash
bash scripts/check-libernetes-platform-progress-gate.sh
```

## Completion gate

```bash
bash scripts/check-libernetes-platform-gate.sh
```
