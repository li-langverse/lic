# Studio vertical: `sim_scientific`

**Focus:** Profile chip + particle display tier / MD labels; **detail-tier smokes** on each studio tick.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `sim_scientific_tick_stub` — MD/heat/rigid **state evolution** + `scientific_oracle_*` | Full `sim.viz` package |
| `sim_scientific_viz_tier_ok` → `li-scene` MD tiers | Tier-2 competitive benches in viewport |
| `studio_md_particle_tier_select_ok` | LAMMPS/GROMACS oracle parity |
| Compose + native present host (h=26) | Full `SimWorld` scientific runs |

## Verify

```bash
lic check packages/li-sim-scientific/li-tests/smoke/scientific_tick_tiers.li
lic check packages/li-sim-scientific/li-tests/smoke/scientific_oracle_bench.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_scientific.html`
