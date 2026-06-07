# Release notes: 2026-05-27 — studio-drug-litl-adaptive

## Summary

Studio shell inspector width and field rows now adapt to drug-design LITL stage (WP-DRUG-03).

## Agent continuation

1. **Read:** `packages/li-ui/src/lib.li` (`layout_studio_shell_drug_litl`), `packages/li-studio/src/lib.li` (`studio_adaptive_layout_for_drug_tick`).
2. **Run:** `lic check packages/li-studio/li-tests/smoke/studio_drug_litl_adaptive.li`.
3. **Next:** Wire runtime demo to call `studio_compose_shell_drug_litl` on profile switch; merge #342 wgpu readback after this.
4. **Blocked:** Real `studio.adaptive` panel IR (still compose rects); Wave A for production kernels.

## Changed

- `packages/li-ui/src/lib.li` — `layout_studio_shell_adaptive_inspector`, `studio_inspector_width_for_drug_litl_stage`, `layout_studio_shell_drug_litl`
- `packages/li-studio/src/lib.li` — `studio_drug_litl_inspector_field_rows`, `studio_mcp_dispatch_adaptive_drug`, `studio_compose_shell_drug_litl`; `li_std_studio_version` → 8
- `packages/li-studio/li-tests/smoke/studio_drug_litl_adaptive.li`, `packages/li-studio/li-tests/manifest.toml`

## Not changed

- `sim.drug_design` LITL chemistry payloads (already on main via #336)
- wgpu swapchain readback (#342)
- Compiler Wave A (#321)

## Breaking

N/A — additive compose/MCP helpers.

## Security

N/A — no trusted surface change.

## Performance

N/A — layout math only.

## Downstream

Agents calling `studio_adaptive_layout` MCP should pass sim tick; `result_code` encodes LITL stage index.
