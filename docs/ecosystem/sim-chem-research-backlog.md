# Chemistry / QM algorithm research backlog

**Status:** Active  
**Vertical:** `chem`  
**Registry:** QM family ids 401–432 in `algo_registry.json`  
**Implement loop:** `sim-p2-qm-dft-scf` on `cursor/sim-algo-plan-loop`

---

todos:

- id: chem-r0-sota-survey
  content: "Gaussian/ORCA/Psi4/PySCF minimal workflows; map to QM registry 401–432"
  status: completed
  study_only: true

- id: chem-r1-basis-size-scaling
  content: "STO-3G vs larger basis — cost/accuracy table for stub SCF"
  status: completed
  study_only: true

- id: chem-r2-dft-scf-gap
  content: "Psi4 oracle harness for qm_dft_scf_energy (418) — plan docs/superpowers/plans/2026-06-05-chem-r2-r3-qm-dft-plan.md"
  status: pending
  handoff_implement: sim-p2-qm-dft-scf

- id: chem-r3-package-placement
  content: "Package placement ADR (li-chem vs li-physics-quantum) — plan docs/superpowers/plans/2026-06-05-chem-r2-r3-qm-dft-plan.md § chem-r3"
  status: pending
  study_only: true

---

## Agent instructions

- One todo per loop iteration (`sim-algo-research-plan-loop.py`).
- Agent: `numerics_researcher` (or `autoresearch` when `novel: true`).
- Gates: `SIM_RESEARCH_VERTICAL=chem ./scripts/sim-algo-research-gates.sh` (study-only default until tier-2 QM bench exists).
- Deliverable: `docs/numerics/studies/YYYY-MM-DD-<todo-id>.md`.
- Push branch `cursor/sim-chem-research-loop` every iteration.
