# PH-world-studio-program — master tracker

**Status:** In progress (impl-13 on `feat/world-studio-impl-1`) — **ready for draft PR**  
**Vision:** [world-studio-vision.md](world-studio-vision.md)  
**Progress report:** [PH-world-studio-progress-report.md](PH-world-studio-progress-report.md) ← **read this for sprint status**

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
| **PH-MMO** | MMO-0…7 | PH-GD-2, PH-SIM-1, `li-net` |
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
| **PH-MMO** plan + `li-mmo` + `store.realtime` | Done (MMO-0) |
| `deploy/mmo/` realm.toml + compose | Done (MMO-3) |
| `sim_profile_mmo` + stack composable | Done (MMO-1) |
| Matchmaking stubs + shard/gateway mains | Done (MMO-2/3) |
| `world_snapshot_for_realm` | Done (MMO-6 partial) |
| `studio_mmo_deploy_status_stub` | Done |
| MMO-4 Redis trusted extern + `store_redis_smoke` | Done (stub) |
| `li-studio-ai`, `li-player` packages | Done (GD-3/7 stub) |
| BIOENG-1 pipeline smoke | Done |
| MMO-7 anticheat tick stub (partial) | Done |
| `benchmarks/competitive/mmorpg.toml` | Done |
| **37 composable** import gates | Done |
| render + scene + studio stack composable | Done |
| BIOENG-3 assay batch types | Done |
| `lic-diagnose-agent-bridge` doc | Done |
| `scripts/deploy-mmo-dev.sh` | Done |
| **41 composable** gates | Done |
| MMO-4 Postgres `open_postgres` | Done |
| BIOENG-4 scorecard row | Done |
| player + render client loop | Done |
| [PR-world-studio-impl-summary.md](PR-world-studio-impl-summary.md) | Done |
| **`li-assets`** glTF stub (PH-GD-4) | Done |
| BIOENG-5 bioreactor → `sim.scientific` | Done |
| MMO shard tick + `sim_mmo_profile_step_smoke` | Done |
| **44 composable** gates | Done |
| MMO-5 `WsSession` + `MmoWsBinding` session bind | Done |
| BIOENG-6 `RegulatoryExport` stub | Done |
| `studio_gen_asset_hook_stub` + assets composable | Done |
| **47 composable** gates | Done |
| MMO-5 WebSocket stubs (`net.httpd`) | Done |
| MMO-6 `world_checkpoint_mmo_stub` | Done |
| BIOENG-2 construct registry | Done |
| `li-render` (PH-GD-5 stub) | Done |
| `studio_ai_diagnose_gate` (GD-3) | Done |
