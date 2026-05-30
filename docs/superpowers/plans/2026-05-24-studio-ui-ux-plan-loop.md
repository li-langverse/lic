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
  - id: studio-ux-11-panel-switch-gate
    content: "PH-UX panel_switch_ms gate — bench hook within 100ms + gui_panel_switch_to region fix"
    status: done
  - id: studio-ux-12-world-studio-demo-linux-audit
    content: "ux-harness world-studio-demo fixture audit on Linux (non-mock) + agentic_ai SOTA refs in gates"
    status: done
  - id: studio-ux-13-proactive-sweep
    content: "Proactive ecosystem sweep — capture-deps probe, briefing snapshot refresh, wave-2 gap registry"
    status: done
  - id: studio-ux-14-native-sdl-ci
    content: "Agent runner SDL/Xvfb deps — native_pixels=true in capture + latest-native-capture.json"
    status: done
  - id: studio-ux-15-wgpu-readback
    content: "li-render wgpu real pixel draw — bench status native (not simulate) for viewport + particles"
    status: done
  - id: studio-ux-16-palette-search-latency
    content: "Command palette fuzzy search + measured open/filter latency hook (UX-04)"
    status: done
  - id: studio-ux-17-gpu-fail-recovery
    content: "Native GPU fail strip + retry affordance in li-studio shell (UX-08)"
    status: done
  - id: studio-ux-18-proactive-wave3
    content: "Proactive sweep wave-3 — keyboard journey audit + native wgpu CI matrix"
    status: done
  - id: studio-ux-19-wgpu-swapchain-readback
    content: "Real wgpu-rs swapchain texture readback in CI GPU images (blocked on runner GPU)"
    status: done
  - id: studio-ux-20-proactive-sweep-20260530
    content: "Proactive briefing refresh — capture-deps + ecosystem audit follow-ups for studio_ui_ux_builder"
    status: done
  - id: studio-ux-21-wgpu-swapchain-gpu-runner
    content: "Real wgpu-rs swapchain texture readback on org GPU runner (LIG_WGPU_SWAPCHAIN=1)"
    status: pending
  - id: studio-ux-22-palette-native-latency
    content: "Native palette open/filter latency on SDL shell — bench status native (UX-04)"
    status: done
  - id: studio-ux-23-agent-chrome-native
    content: "Wire agent chrome to native shell stream — task progress + cancel (UX-06 SOTA)"
    status: done
  - id: studio-ux-24-gpu-runner-deps
    content: "Org GPU runner matrix — Vulkan deps + wgpu swapchain CI green path"
    status: pending
isProject: false
---
- id: studio-ux-16-palette-search-latency
  content: "studio-ui-ux: pending plan todo studio-ux-16-palette-search-latency"
  status: pending
  gap_orchestrator: true
- id: studio-ux-17-gpu-fail-recovery
  content: "studio-ui-ux: pending plan todo studio-ux-17-gpu-fail-recovery"
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
