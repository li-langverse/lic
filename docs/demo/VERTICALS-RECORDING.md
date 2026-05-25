# Studio verticals — recording honesty matrix (UX-14)

| Vertical | Native compose/paint (`lic check`) | HTML mock (`deploy/.../verticals/*.html`) | Native pixels (SDL/wgpu) | Not implemented |
|----------|-----------------------------------|-------------------------------------------|--------------------------|-----------------|
| `game` | `studio_compose_shell_profile`, `studio_shell_demo` smokes | Selection + timeline scene | Optional `LIG_HOST_PRESENT=1` present tick JSON only | Full li-player ship loop |
| `sim_rl` | Profile id + topbar chip paint | Agent “training env” strip | Same | Live env stepping / PH-ML pools |
| `sim_automotive` | Profile roundtrip | Viewport **PLACEHOLDER** label | Same | Maps, sensors, `li-sim-automotive` |
| `sim_robotics` | Inspector field rows when `has_selection=1` | Joint inspector copy | Same | IK, factory cells |
| `sim_additive` | Profile + TOML parse `sim_additive` | 3MF/G-code export hint | Same | `sim.export.print`, printer profiles |
| `sim_scientific` | Profile + particle tier labels in mock HUD | MD / display tier copy | Same | CFD/MD oracles, `sim.viz` |
| `sim_drug_design` | Profile + drug paint color | Adaptive-stage hint | Same | `studio.adaptive`, `li-chem` live |

## Commands

```bash
# Regenerate HTML mocks (tokens: ../studio-tokens.css)
python3 deploy/studio-demo/screenshots/verticals/generate-mocks.py

# PNG + MP4 (needs Chrome + ffmpeg)
./scripts/record-studio-verticals-demo.sh

# Dry-run paths only
STUDIO_VERTICALS_DRY_RUN=1 ./scripts/record-studio-verticals-demo.sh

# Native smokes
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li
```

## MP4

- **Path:** `docs/demo/media/studio-verticals-demo.mp4`
- **Scenes:** 7 × 10s + 5s outro (configurable via `STUDIO_VERTICAL_SCENE_SEC`)
- **Banner:** `MARKETING MOCK — profile: <id> · native_product: false` on every HTML frame
