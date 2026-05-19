# Li World Studio — demo showcase

**Status:** Interactive prototype GUI + optional headless video capture  
**Branch:** `feat/world-studio-impl-1`

---

## What this is

The **killer GUI** is not yet the native Li Studio binary — it is an **HTML5 showcase** that mirrors the studio shell (outliner, viewport, adaptive panels) and animates each competitive vertical:

| Tab | Vertical | Engine packages |
|-----|----------|-----------------|
| Rocket | Custom / unphysical + relativity | `physics.custom`, `physics.relativity`, `sim` |
| Racing | Automotive | `sim.automotive`, `sim` |
| Robot | Robotics | `sim.robotics` |
| Drug LITL | Drug design | `sim.drug_design`, `chem`, `studio` |
| Bioeng | DBTL + bioreactor | `bioeng`, `sim.scientific` |
| MMO | Realms / shards | `mmo`, `store.realtime`, `world` |

Visuals are **illustrative**; simulation truth is in **63+ composable `lic check` gates**.

---

## Run interactively

```bash
cd lic
# Python or any static server:
python3 -m http.server 8765 --directory deploy/studio-demo
# Open http://localhost:8765
```

Or open `deploy/studio-demo/index.html` directly in a browser.

Click **Demo reel** to auto-cycle all verticals every 8 seconds.

---

## Record demo video

```bash
./scripts/record-studio-demo.sh
# Output: deploy/studio-demo/videos/world-studio-demo-reel.webm
```

Requires `google-chrome` (or set `CHROME=`) and `ffmpeg`. Adjust length: `DURATION=60 ./scripts/record-studio-demo.sh`.

For production marketing, re-record with OBS at 1080p while driving the interactive demo — higher quality than headless screenshots.

---

## Li vertical demo mains

| Vertical | Package main |
|----------|----------------|
| Rocket | `packages/li-physics-custom/src/demo_rocket_main.li` |
| Racing | `packages/li-sim-automotive/src/demo_racing_main.li` |
| Robot | `packages/li-sim-robotics/src/demo_robot_main.li` |
| Drug | `packages/li-sim-drug-design/src/demo_drug_main.li` |

```bash
./build/compiler/lic/lic check packages/li-physics-custom/src/demo_rocket_main.li
```

---

## Roadmap to native Studio

1. Wire `li-studio` viewport to real `li-render` / `li-scene` (not canvas stub).  
2. Embed same vertical presets in `studio.toml` spin-up templates.  
3. Replace HTML demo with Electron or in-engine shell when `lic build` ships game targets.

---

*See [PH-world-studio-progress-report.md](PH-world-studio-progress-report.md) for sprint metrics.*
