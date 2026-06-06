# li-parallel — Native Parallel + Distributed HPC (redirect)

**Canonical sprint goal:** [`li-parallel-killer-package.md`](./li-parallel-killer-package.md)

This file is retained for K8s ConfigMap compatibility during rollout. All WP status, phase tracking, and gate definitions live in the killer package goal.

## Gates

**Progress (each agent loop):**

```bash
bash scripts/check-li-parallel-full-suite.sh
```

**Completion (ship criterion):**

```bash
bash scripts/check-li-parallel-killer-gate.sh
```

See `li-parallel-killer-package.md` for the full phase checklist (Phases 0–99), chip package rules, and honest WP status.

**Agent rules:** Do not weaken gates. Do not mark phases **DONE** until sub-gates pass. `LIPAR_KILLER_SKIP_FULL` is removed.
