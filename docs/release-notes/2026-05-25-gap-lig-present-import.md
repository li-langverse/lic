# Gap close: `import lig` resolves present + wgpu smoke

## Summary

Flattens `lig.present` swapchain/host-present APIs into `packages/lig/src/lib.li` so `lic check` resolves `import lig` (not `lig.present`), fixes `wgpu_smoke.li`, and wires `li-render` host present ticks against the merged surface.

## Agent continuation

1. **Read:** `packages/lig/src/lib.li`, `packages/lig/li-tests/smoke/wgpu_smoke.li`, `packages/li-render/src/lib.li`.
2. **Run:** `lic check packages/lig/li-tests/smoke/wgpu_smoke.li packages/lig/li-tests/smoke/lig_device_probe.li packages/li-render/li-tests/smoke/viewport_fps_counter.li`.
3. **Then:** merge to `main`; rebase PH-HW branches that still use `import lig.present`.
4. **Blocked on:** in-tree wgpu-rs / real adapter enumeration without `LIG_HOST_PRESENT=1`.

## Changed

| Area | Paths |
|------|-------|
| lig | `packages/lig/src/lib.li`, smokes, `bench/wgpu_smoke.toml`; deleted `present/lib.li` |
| li-render | `render_present_viewport_tick`, `render_viewport_host_fps_counter`, version 3 |

## Not changed

- Compiler import_resolve submodule map.
- LKIR kernels / WP4 memory beyond present FFI.
- li-studio timeline duplicate externals.
- Tier-2 physics / httpd.

## Breaking

N/A — use `import lig` instead of `lig.present`.

## Security

N/A — same `li_rt_lig_*` trusted FFI.

## Performance

N/A — bench hooks unchanged.

## Downstream

- PR #251 gap; integration PR #224 pattern.
