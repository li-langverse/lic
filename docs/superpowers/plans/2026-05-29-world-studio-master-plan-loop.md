---
name: World Studio master plan loop
overview: Goal-directed agent executes WORLD-STUDIO-MASTER-PLAN.md until all WPs land — native Li studio, sim hooks, agent MCP, canvas, exports. No HTML product demos.
todos:
  - id: wsm-w0-docs-hub
    content: "Hub doc + native-only rule + cross-links (WORLD-STUDIO-MASTER-PLAN.md)"
    status: done
  - id: wsm-w0-gd1-shell
    content: "PH-GD-1 shell MVP — outliner, timeline, inspector, demo bin (WP-GD-01)"
    status: done
  - id: wsm-w0-sim-bridge
    content: "PH-SIM SIM-0/1/2 profile bridge + sim_step + replay metadata (WP-SIM-00..02)"
    status: done
  - id: wsm-w0-agent-registry
    content: "PH-AGENT AGENT-0 — 11 MCP tool IDs + smokes (WP-AG-01)"
    status: done
  - id: wsm-w0-profile-chips
    content: "All 7 vertical profile chips + TOML roundtrip (WP-UX-05)"
    status: done
  - id: wsm-w1-profile-smokes
    content: "Green studio_vertical_profile_roundtrip + studio_sim_step_by_profile for all 7 profiles"
    status: done
  - id: wsm-w1-sim3-envpool
    content: "SIM-3 RL EnvPool persistent + obs contract — not stack stub (WP-SIM-03, WP-RL-01)"
    status: done
  - id: wsm-w1-sim-sensors
    content: "Sensor bus stub for automotive/robotics (WP-SIM-05)"
    status: done
  - id: wsm-w1-studio-toml-engine
    content: "Parse studio.toml [engine] determinism_tier + export section (WP-SIM-06)"
    status: done
  - id: wsm-w1-timeline-playback
    content: "Timeline playhead tied to sim tick — not mock reset (WP-UX-02, WP-GD-08)"
    status: done
  - id: wsm-w1-command-palette
    content: "⌘K command palette overlay + actions (WP-UX-04)"
    status: done
  - id: wsm-w1-keyboard-bridge
    content: "SDL/mock InputState → studio_handle_studio_key end-to-end (WP-UX-09)"
    status: pending
  - id: wsm-w1-agent-chrome-fsm
    content: "Agent task FSM — running/cancel/error/retry + tool trace (WP-UX-06, WP-AG-02)"
    status: pending
  - id: wsm-w2-wgpu-viewport
    content: "li-render PBR-lite wgpu draw list — not stub_pass only (WP-GD-05)"
    status: pending
  - id: wsm-w2-viewport-hud
    content: "Live FPS + particle tier HUD in viewport (WP-UX-13)"
    status: pending
  - id: wsm-w2-viewport-error
    content: "GPU/asset error overlay + retry (WP-UX-08)"
    status: pending
  - id: wsm-w2-native-pixels
    content: "UX-14 native_pixels via wgpu readback — record verticals demo honest (WP-UX-14)"
    status: pending
  - id: wsm-w2-c-host-retire
    content: "Retire deploy/studio-demo C paint hosts after wgpu path (WP-UX-14b)"
    status: pending
  - id: wsm-w3-mcp-dispatch
    content: "studio_mcp_tool_dispatch with real args for all 11 tools (WP-AG-02)"
    status: pending
  - id: wsm-w3-mcp-server
    content: "lis mcp li-engine stdio server wiring (WP-AG-03)"
    status: pending
  - id: wsm-w3-apply-patch-loop
    content: "apply_patch → lic check JSON → retry loop (WP-AG-04, studio-cursor-sdk-rfc)"
    status: pending
  - id: wsm-w3-interaction-modes
    content: "Studio mode FSM — author/simulate/analyze/agent/publish/adaptive (WP-UX-15)"
    status: pending
  - id: wsm-w4-world-checkpoint
    content: "WorldSnapshot checkpoint after sim tick (WP-GD-02)"
    status: pending
  - id: wsm-w4-world-io
    content: "world.li text save/load roundtrip (WP-GD-03)"
    status: pending
  - id: wsm-w4-gltf-ingest
    content: "glTF ingest via li-assets into scene (WP-GD-04)"
    status: pending
  - id: wsm-w5-sci-kernels
    content: "run_algo_registry real tier-2 MD/heat kernels (WP-SCI-03)"
    status: pending
  - id: wsm-w5-sim-viz
    content: "sim.viz pipeline panels → viewport fields (WP-SCI-04)"
    status: pending
  - id: wsm-w5-robo-ik
    content: "6-DOF IK numeric stub + inspector live joints (WP-ROBO-03, WP-UX-03)"
    status: pending
  - id: wsm-w5-am-export
    content: "sim.export.print 3MF/G-code + ≤3-click flow (WP-AM-03, WP-UX-16)"
    status: pending
  - id: wsm-w5-drug-adaptive
    content: "studio.adaptive LITL stage panel sets (WP-DRUG-03)"
    status: pending
  - id: wsm-w6-publish-figures
    content: "studio.publish.figure SVG/PDF vector export (WP-PUB-01)"
    status: pending
  - id: wsm-w6-publish-data
    content: "HDF5/CSV scientific table export (WP-PUB-02)"
    status: pending
  - id: wsm-w6-repro-bundle
    content: "publish_bundle MCP → manifest zip after lic build (WP-PUB-03)"
    status: pending
  - id: wsm-w6-player-ship
    content: "li-player publish bundle from game profile (WP-GD-06)"
    status: pending
  - id: wsm-w6-agent-eval
    content: "Patch eval harness + 70% fix-rate gate (WP-AG-06)"
    status: pending
  - id: wsm-w6-vertical-dod
    content: "All 7 profile Definition-of-Done checklists green in §11 master plan"
    status: pending
isProject: false
---

# World Studio master plan loop

**Agent:** `world_studio_builder` (li-cursor-agents)  
**Branch:** `cursor/world-studio-master-plan-loop`  
**Hub:** [WORLD-STUDIO-MASTER-PLAN.md](../../game-dev/WORLD-STUDIO-MASTER-PLAN.md)  
**WP detail:** [studio-full-implementation-plan.md](../../game-dev/studio-full-implementation-plan.md)

**Not in scope:** HTML/CSS/JS as studio runtime; httpd; compiler Wave A unless todo explicitly blocks.

**Loop:** `./scripts/world-studio-plan-loop.py`  
**Gates:** `./scripts/world-studio-plan-gates.sh`  
**Continuous:** `./scripts/world-studio-plan-continuous.sh`  
**Goal sprint:** `data/goal-directed-sprints/world-studio-master-plan.md` + `goal-directed-loop.sh --until-complete`

**State:** `data/world-studio-plan-loop/state.json`  
**Reports:** `docs/reports/world-studio/iterations/`
