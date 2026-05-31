# Studio studio.toml engine + export parsing (WP-SIM-06)

Cumulative line parser for `studio.toml` `[engine]` and `[engine.export]` sections lands in native Li Studio.

## Verify

```bash
lic check packages/li-studio/li-tests/smoke/studio_toml_engine_export.li
./scripts/world-studio-plan-gates.sh
```

## Changed

| Area | What |
|------|------|
| `runtime/li_rt.c` | `li_rt_studio_toml_*` — profile, determinism_tier 0–3, export format mask, require_sim_pass, printer_profile slot |
| `li-studio` | `studio_toml_parsed_config`, `studio_apply_config_to_sim` maps tier → `output_detail` |
| Smoke | `studio_toml_engine_export.li` — sim_additive fixture + tier override |
| Example | `examples/verticals/sim_additive/studio.toml` |

## Remaining

- Full TOML file I/O (not line-at-a-time) — WP-PUB-03 publish manifest.
- Bracket-list `formats = ["3mf", "gcode"]` parse in native file reader (line parser uses substring mask for lic check).
