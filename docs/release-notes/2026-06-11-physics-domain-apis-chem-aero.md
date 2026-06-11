# Physics domain APIs — chem Arrhenius + aero orbit (lic#7)

**Issue:** [lic#7](https://gitlab.lilangverse.xyz/li-langverse/lic/-/issues/7)  
**North star:** proof-first domain surface (units, fields, integrator hooks) before perf.

## Changes

- **`li-physics-chem`:** `arrhenius_rate` uses `k0 * exp(-Ea/RT)`; `chem_arrhenius_smoke` oracle; version bump to 2.
- **`li-physics-aero`:** `OrbitState2D`, `gravity_accel_from_offset`, `orbit_leapfrog_step`, `orbit_two_body_smoke`; version bump to 2.
- **Smokes:** honest `builds.li` for hep/aero/chem packages; `orbit_two_body_smoke.li`, `arrhenius_smoke.li`.
- **Composable:** `import_physics_aero.li`, `import_physics_chem.li`.
- **Gate:** `scripts/ph-physics-domain-gate.sh`.

## Follow-up

- Merge with MR !263 (hep/core Wave A+C) or supersede duplicate branches.
- Close lic#7 after CI green via `org-close-issue.py`.
