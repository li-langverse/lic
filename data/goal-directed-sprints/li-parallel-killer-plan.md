---
workflow_repo: lic
branch: cursor/li-parallel-native-hpc
---

# li-parallel killer plan — agent loop todos

Plan loop for `goal-directed-loop` stuck detection (`LI_GOAL_SELF_UNBLOCK=1`).

## Todos

- id: par100-gpar-registers
  content: Mark G-par **Done** in gap-register.md and proofs-table.md (compiler-supported surface only)
  status: done

- id: par100-proofs-complete-gate
  content: Green `scripts/check-li-parallel-proofs-complete-gate.sh` (proofs gate + G-par Done markers + Discharge builtins)
  status: pending

- id: par99-killer-gate
  content: Green `scripts/check-li-parallel-killer-gate.sh` (152 benchmarks dual-mode, all sub-gates)
  status: done

- id: par101-goal-complete-gate
  content: Green `scripts/check-li-parallel-goal-complete-gate.sh` (killer + proofs-complete)
  status: pending

- id: par102-ci-enforced
  content: PR #881 lipar-killer-gate + build-and-test green on cursor/li-parallel-native-hpc
  status: pending
