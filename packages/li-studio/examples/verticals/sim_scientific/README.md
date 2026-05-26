# Studio vertical: `sim_scientific`

**Focus:** Profile chip + particle display tier / MD labels; **detail-tier smokes** on each studio tick.

## Honest status

| Implemented | Not implemented |
|-------------|-----------------|
| `sim_scientific_tick_stub` — MD (detail 0–1), heat PDE (2), rigid (3) | CFD/MD oracles, `sim.viz` |
| `studio_md_particle_tier_select_ok` | Tier-2 competitive benches in viewport |
| Compose + native present host (h=26) | Full `SimWorld` scientific runs |

## Verify

```bash
lic check packages/li-sim-scientific/li-tests/smoke/scientific_tick_tiers.li
lic check packages/li-studio/li-tests/smoke/studio_sim_step_by_profile.li
```

## Mock

`deploy/studio-demo/archive/verticals-html-mocks/sim_scientific.html`
