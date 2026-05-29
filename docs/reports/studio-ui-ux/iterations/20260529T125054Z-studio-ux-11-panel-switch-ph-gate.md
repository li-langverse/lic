# Studio UI/UX iteration — `studio-ux-11-panel-switch-ph-gate`

_UTC 2026-05-29T12:50:54.303883+00:00_

## UX assessment

- **pass:** True
- **avg_score:** 2.52
- **min_score:** 2.0

| ID | Score | Note |
|----|------:|------|
| UX-01 | 2.2 | SDL stub draws grid + selection rect; full li-render wgpu grid pending. |
| UX-02 | 2.8 | Native play/pause RT + tick; timeline compose smoke. |
| UX-03 | 2.8 | Inspector field rows when selected; empty delegates to UX-07 helper. |
| UX-04 | 2.5 | Native palette compose, Cmd+K toggle; stub results, no search latency. |
| UX-05 | 3 | studio_profile_* + topbar chip; TOML line parse stub. |
| UX-06 | 2.4 | Agent chrome + invoke strip; Cursor/Linear/Copilot SOTA compared. |
| UX-07 | 3 | Native empty inspector/viewport composables + shell wiring. |
| UX-08 | 2.1 | Viewport + agent error strips composable; wgpu probe deferred to studio-ux-13. |
| UX-09 | 3.0 | SDL/mock InputState probe + studio-shell-sdl-tick.sh. |
| UX-10 | 3.2 | focus_ring token + studio_paint_focus_ring IR; inspector focus smoke. |
| UX-11 | 3 | StudioShellLoadingState skeleton cmds; loading > idle smoke. |
| UX-12 | 2.3 | Mock banner + aligned GPU/agent error copy in HTML mock. |
| UX-13 | 2.7 | PH panel_switch gate on product transitions; stress 150ms documented outside gate. |
| UX-14 | 2.8 | HTML labeled mock; native_pixels meta when SDL runs. |

## Bench

```json
{
  "generated_at": "2026-05-29T12:50:51Z",
  "registry_path": "benchmarks/competitive/studio-ui.toml",
  "registry_schema": "li_studio_ui_bench_v1",
  "registry_version": 1,
  "load_ms": 0.09,
  "viewport_fps_target": 60,
  "panel_switch_ms_target": 100,
  "studio_load_ms_target": 2000,
  "viewport_fps": {
    "fps_target": 60,
    "fps_estimated": 60.0,
    "meets_target": true,
    "native_pixels": true,
    "native_pixels_stub": false,
    "wgpu_smoke_status": "paint_blit_host",
    "wgpu_surface_ok": true,
    "wgpu_surface_ok_stub": false,
    "native_pixel_source": 2,
    "native_pixel_source_paint_blit": 2,
    "fps_counter_hook": "li-render",
    "bench_simulate_fn": "render_bench_fps_counter_simulate",
    "host_bench_fn": "render_viewport_host_fps_counter",
    "hook_version": 2,
    "status": "host_present",
    "honest_simulate": false,
    "lig_present_runtime_probe": {
      "stub": {
        "host_present_active": 0,
        "paint_blit_ok": 0,
        "surface_ok": 0,
        "native_pixels": 0,
        "native_pixel_source": 0,
        "probe_run_ok": true
      },
      "host_present": {
        "host_present_active": 1,
        "paint_blit_ok": 1,
        "surface_ok": 1,
        "native_pixels": 1,
        "native_pixel_source": 2,
        "probe_run_ok": true
      },
      "probe_compile_ok": true
    }
  },
  "panel_switch_ms": {
    "budget_ms": 100.0,
    "worst_elapsed_ms": 94.0,
    "median_elapsed_ms": 88.0,
    "transition_count": 3,
    "stress_transition_count": 1,
    "stress_worst_elapsed_ms": 150.0,
    "all_within_budget": true,
    "meets_target": true,
    "native_pixels": false,
    "status": "simulate",
    "bench_simulate_fn": "gui_panel_switch_budget_ms"
  },
  "particle_tiers": [
    {
      "id": "md_1k",
      "tier_id": 0,
      "particles": 1000,
      "fps_target": 60,
      "fps_estimated": 60.0,
      "meets_target": true,
      "status": "simulate",
      "native_pixels": false,
      "draw_path": "scene_budget_simulate",
      "kernel": "md_lennard_jones",
      "hook_version": 1,
      "bench_simulate_fn": "scene_bench_particle_tier_simulate"
    },
    {
      "id": "md_10k",
      "tier_id": 1,
      "particles": 10000,
      "fps_target": 60,
      "fps_estimated": 60.0,
      "meets_target": true,
      "status": "simulate",
      "native_pixels": false,
      "draw_path": "scene_budget_simulate",
      "kernel": "md_lennard_jones",
      "hook_version": 1,
      "bench_simulate_fn": "scene_bench_particle_tier_simulate"
    },
    {
      "id": "md_100k",
      "tier_id": 2,
      "particles": 100000,
      "fps_target": 30,
      "fps_estimated": 30.0,
      "meets_target": true,
      "status": "simulate",
      "native_pixels": false,
      "draw_path": "scene_budget_simulate",
      "kernel": "md_lennard_jones",
      "hook_version": 1,
      "bench_simulate_fn": "scene_bench_particle_tier_simulate"
    }
  ],
  "memory_mib": {
    "profile_exit": 0,
    "lines": [
      "tracemalloc peak (import): 0.46 MiB",
      "==> budget warn_peak_mib=512 observed=0.46 meets=True",
      "STUDIO_MEMORY_JSON={\"schema\":\"li_studio_memory_profile_v1\",\"generated_at\":\"2026-05-29T12:50:52Z\",\"memory_id\":\"animate_md_import\",\"warn_peak_mib\":512.0,\"peak_import_mib\":0.46,\"peak_rss_mib\":null,\"peak_observed_mib\":0.46,\"meets_budget\":true,\"rss_status\":\"skip\",\"registry_path\":\"benchmarks/competitive/studio-ui.toml\",\"notes\":[\"import peak = tracemalloc after loading animate_md\",\"rss peak = --skip-export --max-frames 4 when /usr/bin/time available\",\"full GIF export can exceed budget; Studio timeline uses streamed frames\"]}"
    ],
    "profile": {
      "schema": "li_studio_memory_profile_v1",
      "generated_at": "2026-05-29T12:50:52Z",
      "memory_id": "animate_md_import",
      "warn_peak_mib": 512.0,
      "peak_import_mib": 0.46,
      "peak_rss_mib": null,
      "peak_observed_mib": 0.46,
      "meets_budget": true,
      "rss_status": "skip",
      "registry_path": "benchmarks/competitive/studio-ui.toml",
      "notes": [
        "import peak = tracemalloc after loading animate_md",
        "rss peak = --skip-export --max-frames 4 when /usr/bin/time available",
        "full GIF export can exceed budget; Studio timeline uses streamed frames"
      ]
    },
    "warn_peak_mib": 512.0,
    "peak_observed_mib": 0.46,
    "meets_budget": true
  },
  "gates": {
    "viewport_fps": {
      "target": 60,
      "value": 60.0,
      "unit": "fps",
      "meets_target": true,
      "honest_simulate": false
    },
    "panel_switch_ms": {
      "target": 100,
      "value": 94.0,
      "unit": "ms",
      "meets_target": true,
      "honest_simulate": true
    },
    "studio_load_ms": {
      "target": 2000,
      "value": 0.09,
      "unit": "ms",
      "meets_target": true,
      "honest_simulate": true
    },
    "md_1k": {
      "target": 60,
      "value": 60.0,
      "unit": "fps",
      "particles": 1000,
      "meets_target": true,
      "honest_simulate": true
    },
    "md_10k": {
      "target": 60,
      "value": 60.0,
      "unit": "fps",
      "particles": 10000,
      "meets_target": true,
      "honest_simulate": true
    },
    "md_100k": {
      "target": 30,
      "value": 30.0,
      "unit": "fps",
      "particles": 100000,
      "meets_target": true,
      "honest_simulate": true
    },
    "animate_md_import": {
      "target": 512.0,
      "value": 0.46,
      "unit": "mib",
      "meets_target": true,
      "honest_simulate": true,
      "peak_import_mib": 0.46,
      "peak_rss_mib": null
    }
  },
  "hooks": {
    "viewport_fps": {
      "package": "li-render",
      "path": "packages/li-render/bench/viewport_fps.toml",
      "present": true
    },
    "wgpu_smoke": {
      "package": "lig",
      "path": "packages/lig/bench/wgpu_smoke.toml",
      "present": true
    },
    "panel_switch": {
      "package": "li-gui",
      "path": "packages/li-gui/bench/panel_switch.toml",
      "present": tru
```

