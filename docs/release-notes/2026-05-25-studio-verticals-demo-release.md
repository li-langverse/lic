# Studio verticals demo — GitHub Release publish path

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/gap-demo-release  
**PH / REQ:** PH-UX (demo media), gap verticals MP4 not in git  
**Author:** agent

---

## Summary

Documents how to generate the gitignored `studio-verticals-demo.mp4`, upload it to GitHub Release `studio-verticals-demo`, and optionally rebuild via `workflow_dispatch` CI (no MP4 in git).

## Agent continuation

1. **Read** — `docs/demo/media/README.md`, `docs/demo/VERTICALS-RECORDING.md`.
2. **Run** — `LIG_HOST_PRESENT=1 ./scripts/record-studio-verticals-demo.sh`; `./scripts/upload-studio-verticals-demo-release.sh` (with `GH_TOKEN` or `gh auth login`).
3. **Then** — On merge, run Actions workflow once to seed the release asset for users; link download URL in studio/marketing docs if needed.
4. **Blocked on** — PR #258 (`feat/vertical-gap-native-present`) for `STUDIO_DEMO_PROFILE` / li-studio-demo capture path — orthogonal to release wiring.

## Changed

| Area | What | Evidence |
|------|------|----------|
| `scripts/upload-studio-verticals-demo-release.sh` | Create release if missing; upload MP4 with `--clobber` | Local record + upload script |
| `docs/demo/media/README.md` | Generate + publish + `gh release download` | — |
| `.github/workflows/studio-verticals-demo-release.yml` | `workflow_dispatch` build + upload | Ubuntu ffmpeg + CPU native host |
| `docs/demo/VERTICALS-RECORDING.md` | Link to media README | — |

## Not changed

- `record-studio-verticals-demo.sh` / `studio-verticals-capture-native.sh` capture logic
- `.gitignore` (MP4 already ignored)
- wgpu / `li-studio-demo` window readback (PR #258)
- `li-langverse/studio` org repo

## Breaking

N/A — additive publish path.

## Security

N/A — public demo asset; workflow uses `GITHUB_TOKEN` only (no custom secrets in repo).

## Performance

N/A — no bench threshold changes.

## Downstream

| Repo | Action |
|------|--------|
| studio / marketing | Document `gh release download studio-verticals-demo` when promoting verticals reel |

## CHANGELOG entry (paste into Unreleased)

### Added

- **Studio verticals demo release:** `upload-studio-verticals-demo-release.sh`, `docs/demo/media/README.md`, optional GHA `studio-verticals-demo-release` workflow — MP4 via GitHub Release `studio-verticals-demo`, not git — `docs/release-notes/2026-05-25-studio-verticals-demo-release.md`.
