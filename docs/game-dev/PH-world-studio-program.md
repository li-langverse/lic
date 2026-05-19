# PH-world-studio-program — master tracker

**Status:** In progress (impl-5 on `feat/world-studio-impl-1`)  
**Vision:** [world-studio-vision.md](world-studio-vision.md)

Cross-cutting program IDs. Implementation order respects dependencies in the vision doc.

| Program | Phases | Depends on |
|---------|--------|------------|
| **PH-GD** | GD-0…7 | `li-scene`, `li-ui` |
| **PH-UX** | UX-0…5 | PH-GD-1 |
| **PH-SIM** | SIM-0…6 | `li-physics-runtime` |
| **PH-PHYS-CUSTOM** | CUSTOM-0…3 | PH-SIM-1 |
| **PH-ROBO** | ROBO-0…5 | PH-SIM-1 |
| **PH-AM** | AM-0…9 | PH-SCI-2, PH-UX-3 |
| **PH-SCI** | SCI-0…7 | tier-2 physics |
| **PH-DRUG** | DRUG-0…7 | PH-SCI-2, PH-GD-1, PH-AGENT |
| **PH-BIOENG** | BIOENG-0…7 | PH-DRUG-0, PH-ML-0, PH-QM-0 |
| **PH-QM** | QM-0…7 | PH-HW, PH-COMPLY |
| **PH-VOXEL** | VOXEL-0…5 | PH-GD-5 |
| **PH-PUB** | PUB-0…5 | PH-UX, `sim.viz` |
| **PH-ML** | ML-0…5 | PH-HW-1 |
| **PH-AGENT** | AGENT-0…6 | `lic check --format=json` |
| **PH-PORT** | PORT-0…2 | LLVM triples |
| **PH-HW** | HW-0…4 | `li-gpu` |
| **PH-COMPLY** | COMPLY-0…4 | governance |

**Next execution milestones:** RFC stubs (landed) → package scaffolds (PH-GD-1 / PH-SIM-1) → composable import gates → `sim_step_physics` when compiler merges imported types.

| Milestone | State |
|-----------|--------|
| RFC stubs + vision on `main` | Done (#59) |
| `li-sim`, `li-studio`, `li-chem`, `li-voxel` packages | Done (PR #60 branch) |
| `li-tests/composable/import_sim` / `import_studio` | Done |
| `targets/manifest.toml` (PH-PORT-0) | Done |
| `sim_step` → `physics.runtime` | Blocked — imported types in fields/locals |
| `li-world` save/load stubs (PH-GD-2) | Done |
| `li-sim-additive` export stubs (PH-AM-0) | Done |
| SIM-2 replay buffer in `li-sim` | Done |
| Studio viewport/outliner hooks | Done |
| MCP `li-engine` server | Docs: [agent-mcp-sketch.md](agent-mcp-sketch.md) |
| `sim.scientific` / `sim.robotics` / `sim.automotive` / `sim.drug_design` | Done |
| `li-ml`, `li-gpu` stubs | Done |
| `studio_adaptive_*`, `studio_publish_*` in `li-studio` | Done |
| `chem` DFT/TDDFT tagged stubs | Done |
| **Arbitrary / unphysical physics** (`li-physics-custom`) | Done (CUSTOM-0) |
| `sim` law_mode + `sim_step_arbitrary` | Done |
| **PH-BIOENG** plan + `li-bioeng` + drug bridge | Done (BIOENG-0) |
| `benchmarks/competitive/bioengineering.toml` | Done (stub) |
