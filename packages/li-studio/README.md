# li-studio

Li World Studio product shell: composes **dock**, **timeline**, and **inspector** panels from `li-ui` layout IR and `li-gui` paint primitives.

Import: `import studio`

## Compose API

- `studio_compose_shell` / `studio_compose_shell_profile` — layout + `StudioProjectConfig.active_profile`
- `studio_profile_from_name` / `studio_parse_toml_profile_line` — PH-SIM profile stub (`fixtures/studio.toml`)
- `studio_paint_topbar_profile` — topbar chip; `last_rect.h` encodes active profile id
- `studio_paint_compose_panels` — paint dock slots, timeline track/playhead, inspector chrome
- `studio_shell_frame` — full editor chrome (panels + topbar + viewport grid + agent chrome)
- `studio_compose_agent_chrome` / `studio_paint_agent` — task status, step progress, context label, cancel, error strip, retry hint (UX-06)
- `studio_panel_switch_inspector` / `studio_panel_switch_timeline` — PH-UX panel switch hooks

## Agent chrome (UX-06)

| Field / API | Purpose |
|-------------|---------|
| `StudioAgentProgress` | `step_index`, `step_total`, `progress_rect`; `visible == 1` only when `task_state == running` (determinate bar, not a spinner) |
| `agent_context_label` | Context id on compose; painted as `context_rect` stroke inside status |
| `studio_agent_context_world()` | Label id `1` → display **world.li** |
| `studio_agent_context_selection()` | Label id `2` → display **selection: Node** |
| `retry_hint_rect` | Failed-state retry affordance (stroke only) |
| `studio_agent_last_action_reversible()` | Undo contract stub; returns `0` until host wires undo |

Failures use `studio_color_agent_error()` on status + error strip; running state never masks failed tasks.
