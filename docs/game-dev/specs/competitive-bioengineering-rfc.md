# RFC: Competitive bioengineering module (PH-BIOENG)

**Status:** Draft  
**Track:** PH-BIOENG  
**Plan:** [competitive-bioengineering-plan.md](../competitive-bioengineering-plan.md)  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Bioengineering teams use disjoint tools: electronic lab notebooks, protein design CLIs, CFD for bioreactors, and QM packages — without a **proved**, agent-safe loop from design to publish. Drug-discovery LITL stacks (Roche-class) stop at chemistry; synthetic biology needs **build + assay + learn** on the same spine.

## Proposal

**`li-bioeng`** (`import bioeng`) extends **`li-sim-drug-design`**:

| Concern | Owner |
|---------|--------|
| LITL stage IDs | `sim.drug_design` — hypothesis, generate, DFT |
| DBTL extension | `bioeng` — build, assay, learn, scorecard |
| QM | `chem` |
| Adaptive UI | `studio` |
| Search | `ml` |
| Viz / reactor | `sim.scientific` (later) |

### Core types (BIOENG-0)

- `BioengPipeline` — iteration, stage, objective score  
- `BioengConstruct` — part count, validity flag  

### Stages

```li
def bioeng_stage_design() -> int
def bioeng_stage_build() -> int
def bioeng_stage_test() -> int
def bioeng_stage_learn() -> int
```

### Drug-design bridge

```li
def bioeng_from_drug_stage(drug_stage_id: int) -> int
  # maps lab_loop_stage_* → bioeng_stage_*
```

### Competitive scorecard (BIOENG-4)

```li
def bioeng_objective_score(p: BioengPipeline) -> float
def bioeng_scorecard_rank(score: float, baseline: float) -> int
```

## Proof policy

- Stubs use weak `ensures` (no false biological claims).  
- Production assays require CRITICAL audit + model cards (PH-COMPLY).  
- All exported `bioeng` patches go through `lic build`.

## Phases

See plan §3: BIOENG-0…7.

## Dependencies

PH-DRUG-0 (done), PH-QM-0, PH-ML-0, PH-GD-1, PH-PUB (future).

## Open questions

- SBOL / GenBank import path — trusted parsers only.  
- Multi-site collaboration — `world` snapshots + publish bundles.
