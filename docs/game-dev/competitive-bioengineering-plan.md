# Competitive bioengineering module — program plan (PH-BIOENG)

**Status:** Planning → implementation (impl-5)  
**Builds on:** [PH-DRUG](specs/drug-design-lab-loop-rfc.md) · `li-sim-drug-design` · `li-chem` · `studio.adaptive`  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**RFC:** [competitive-bioengineering-rfc.md](specs/competitive-bioengineering-rfc.md)

---

## 1. Strategic goal

Deliver a **competitive bioengineering vertical** inside Li World Studio / Li Engine — not a separate fork — that beats incumbents on:

| Dimension | Incumbent gap | Li beat condition |
|-----------|---------------|-------------------|
| **Closed loops** | Benchling / LIMS silos | Same **Lab-in-the-Loop** spine as PH-DRUG + `lic build` on every patch |
| **QM + ML** | BioNeMo / Schrödinger lock-in | `li-chem` + `li-ml` async pools on **one** engine |
| **Design–build–test** | Rosetta, ProteinMPNN as CLI islands | `bioeng` pipeline stages in Studio with adaptive panels |
| **Bioprocess** | COMSOL / Aspen one-way export | `sim.scientific` + `bioeng.reactor` stubs → tier-2 physics |
| **Repro & publish** | Ad-hoc figures | PH-PUB bundles tied to pipeline hash |
| **Agents** | Copilot without proof | MCP `li-engine` + mandatory `lic check` on constructs |

**Positioning:** *Drug design is the wedge; bioengineering is the platform* — synthetic biology, protein engineering, metabolic engineering, and bioprocess scale-up share the same loop.

---

## 2. Architecture (layers)

```text
┌─────────────────────────────────────────────────────────────────┐
│  World Studio — bioeng.adaptive panels, DBTL wizard, leaderboards│
├─────────────────────────────────────────────────────────────────┤
│  li-bioeng (import bioeng) — constructs, assays, objectives      │
│    └─ extends li-sim-drug-design lab_loop stages (DRUG → BIOENG) │
├─────────────────────────────────────────────────────────────────┤
│  li-chem (QM) · li-ml (surrogates) · li-voxel (fields)          │
│  li-sim-scientific (CFD/reactor) · physics.custom (toy kinetics) │
└─────────────────────────────────────────────────────────────────┘
```

### Import map

| Import | Package | Role |
|--------|---------|------|
| `sim.drug_design` | `li-sim-drug-design` | Base LITL stages (hypothesis → DFT) |
| `bioeng` | `li-bioeng` | Construct → express → assay → optimize |
| `chem` | `li-chem` | Binding, mechanism, TDDFT |
| `studio` | `li-studio` | `studio_adaptive_panel_for_stage` |
| `ml` | `li-ml` | Multi-objective search, env pools |

---

## 3. Program phases (PH-BIOENG)

| Phase | ID | Deliverable | Depends |
|-------|-----|-------------|---------|
| 0 | BIOENG-0 | This plan + RFC + `li-bioeng` stubs | PH-DRUG-0 |
| 1 | BIOENG-1 | **DBTL loop** API (`bioeng_dbtl_*`) wired to `lab_loop_*` | DRUG-0 |
| 2 | BIOENG-2 | Construct registry (parts, plasmids, strains) text stubs | BIOENG-1 |
| 3 | BIOENG-3 | Assay ingest + objective vector (fitness, titer, burden) | BIOENG-2, PH-ML |
| 4 | BIOENG-4 | **Competitive scorecard** — benchmark table vs registry | PH-PUB |
| 5 | BIOENG-5 | Bioreactor hook → `sim.scientific` + `heat_equation` tier-2 | PH-SCI-1 |
| 6 | BIOENG-6 | Regulatory export (audit trail, model cards) | PH-COMPLY |
| 7 | BIOENG-7 | GPU surrogates + `li-gpu` batch scoring | PH-HW, PH-ML |

---

## 4. DBTL loop (extends drug LITL)

| Stage | DRUG analog | `bioeng` API (stub → real) |
|-------|-------------|----------------------------|
| **Design** | hypothesis + generate | `bioeng_stage_design()` |
| **Build** | — | `bioeng_stage_build()` — construct assembly |
| **Test** | DFT + assay proxy | `bioeng_stage_test()` — calls `chem` / assay stub |
| **Learn** | retrain | `bioeng_stage_learn()` — `ml.job_graph` hook |

```li
import bioeng
import sim.drug_design

def run_dbtl_iteration(iter: int) -> int
  requires iter >= 0
  ensures result >= 0
  decreases iter
=
  var drug_stage = lab_loop_stage_new(lab_loop_stage_hypothesis())
  lab_loop_advance_stub(drug_stage)
  var bio = bioeng_dbtl_new(iter)
  bioeng_dbtl_advance(bio)
  return bioeng_objective_score(bio)
```

---

## 5. Competitive benchmarks (BIOENG-4)

New registry slice: `benchmarks/competitive/bioengineering.toml` (planned) — track:

- **Protein design:** RFdiffusion-class, ProteinMPNN-class (task definitions only in v1)
- **Docking / affinity:** GNINA, DiffDock-class
- **Bioprocess:** ideal CSTR yield vs Li reactor stub
- **LITL throughput:** iterations/hour with `lic check` in loop

**Li wins when:** same repo runs game + bio + QM with one `lic build` and published repro bundle (PH-PUB).

---

## 6. Studio UX (PH-UX + PH-DRUG)

| Surface | Behavior |
|---------|----------|
| **Bioeng dashboard** | Stage rail: Design \| Build \| Test \| Learn |
| **Leaderboard panel** | `bioeng_scorecard_row` — multi-objective Pareto stub |
| **Construct editor** | Parts list → `bioeng_construct_valid` |
| **Export** | `studio.publish.bundle` + compliance hash |

Reuse `studio_adaptive_panel_for_stage` — map `bioeng_stage_*` → panel layouts.

---

## 7. Compliance & tiers

| Package | Tier | Notes |
|---------|------|-------|
| `li-bioeng` | IMPORTANT | Audit on export constructs to lab |
| `li-chem` | CRITICAL | QM in Test stage |
| `li-sim-drug-design` | CRITICAL | Shared LITL spine |

---

## 8. Implementation order (next sprints)

1. ✅ **BIOENG-0** — `li-bioeng`, plan, RFC, composable gate, extend `sim_profile_*`  
2. **BIOENG-1** — `bioeng_dbtl_*` calls into `lab_loop_*` from composable test  
3. **BIOENG-2** — construct types + validation  
4. **BIOENG-3** — link `ml.env_pool_step_stub` in learn stage  
5. **BIOENG-4** — `benchmarks/competitive/bioengineering.toml` + docs row in landscape  

---

## 9. Open questions

- [ ] Separate `bioeng.drug` import vs single `bioeng` package? **v1: single `bioeng`**.  
- [ ] ROS/LIMS FFI boundary — trusted channel only (PH-COMPLY).  
- [ ] SynBio DSL in Li vs external SBOL — start with text stubs in `li-world`.

---

## 10. Links

- [drug-design-lab-loop-rfc.md](specs/drug-design-lab-loop-rfc.md)  
- [li-chem-qm-rfc.md](specs/li-chem-qm-rfc.md)  
- [competitive-landscape.md](competitive-landscape.md)  
- [PH-world-studio-program.md](PH-world-studio-program.md)
