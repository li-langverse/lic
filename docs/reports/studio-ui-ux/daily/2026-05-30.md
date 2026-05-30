# Studio UI/UX — daily report 2026-05-30

_Generated 2026-05-30T04:33:42.823415+00:00 (Europe/Berlin)_

## Summary

| Metric | Value |
|--------|-------|
| Plan todos (state) | **14** completed ids |
| Iterations run | **12** |
| UX gate pass | **True** |
| UX avg / min | 2.52 / 2.0 |
| Branch | `cursor/studio-ui-ux-plan-loop` |
| HEAD | `f398a1e4` |
| Tracking issue | #182 |

## Last iterations

- 2026-05-24T19:36:50+00:00: `studio-ux-03-render-wgpu-smoke` agent=0 gates=True ux=True
- 2026-05-24T21:42:00+00:00: `studio-ux-03-render-wgpu-smoke` agent=0 gates=True ux=True
- 2026-05-24T23:05:00+00:00: `studio-ux-04-particle-display` agent=0 gates=True ux=True
- 2026-05-25T00:42:54+00:00: `studio-ux-04-particle-display` agent=0 gates=True ux=True
- 2026-05-25T02:14:50+00:00: `studio-ux-06-agent-chrome` agent=0 gates=True ux=True
- 2026-05-29T08:42:00+00:00: `studio-ux-11-panel-switch-gate` agent=0 gates=True ux=True
- 2026-05-30T01:04:00+00:00: `studio-ux-12-world-studio-demo-linux-audit` agent=0 gates=True ux=True
- 2026-05-30T04:33:00+00:00: `studio-ux-13-proactive-sweep` agent=0 gates=True ux=True

## Bench (latest)

```json
{
  "generated_at": "2026-05-30T04:33:42Z",
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
      "STUDIO_MEMORY_JSON={\"schema\":\"li_studio_memory_profile_v1\",\"generated_at\":\"2026-05-30T04:33:42Z\",\"memory_id\":\"animate_md_import\",\"warn_peak_mib\":512.0,\"peak_import_mib\":0.46,\"peak_rss_mib\":null,\"peak_observed_mib\":0.46,\"meets_budget\":true,\"rss_status\":\"skip\",\"registry_path\":\"benchmarks/competitive/studio-ui.toml\",\"notes\":[\"import peak = tracemalloc after loading animate_md\",\"rss peak = --skip-export --max-frames 4 when /usr/bin/time available\",\"full GIF export can exceed budget; Studio timeline uses streamed frames\"]}"
    ],
    "profile": {
      "schema": "li_studio_memory_profile_v1",
      "generated_at": "2026-05-30T04:33:42Z",
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
      "package": "li-gpu"
```


## UX dimensions

| ID | Score |
|----|------:|
| UX-01 | 2.2 |
| UX-02 | 2.8 |
| UX-03 | 2.8 |
| UX-04 | 2.5 |
| UX-05 | 3 |
| UX-06 | 2.4 |
| UX-07 | 3 |
| UX-08 | 2 |
| UX-09 | 3 |
| UX-10 | 3.2 |
| UX-11 | 3 |
| UX-12 | 2.4 |
| UX-13 | 2.5 |
| UX-14 | 2.8 |

## Canvas

Open `canvases/studio-ui-ux-daily-report.canvas.tsx` in Cursor (live refresh via agent-canvases-watch).

## Gates per iteration

| Gate | Script |
|------|--------|
| Design system | `studio-ui-ux-generate-design-system.sh` |
| Validity + build | `studio-ui-ux-plan-gates.sh` |
| Perf / memory | `bench-studio-viewport-perf.sh`, `profile-animate-memory.sh` |
| Capture | `studio-ui-ux-capture-progress.sh` |
| Publish | `studio-ui-ux-commit-push.sh` |

