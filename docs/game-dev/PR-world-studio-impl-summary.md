# PR summary — `feat/world-studio-impl-1` → `main`

**Purpose:** Land World Studio / Li Engine implementation (impl-1…impl-28).

## Stats (impl-28)

| Metric | Value |
|--------|-------|
| Packages added/extended | 28+ |
| Composable gates | **88** |
| LKIR present | `gpu_lkir_present_*` + `render_lkir_present_*` |
| Merge-ready gate | `import_world_studio_merge_ready` |
| Binary | runtime tag **8288** + verify script |
| Game dev parse_ok | **12** |
| Spin-up templates | **8** (incl. `scientific`, `game_unphysical`) |
| Vertical demo builds | **7** |
| Demo showcase | `deploy/studio-demo/` + WebM reel |
| Studio binary | `build/bin/world-studio` |
| CI | `ci-world-studio.sh` + `check-world-studio-gates.sh` |

## Verify before merge

```bash
./scripts/check-world-studio-gates.sh
# or:
./li-tests/run_all.sh composable
./li-tests/run_all.sh spinup_templates
```

## After merge

- Squash-merge or merge PR from `feat/world-studio-impl-1`
- Register new packages in ecosystem `official-packages.md` (human)
- Enable package CI per repo
- Upstream `lis new world-studio` in lis repo (shim exists in `lic/scripts/lis`)

## Known blockers (post-merge OK)

- `sim_step_physics` → `physics.runtime` (`sim_physics_runtime_deferred`)
