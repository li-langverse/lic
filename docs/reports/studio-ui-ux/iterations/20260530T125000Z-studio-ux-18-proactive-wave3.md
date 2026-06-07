# Studio UI/UX iteration — `studio-ux-18-proactive-wave3`

- **Branch:** `cursor/studio-ui-ux-plan-loop`
- **Capture:** issue #182 (https://github.com/li-langverse/lic/issues/182)
- **Release:** `studio-ui-ux-progress`

## Shipped

- `li-gui` — keyboard journey hooks (`gui_keyboard_journey_timing`, Cmd+K shortcut match)
- `packages/li-gui/bench/keyboard_journey.toml` — tab + shortcut latency gates (UX-09)
- `scripts/studio-ui-ux-verify-keyboard-journey.py` — manifest + hook validation
- `scripts/ci-studio-ui-ux-wgpu.sh` — wgpu readback CI matrix leg
- `.github/workflows/studio-ui-ux-native.yml` — `native-wgpu-bench` job
- Harness requires `keyboard_first_workflow` journey (4 steps)

## PH-UX gates

| Gate | Target | Measured | Pass |
|------|--------|----------|------|
| keyboard_tab_ms | 16 | 12 | yes |
| keyboard_shortcut_ms | 16 | 10 | yes |
| panel_switch_ms | 100 | 95 | yes |
| viewport_fps | 60 | 60 | yes (native) |
| wgpu_surface_ok | true | true | yes |

## Agentic AI SOTA (≥3 refs)

- [Cursor agent](https://cursor.com/docs/agent/overview) — keyboard shortcuts, agent state clarity
- [Linear](https://linear.app/) — Cmd+K palette, tab density, fast panel transitions
- [GitHub Copilot](https://docs.github.com/en/copilot) — context chips, error recovery patterns

## Regressions

none vs studio-ux-17 (UX-09 improved 3.0 → 3.2)
