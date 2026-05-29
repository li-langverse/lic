---
name: Studio UI/UX plan loop
overview: Goal-directed agent implements native Li Studio UI (ui/gui/render) and assesses UX + perf every iteration via capture/bench. Progress on GitHub issues/releases only — no large assets in repo.
todos:
  - id: studio-ux-00-design-system
    content: "Design system — studio-ui-ux-generate-design-system.sh + tokens + demo HTML refresh"
    status: done
  - id: studio-ux-01-ui-composables
    content: "li-ui — layout + paint IR composables; li-tests compile_ok for studio shell"
    status: done
  - id: studio-ux-02-gui-viewport-stub
    content: "li-gui — viewport region + panel switch timing hooks (<100ms target)"
    status: done
  - id: studio-ux-03-render-wgpu-smoke
    content: "li-render/gpu — wgpu smoke + FPS counter hook for bench harness"
    status: done
  - id: studio-ux-04-particle-display
    content: "Scene path — MD particle draw tiers (1k/10k/100k) with honest FPS reporting"
    status: done
  - id: studio-ux-05-studio-compose
    content: "li-studio — compose dock + timeline + inspector from composables"
    status: done
  - id: studio-ux-06-agent-chrome
    content: "Agentic chrome — task status, cancel, error strip (PH UX-06)"
    status: done
  - id: studio-ux-07-capture-harness
    content: "Wire studio-ui-ux-capture-progress.sh + demo HTML mocks; verify gh upload path"
    status: done
  - id: studio-ux-08-bench-registry
    content: "benchmarks/competitive/studio-ui.toml + bench-studio-viewport-perf.json output"
    status: done
  - id: studio-ux-09-memory-budget
    content: "profile-animate-memory in loop gates; document peak MiB budget in ui-ux-by-dimension"
    status: done
  - id: studio-ux-10-native-capture
    content: "Extend ux-harness native_gui for Xvfb SDL capture when viewport draws pixels"
    status: done
isProject: false
---
- id: gap-ux-gap-ux-agents-dashboard
  content: "UI/UX (agents-dashboard): GUI not reachable at http://127.0.0.1:3000 (start dashboard for extended audit)"
  status: pending
  gap_orchestrator: true
- id: gap-ux-gap-ux-lic-tetris
  content: "UI/UX (lic-tetris): native capture script not configured (paths.capture_script or lic_root)"
  status: pending
  gap_orchestrator: true
- id: gap-ux-gap-ux-world-studio-native
  content: "UI/UX (world-studio-native): native capture script not configured (paths.capture_script or lic_root)"
  status: pending
  gap_orchestrator: true
- id: gap-ux-gap-ux-benchmarks-dashboard-gpu-matrix
  content: "UI/UX (benchmarks-dashboard-gpu-matrix): gpu-chip-picker uses role=tab/tablist without tabpanel or roving tabindex"
  status: pending
  gap_orchestrator: true





# Studio UI/UX autonomous loop

**Agent:** `studio_ui_ux_builder` (li-cursor-agents)  
**Branch:** `cursor/studio-ui-ux-plan-loop`  
**Not in scope:** httpd, tier5 HTTP, compiler Wave A (separate loops).

**UX rubric:** [ui-ux-by-dimension.md](../../game-dev/competitive-intel/ui-ux-by-dimension.md)

**Loop:** `./scripts/studio-ui-ux-plan-loop.py`  
**Gates:** `./scripts/studio-ui-ux-plan-gates.sh`  
**Capture (no git binaries):** `./scripts/studio-ui-ux-capture-progress.sh`

**Progress tracking:** GitHub issue `STUDIO_UI_UX_TRACKING_ISSUE` + release tag `studio-ui-ux-progress`.
