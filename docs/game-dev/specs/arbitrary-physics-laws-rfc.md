# RFC: Arbitrary & unphysical physics laws

**Status:** Draft  
**Track:** PH-SIM · PH-PHYS-CUSTOM  
**Vision:** [world-studio-vision.md](../world-studio-vision.md)

## Problem

Realistic integrators (semi-implicit Euler, symplectic stacks, conserved quantities) are **wrong** as the only option:

- **Games** need inverse gravity, scripted teleports, zero drag, non-conservative boosts, and per-frame rule changes.
- **Research** needs counterfactual universes (different \(g\), broken symmetries, toy QM/classical hybrids) without forking the engine.

Hard-coding “real physics only” forces studios to bypass the engine with ad-hoc C++ or duplicate simulators.

## Proposal

### Law modes (per world / entity)

| Mode | Value | Behavior |
|------|-------|----------|
| `realistic` | 0 | `li-physics-runtime` + tiered `li-physics-*` |
| `arbitrary` | 1 | **Only** `physics.custom` laws — no conservation required |
| `hybrid` | 2 | Realistic base + custom overrides per body/region |

### Package: `li-physics-custom` (`import physics.custom`)

- `CustomState` — minimal phase-space carrier (games + research)
- `custom_law_step_*` — per-law integrators (inverse gravity, zero drag, teleport)
- `custom_law_apply(law_id, …)` — **CUSTOM-1** (dispatch blocked on borrowck in CUSTOM-0)
- Built-ins: inverse gravity, zero drag, teleport pulse (`allows_discontinuity`)
- User laws: `law_id >= 1000` via `custom_law_user_register_stub` (future: `def` callbacks with proofs optional)

### `li-sim` integration

- `SimWorld.law_mode`, `SimWorld.custom_law_id`
- `sim_set_law_mode`, `sim_step_arbitrary` — tick without forcing realistic integrator

```li
import sim
import physics.custom

def game_step_unphysical(w: SimWorld, s: CustomState) -> unit
  requires w.law_mode == sim_law_mode_arbitrary()
  requires w.custom_law_id == custom_law_builtin_inverse_gravity()
=
  custom_law_step_inverse_gravity(s, w.dt)
  sim_step_arbitrary(w)
```

### Studio / compliance

- World Studio inspector: **Law mode** + pick built-in or project `def` law.
- **Unphysical** runs skip energy-drift gates; scientific export can require `law_mode == realistic` via `studio.toml`.

## Proof policy

| Law class | Contracts |
|-----------|-----------|
| Realistic tier | Full `requires` / `ensures` / drift bounds |
| Built-in arbitrary | Document non-conservation; weak ensures (no false conservation claims) |
| User arbitrary | Author-owned contracts; engine does not prove physical truth |

## Phases

| Phase | Deliverable |
|-------|-------------|
| CUSTOM-0 | `li-physics-custom` stubs + `sim` law_mode (landed) |
| CUSTOM-1 | User `def` law registry + `lic check` on law modules |
| CUSTOM-2 | Hybrid per-entity masks in `li-scene` |
| CUSTOM-3 | GPU batch custom laws via `li-gpu` |

## Dependencies

`li-sim`, `li-physics-runtime`, PH-GD inspector (future).
