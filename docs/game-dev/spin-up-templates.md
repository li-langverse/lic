# World Studio spin-up templates (PH-GD / PH-SIM)

**Status:** Stub — `lis new` integration pending.

| Template | Profile | Packages |
|----------|---------|----------|
| `game` | `sim_profile_game()` | `studio`, `world`, `scene`, `sim` |
| `sim_rl` | `sim_profile_rl()` | `sim`, `ml` (future) |
| `sim_automotive` | `sim_profile_automotive()` | `sim`, `sim.automotive` (future) |
| `sim_additive` | AM | `sim`, `sim.additive`, `voxel` |
| `sim_scientific` | SCI | `sim`, `physics.*`, `chem` |
| `sim_drug_design` | DRUG | `studio`, `chem`, `sim.drug_design` (future) |

Example project snippet (hand-authored until scaffolding lands):

```li
import studio
import world
import sim

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var p = studio_project_new()
  studio_play(p)
  var w = sim_world_new(1.0 / 60.0, 1)
  sim_step(w)
  return 0
```
