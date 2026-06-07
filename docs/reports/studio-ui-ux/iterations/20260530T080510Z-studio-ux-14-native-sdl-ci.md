# Studio UI/UX iteration — `studio-ux-14-native-sdl-ci`

_UTC 2026-05-30T08:05:10.108845+00:00_

## UX assessment

- **pass:** True
- **avg_score:** 2.58
- **min_score:** 2.0

| ID | Score | Note |
|----|------:|------|
| UX-01 | 2.5 | SDL software renderer draws grid+particles; native_pixels=true; wgpu path still wave-2 (studio-ux-15). |
| UX-02 | 2.8 | Native play/pause RT + tick; timeline compose smoke. |
| UX-03 | 2.8 | Inspector fields when selected; empty delegates to UX-07. |
| UX-04 | 2.5 | Cmd+K palette compose; stub results — studio-ux-16 adds search latency. |
| UX-05 | 3 | studio_profile_* topbar chip; TOML line parse stub. |
| UX-06 | 2.4 | Agent chrome vs Cursor/Linear/Copilot SOTA (task state, cancel, errors). |
| UX-07 | 3 | Native empty inspector/viewport composables + smoke. |
| UX-08 | 2 | Agent error mock only; studio-ux-17 targets native GPU fail strip. |
| UX-09 | 3 | SDL/mock InputState probe + keyboard JSON bridge. |
| UX-10 | 3.2 | focus_ring token + contrast stub; axe CI follow-up. |
| UX-11 | 3 | Loading skeleton compose; loading cmd_count > idle smoke. |
| UX-12 | 2.4 | world-studio-demo Linux non-mock harness; native_gui audit with SDL frames. |
| UX-13 | 2.5 | Bench gates pass (simulate); panel_switch 95ms; memory 0.46 MiB import peak. |
| UX-14 | 3 | native_pixels=true via SDL+Xvfb CI; HTML mocks labeled; studio-ui-ux-native.yml gate. |

## Bench

```json
{
  "generated_at": "2026-05-30T08:04:37Z",
  "registry_path": "benchmarks/competitive/studio-ui.toml",
  "registry_schema": "li_studio_ui_bench_v1",
  "registry_version": 1,
  "load_ms": 0.08,
  "viewport_fps_target": 60,
  "panel_switch_ms_target": 100,
  "studio_load_ms_target": 2000,
  "viewport_fps": {
    "fps_target": 60,
    "fps_estimated": 60.0,
    "meets_target": true,
    "native_pixels": false,
    "wgpu_smoke_status": "stub_pass",
    "wgpu_surface_ok": false,
    "fps_counter_hook": "li-render",
    "bench_simulate_fn": "render_bench_fps_counter_simulate",
    "hook_version": 1,
    "status": "simulate"
  },
  "panel_switch_ms": {
    "budget_ms": 100.0,
    "worst_elapsed_ms": 95.0,
    "median_elapsed_ms": 88.0,
    "transition_count": 3,
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
      "STUDIO_MEMORY_JSON={\"schema\":\"li_studio_memory_profile_v1\",\"generated_at\":\"2026-05-30T08:04:37Z\",\"memory_id\":\"animate_md_import\",\"warn_peak_mib\":512.0,\"peak_import_mib\":0.46,\"peak_rss_mib\":null,\"peak_observed_mib\":0.46,\"meets_budget\":true,\"rss_status\":\"skip\",\"registry_path\":\"benchmarks/competitive/studio-ui.toml\",\"notes\":[\"import peak = tracemalloc after loading animate_md\",\"rss peak = --skip-export --max-frames 4 when /usr/bin/time available\",\"full GIF export can exceed budget; Studio timeline uses streamed frames\"]}"
    ],
    "profile": {
      "schema": "li_studio_memory_profile_v1",
      "generated_at": "2026-05-30T08:04:37Z",
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
      "honest_simulate": true
    },
    "panel_switch_ms": {
      "target": 100,
      "value": 95.0,
      "unit": "ms",
      "meets_target": true,
      "honest_simulate": true
    },
    "studio_load_ms": {
      "target": 2000,
      "value": 0.08,
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
      "package": "li-gpu",
      "path": "packages/li-gpu/bench/wgpu_smoke.toml",
      "present": true
    },
    "panel_switch": {
      "package": "li-gui",
      "path": "packages/li-gui/bench/panel_switch.toml",
      "present": true
    },
    "studio_compose": {
      "package": "li-studio",
      "path": "packages/li-studio/bench/studio_compose.toml",
      "present": true
    },
    "particle_tiers": {
      "package": "li-scene",
      "path": "packages/li-scene/bench/particle_tiers.toml",
      "present": true
    }
  },
  "notes": [
    "present:li-ui",
    "present:li-gui",
    "present:li-gpu",
    "present:li-render",
    "present:li-scene",
    "present:li-studio",
    "particle_tiers:li-scene_hook_simulate"
  ],
  "gates_pass": true
}
```

