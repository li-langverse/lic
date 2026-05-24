# Studio UI/UX — competitive dimensions (PH-UX)

**Audience:** `studio_ui_ux_builder` plan loop · **not** httpd.

## Performance gates (PH-UX)

| Gate | Target | Measure |
|------|--------|---------|
| Viewport FPS | ≥ 60 sustained | `bench-studio-viewport-perf.sh` / future native HUD |
| Panel switch | &lt; 100 ms | Instrumented composable or mock timing |
| Studio cold load | &lt; 2 s to interactive shell | `load_ms` in bench JSON |
| MD particles (display) | 10k @ 60 fps; 100k @ 30 fps (tiered) | `md_lennard_jones` + scene path |
| Memory (animate MD) | Document peak MiB; no unbounded growth | `profile-animate-memory.sh` |

## UX dimensions (score 0–3 each iteration)

| ID | Dimension | SOTA refs |
|----|-----------|-----------|
| UX-01 | Viewport clarity (grid, selection, depth cues) | Godot, Blender |
| UX-02 | Timeline / playback affordances | DaVinci, Unreal Sequencer |
| UX-03 | Inspector density vs readability | Unity, Figma |
| UX-04 | Command palette (discoverability, latency) | Linear, VS Code |
| UX-05 | Vertical profiles (chem/bio/game) switching | Notion databases |
| UX-06 | Agentic AI: task status & cancel | Cursor, Copilot |
| UX-07 | Empty states (no scene / no selection) | shadcn patterns |
| UX-08 | Error recovery (GPU fail, missing asset) | Primer |
| UX-09 | Keyboard-first workflows | Blender, Linear |
| UX-10 | Accessibility (contrast, focus) | axe / WCAG AA |
| UX-11 | Loading / skeleton states | Material 3 |
| UX-12 | Copy & terminology consistency | Diátaxis docs tone |
| UX-13 | Performance honesty (show FPS / particle count) | Game engines |
| UX-14 | Marketing vs product truth | No HTML mock passed as native |

**Competitors (design):** Blender, Unreal Editor, Unity, Houdini (viewport); **agentic:** Cursor, Linear, GitHub Copilot Workspace.

**Evidence:** screenshots + short reel per iteration on GitHub (release `studio-ui-ux-progress`), not in git tree.
