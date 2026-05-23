# PH-world-studio-program — master tracker

**Status:** Planning  
**Vision:** [world-studio-vision.md](world-studio-vision.md)

Cross-cutting program IDs. Implementation order respects dependencies in the vision doc.

| Program | Phases | Depends on |
|---------|--------|------------|
| **PH-GD** | GD-0…7 | `li-scene`, `li-ui` |
| **PH-UX** | UX-0…5 | PH-GD-1 |
| **PH-SIM** | SIM-0…6 | `li-physics-runtime` |
| **PH-ROBO** | ROBO-0…5 | PH-SIM-1 |
| **PH-AM** | AM-0…9 | PH-SCI-2, PH-UX-3 |
| **PH-SCI** | SCI-0…7 | tier-2 physics |
| **PH-CAE** | CAE-0…5 | PH-SCI-2; [engineering-cae-fundamentals.md](../ecosystem/engineering-cae-fundamentals.md) |
| **PH-CIN** | CIN-0…5 | PH-GD-1, `seq`, `anim`; [cinematic-algorithm-fundamentals.md](../ecosystem/cinematic-algorithm-fundamentals.md) |
| **PH-DRUG** | DRUG-0…7 | PH-SCI-2, PH-GD-1, PH-AGENT |
| **PH-QM** | QM-0…7 | PH-HW, PH-COMPLY |
| **PH-VOXEL** | VOXEL-0…5 | PH-GD-5 |
| **PH-GEO** | GEO-0…5 | `math`, PH-GD-1; [cad-fundamentals.md](../ecosystem/cad-fundamentals.md) |
| **PH-PUB** | PUB-0…5 | PH-UX, `sim.viz` |
| **PH-ML** | ML-0…5 | PH-HW-1 |
| **PH-AGENT** | AGENT-0…6 | `lic check --format=json` |
| **PH-PORT** | PORT-0…2 | LLVM triples |
| **PH-HW** | HW-0…4 | `li-gpu` |
| **PH-COMPLY** | COMPLY-0…4 | governance |

**Next execution milestones:** RFC stubs (landed) → `li-studio` scaffold (PH-GD-1) → `li-sim` step API (PH-SIM-1).
