# Publish metadata — PKG-li-physics-hep

| Field | Value |
|-------|--------|
| **PKG id** | `PKG-li-physics-hep` |
| **Registry name** | `li-physics-hep` (lip, phase 8d) |
| **Maintainer** | li-langverse |
| **Repository** | https://github.com/li-langverse/li-physics-hep |
| **License** | Apache-2.0 OR MIT (SPDX) |

## Exports (v1)

Education-tier toy MC (non-SOTA):

- `DecayChannel`, `McEvent`
- `decay_branching`, `isotropic_sample_angles`, `event_weight_cross_section`
- `hep_toy_cross_section_smoke`

## Bench refs

Education tier only — no tier-2 production oracle. Composable smoke: `hep_toy_mc_smoke.li`.

## Proof / coverage tier

| Gate | Required for registry |
|------|------------------------|
| `lic build` | Yes |
| `lit test --coverage` ≥ 80% | Yes (lip 8e) |
| ed25519 manifest signature | Yes (lip 8c) |
