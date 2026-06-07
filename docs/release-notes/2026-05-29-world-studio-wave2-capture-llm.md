# World Studio wave 2 — Li PPM capture + lillm matmul hint (2026-05-29)

## Summary

WP-UX-14b Step 1 and WP-LLM-05 partial: vertical PNG capture can use Li `studio_vertical_capture_ppm`; forward pass probes `ml_lig_matmul_run_auto`.

## Changed

| Path | Notes |
|------|-------|
| `runtime/li_rt_studio_paint_capture.c` | `li_rt_studio_shell_paint_ppm` (includes paint_fb layout) |
| `packages/li-studio` | `studio_vertical_capture_ppm`, `capture_vertical.li`, smoke |
| `scripts/studio-verticals-capture-li-demo.sh` | Li PPM path with C fallback |
| `packages/li-llm` | `llm_forward_matmul_cpu_hint`, forward raises IO |
| `compiler/codegen/compile.cpp` | link paint capture runtime |

## Not changed

- C files under `deploy/studio-demo/native/` not deleted (Step 4)
- wgpu swapchain readback PNGs
- PR #374 agentic wave 1 (still open)

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_vertical_capture_ppm.li
lic check packages/li-llm/li-tests/smoke/llm_forward_matmul.li
./scripts/studio-verticals-capture-li-demo.sh
```
