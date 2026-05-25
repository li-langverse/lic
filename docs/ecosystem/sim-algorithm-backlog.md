# Simulation algorithm backlog (agent todos)

**Status:** Active  
**Registry:** `benchmarks/competitive/algo_registry.json`

---

todos:
- id: gap-sim-sim-p1-num-dot-axpy
  content: "sim: pending plan todo sim-p1-num-dot-axpy"
  status: pending
  gap_orchestrator: true
- id: gap-sim-sim-p1-md-neighbor-cell
  content: "sim: pending plan todo sim-p1-md-neighbor-cell"
  status: pending
  gap_orchestrator: true
- id: gap-sim-sim-p2-qm-dft-scf
  content: "sim: pending plan todo sim-p2-qm-dft-scf"
  status: pending
  gap_orchestrator: true




- id: sim-p0-md-lj-li-parity
  content: "Tier-2 Li md_lennard_jones checksum parity vs native (fix runtime sink / driver)"
  status: pending

- id: sim-p0-heat-li-smoke
  content: "Pure-Li heat_equation_2d smoke with harness verify row"
  status: pending

- id: sim-p1-num-dot-axpy
  content: "sim: pending plan todo sim-p1-num-dot-axpy — gap orchestrator"
  status: pending

- id: sim-p1-md-neighbor-cell
  content: "sim: pending plan todo sim-p1-md-neighbor-cell — gap orchestrator"
  status: pending

- id: sim-p2-qm-dft-scf
  content: "sim: pending plan todo sim-p2-qm-dft-scf — gap orchestrator"
  status: pending

---

## Agent instructions

- One todo per loop iteration (`sim-plan-loop.py`).
- After each slice: `./scripts/sim-plan-gates.sh` (uses `bench-package.sh`, not full tier-12).
- Update `implemented_smoke` in registry when a composable or tier-2 row exists.
