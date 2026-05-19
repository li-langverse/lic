# World Studio / Li Engine — progress report

**Branch:** `feat/world-studio-impl-1`  
**Sprint:** impl-19 (2026-05)  
**Tracker:** [PH-world-studio-program.md](PH-world-studio-program.md)  
**PR summary:** [PR-world-studio-impl-summary.md](PR-world-studio-impl-summary.md)

---

## Executive summary

| Metric | Value |
|--------|--------|
| **Packages** | 28 |
| **Composable gates** | **66 / 66 pass** ✅ |
| **Demo GUI** | [deploy/studio-demo/](../../deploy/studio-demo/) (HTML showcase) |
| **Sprints** | impl-1 → **impl-19** |
| **Blocked** | `sim_step_physics` |
| **Merge** | ⬜ open PR → `main` |

---

## Sprint impl-19

| Deliverable | Track | State |
|-------------|-------|--------|
| `import_scientific_drug_chem` | PH-SCI / DRUG / QM | ✅ |
| `import_sim_relativity_rocket` | Rocket / relativity | ✅ |
| `import_pub_bioeng_leaderboard` | PH-PUB / BIOENG | ✅ |
| **Studio demo GUI** | showcase | ✅ HTML + record script |
| [demo-showcase.md](demo-showcase.md) | docs | ✅ |

---

## Demo videos

| Asset | How |
|-------|-----|
| **Interactive** | `deploy/studio-demo/index.html` — rocket, racing, robot, drug, bioeng, MMO |
| **Reel (WebM)** | `./scripts/record-studio-demo.sh` → `deploy/studio-demo/videos/` |

Native Li Studio binary GUI is **not** yet shipped; the showcase is the visual prototype until `li-render` wires to the shell.

---

## Program progress

| Program | ~% | Change (impl-19) |
|---------|-----|------------------|
| **PH-DRUG** | **52%** | sci+drug+chem stack |
| **PH-QM** | **22%** | TDDFT LITL |
| **PH-GD** | **72%** | demo showcase GUI |
| **PH-PUB** | **30%** | pub+bioeng bundle |

---

## Composable timeline

| Sprint | Gates |
|--------|-------|
| impl-18 | 63 |
| **impl-19** | **66** |

---

## Verify

```bash
./li-tests/run_all.sh composable
python3 -m http.server 8765 --directory deploy/studio-demo
```

---

## Next (impl-20)

1. Merge PR → `main`  
2. Native viewport hook (`li-render` → studio shell)  
3. Per-vertical demo `.li` mains (rocket, race, robot)  
4. `sim_step_physics` when types land  

---

*impl-19 · `feat/world-studio-impl-1`*
