# Li Studio marketing demos (HTML only)

Static previews for the Studio UI/UX plan loop. **Not** the shipped native app (`li-ui` / `li-gui` / `li-render`).

## Screenshots

| File | Purpose |
|------|---------|
| `screenshots/01-studio-workspace.html` | Full shell: viewport, timeline, inspector, agent running |
| `screenshots/02-studio-empty-viewport.html` | Empty scene / selection / idle agent |
| `screenshots/03-studio-agent-error.html` | Agent failed + error strip (recovery UX) |
| `screenshots/studio-tokens.css` | Generated from `docs/design/studio-design-tokens.toml` |
| `screenshots/capture.sh` | Headless Chrome PNG capture (1920×1080) |

## Capture harness

```bash
# From lic repo root
STUDIO_UI_UX_ITERATION=studio-ux-07-capture-harness \
  ./scripts/studio-ui-ux-capture-progress.sh
```

PNG/MP4 are written under `data/studio-ui-ux-plan-loop/artifacts/` and uploaded to GitHub release `studio-ui-ux-progress` (never committed). Progress comments go to the tracking issue (`data/studio-ui-ux-plan-loop/tracking-issue.txt`).

Dry run (gates / CI):

```bash
STUDIO_UI_UX_CAPTURE_DRY=1 ./scripts/studio-ui-ux-capture-progress.sh
./scripts/studio-ui-ux-verify-capture.py
```
