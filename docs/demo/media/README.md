# Studio demo media (gitignored outputs)

Large binaries are **not** committed. `.gitignore` covers `studio-verticals-demo.mp4`, `native-verticals/png/`, and concat lists under this directory.

Honesty matrix and blockers: [VERTICALS-RECORDING.md](../VERTICALS-RECORDING.md).

## Generate (local)

**Prerequisites:** `ffmpeg`, `python3`, C compiler (`cc`/`gcc`). SDL2 is optional for the CPU present host (`deploy/studio-demo/native/studio_verticals_present_host.c`).

```bash
# From lic repo root
lic check packages/li-studio/li-tests/smoke/studio_vertical_profile_roundtrip.li

# Native PNGs (7 vertical profiles)
LIG_HOST_PRESENT=1 ./scripts/studio-verticals-capture-native.sh

# MP4 (~80s, 1920×1080, native frames only)
LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh
```

Dry-run (no capture/ffmpeg):

```bash
STUDIO_VERTICALS_DRY_RUN=1 ./scripts/record-studio-verticals-demo.sh
```

**Outputs (gitignored):**

| Path | Role |
|------|------|
| `native-verticals/png/*.png` | One frame per vertical |
| `native-verticals/capture.json` | Provenance (`native_pixels`, sources) |
| `studio-verticals-demo.mp4` | User-facing tour |
| `ffmpeg-verticals-scenes.txt` | ffmpeg concat list (regenerated) |

## Publish (GitHub Release)

Default release tag: **`studio-verticals-demo`** (asset name matches the file).

```bash
# After record-studio-verticals-demo.sh produced the MP4
export GH_TOKEN=...   # or: gh auth login
./scripts/upload-studio-verticals-demo-release.sh
# Or explicit tag:
./scripts/upload-studio-verticals-demo-release.sh studio-verticals-demo
```

The upload script creates the release if missing, then `gh release upload --clobber`. Do **not** `git add` the MP4.

**Download for users:**

```bash
gh release download studio-verticals-demo -p studio-verticals-demo.mp4 -D docs/demo/media/
```

## CI (optional)

Workflow [`.github/workflows/studio-verticals-demo-release.yml`](../../.github/workflows/studio-verticals-demo-release.yml) — `workflow_dispatch` only:

1. Installs `ffmpeg` (Ubuntu runner).
2. Runs `record-studio-verticals-demo.sh` (CPU native present host; no repo secrets).
3. Uploads to release `studio-verticals-demo` via `GITHUB_TOKEN`.

Trigger: **Actions → Studio verticals demo release → Run workflow**.
