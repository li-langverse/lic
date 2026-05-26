# Studio vertical: `sim_scientific`

**Focus:** Profile chip + particle display tier / MD labels; **detail-tier smokes** on each studio tick.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `sim_scientific_tick_stub` — MD/heat/rigid **state evolution** + `scientific_oracle_*` | ParaView/VTK field rendering |
| `sim_scientific_viz_tier_ok` → `li-scene` MD tiers | Tier-2 competitive benches **in** viewport |
| `sim.viz` pipeline stub (`viz_pipeline_*`, Properties/Display/View IDs) | wgpu particle/field draw (`li-render` `native_pixels=0`) |
| `studio_sim_scientific_viz_viewport_ok` — tier + pipeline gate on sim step | LAMMPS/GROMACS oracle parity |
| `studio_md_particle_tier_select_ok` | Full `SimWorld` scientific runs |
| Compose + native present host (h=26) | |

## Verify

```bash
lic check packages/li-sim-viz/li-tests/smoke/builds.li
lic check li-tests/composable/import_sim_viz_pipeline_source_display.li
lic check packages/li-sim-scientific/li-tests/smoke/scientific_tick_tiers.li
lic check packages/li-studio/li-tests/smoke/studio_sim_scientific_viz_viewport.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_scientific.html`
