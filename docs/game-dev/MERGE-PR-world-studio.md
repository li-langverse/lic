# Open merge PR — World Studio / Li Engine

**Branch:** `feat/world-studio-impl-1` → `main`

## Preflight (required)

```bash
./scripts/merge-world-studio-preflight.sh
```

## Create draft PR

```bash
./scripts/create-world-studio-pr.sh
```

Or manually:

```bash
gh pr create \
  --base main \
  --head feat/world-studio-impl-1 \
  --title "feat: World Studio / Li Engine (130 gates, play_mode)" \
  --body-file docs/game-dev/PR-world-studio-impl-summary.md \
  --draft
```

## Metrics at merge (impl-41)

| Metric | Value |
|--------|--------|
| Composable gates | **145** |
| Spin-up templates | **12** (`play_mode`) |
| Demo tabs | 13 |
| Vertical demos | 7 |
| Author API | [world-api-quickstart.md](world-api-quickstart.md) |

See [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md).
