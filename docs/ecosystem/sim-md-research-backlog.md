# MD simulation algorithm research backlog

**Status:** Active  
**Vertical:** `md`  
**Registry:** `benchmarks/competitive/algo_registry.json` (family `md`, ids 101–120)  
**Implement loop:** `docs/ecosystem/sim-algorithm-backlog.md` on `cursor/sim-algo-plan-loop`

---

todos:
- id: gap-sim-md-research-md-r1-stability-matrix
  content: "sim-md-research: pending plan todo md-r1-stability-matrix"
  status: pending
  gap_orchestrator: true
- id: gap-sim-md-research-md-r2-neighbor-list-gap
  content: "sim-md-research: pending plan todo md-r2-neighbor-list-gap"
  status: pending
  gap_orchestrator: true
- id: gap-sim-md-research-md-r3-oracle-plan
  content: "sim-md-research: pending plan todo md-r3-oracle-plan"
  status: pending
  gap_orchestrator: true




- id: md-r0-sota-survey
  content: "LAMMPS/GROMACS/OpenMM — integrators, neighbor lists, cutoffs; map to algo_registry 101–120"
  status: pending
  study_only: true

- id: md-r1-stability-matrix
  content: "CFL / neighbor-skin / size scaling for md_lennard_jones; tier-0 stability row proposal"
  status: pending
  study_only: true

- id: md-r2-neighbor-list-gap
  content: "sim-md-research: pending plan todo md-r2-neighbor-list-gap — gap orchestrator"
  status: pending
  handoff_implement: sim-p1-md-neighbor-cell

- id: md-r3-oracle-plan
  content: "sim-md-research: pending plan todo md-r3-oracle-plan — gap orchestrator"
  status: pending
  study_only: true

---

## Agent instructions

- One todo per loop iteration (`sim-algo-research-plan-loop.py`).
- Agent: `numerics_researcher` (or `autoresearch` when `novel: true` on todo).
- Gates: `SIM_RESEARCH_VERTICAL=md ./scripts/sim-algo-research-gates.sh`.
- Deliverable: `docs/numerics/studies/YYYY-MM-DD-<todo-id>.md` with grade matrix (see `sim-algo-research-grading.md`).
- Survey/stability todos: `study_only: true` — gates require study file, not full bench timing.
- Push branch `cursor/sim-md-research-loop` every iteration.
