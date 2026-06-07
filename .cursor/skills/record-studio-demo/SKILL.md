# Record studio demo

Local-only studio vertical demo capture — **no GitHub Release artifacts**.

## When to use

Recording studio vertical frames or MP4 for local marketing / UX review.

## Policy

- **Local capture only** — `LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh`
- **No GitHub Release demo videos** — MP4/PNG must not ship on releases
- **No** `.github/workflows/*demo*release*` workflows
- Do not invoke `scripts/upload-studio-verticals-demo-release.sh` in agent flows
- PR #271 closed: won't do release MP4

## Workflow

1. `lic build packages/li-studio/src/main.li -o build/li-studio-demo` (when demo binary ready)
2. `lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li`
3. `LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh`
4. Optional MP4: `LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh`
5. Output under `docs/demo/media/` (gitignored) — never commit MP4 to git

## Reference

[VERTICALS-RECORDING.md](../../docs/demo/VERTICALS-RECORDING.md)
