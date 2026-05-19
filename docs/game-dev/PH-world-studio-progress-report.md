# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-20 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**PR summary:** [PR-world-studio-impl-summary.md](PR-world-studio-impl-summary.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Packages** | 28 |
| **Composable gates** | **68 / 68 pass** ✅ |
| **Game dev smokes** | **10 parse_ok** |
| **Demo GUI** | [deploy/studio-demo/](../../deploy/studio-demo/) |
| **Vertical `.li` demos** | rocket, racing, robot, drug |
| **Sprints** | impl-1 → **impl-20** |
| **Blocked** | `sim_step_physics` |
| **Merge** | ⬜ open PR → `main` |

---

## Sprint impl-20

| Deliverable | Track | State |
|-------------|-------|--------|
| `studio_viewport_bind_render_stub` + render bridge | PH-GD-5 | ✅ |
| `import_studio_render_viewport` composable | PH-GD | ✅ |
| `demo_*_main.li` per vertical | demos | ✅ |
| `import_demo_verticals` composable | gates | ✅ |
| game_dev `demo_*.li` parse gates | tests | ✅ |

---

## Sprint impl-19 (shipped)

| Deliverable | Track | State |
|-------------|-------|--------|
| HTML studio showcase + WebM reel | demo | ✅ |
| sci+drug+chem · relativity · pub composables | gates | ✅ |

---

## Vertical demo entrypoints

| Demo | File |
|------|------|
| Rocket | `packages/li-physics-custom/src/demo_rocket_main.li` |
| Racing | `packages/li-sim-automotive/src/demo_racing_main.li` |
| Robot | `packages/li-sim-robotics/src/demo_robot_main.li` |
| Drug LITL | `packages/li-sim-drug-design/src/demo_drug_main.li` |

Interactive visuals: [demo-showcase.md](demo-showcase.md)

---

## Composable timeline

| Sprint | Gates |
|--------|-------|
| impl-19 | 66 |
| **impl-20** | **68** |

---

## Verify

```bash
./li-tests/run_all.sh composable
./li-tests/run_all.sh game_dev
```

---

## Next (impl-21)

1. Merge PR → `main`  
2. `lic build` vertical demos when package mains stable  
3. Wire studio-demo HTML to live composable status JSON  
4. `sim_step_physics` when cross-package types land  

---

*impl-20 · `feat/world-studio-impl-1`*
