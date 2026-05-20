# World Studio spin-up templates (PH-GD / PH-SIM)

**Status:** Scaffold via `./scripts/lis-new-world-studio.sh` (until `lis new` ships).

| Template | Profile | Packages |
|----------|---------|----------|
| `game` | `sim_profile_game()` | `studio`, `world`, `scene`, `sim`, `physics.custom` |
| `game_unphysical` | `sim_law_mode_arbitrary()` | `sim`, `physics.custom` (inverse gravity, teleports, etc.) |
| `sim_rl` | `sim_profile_rl()` | `sim`, `ml` (future) |
| `sim_automotive` | `sim_profile_automotive()` | `sim`, `sim.automotive` |
| `sim_additive` | AM | `sim`, `sim.additive`, `voxel` |
| `sim_scientific` | SCI | `sim`, `sim.scientific`, `physics.*`, `chem` |
| `sim_robotics` | ROBO | `sim`, `sim.robotics` |
| `sim_drug_design` | DRUG | `studio`, `chem`, `sim.drug_design` |
| `bioengineering` | BIOENG | `bioeng`, `sim.drug_design`, `chem`, `ml`, `studio` |
| `mmorpg` | MMO | `mmo`, `store.realtime`, `player`, `sim`, `world`, `scene`, `net.httpd` |
| `studio_agent` | GD-3 | `studio.ai`, `studio`, `lic check` |
| `sim_rl` | ML | `sim`, `ml` |

## Scaffold a project

```bash
./scripts/lis-new-world-studio.sh game ./my-game
# or (shim until lis package ships):
./scripts/lis new world-studio mmorpg ./my-realm
./scripts/lis new world-studio drug_design ./my-lab
./scripts/lis new world-studio bioengineering ./my-bio
./scripts/lis new world-studio robotics ./my-cell
./scripts/lis new world-studio automotive ./my-race
./scripts/lis new world-studio scientific ./my-viz
./scripts/lis new world-studio game_unphysical ./my-weird-game
./scripts/lis new world-studio publish ./my-paper-figs
./scripts/lis new world-studio additive ./my-am-cell
./scripts/lis new world-studio agent ./my-agent-project
```

Registry: [deploy/world-studio-spinup/spinup.toml](../../deploy/world-studio-spinup/spinup.toml)

Composable gates: `import_spinup_game`, `import_spinup_mmorpg`, `import_spinup_drug`, `import_spinup_bioeng`.

Example project snippet (hand-authored):

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
