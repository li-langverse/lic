# Open merge PR — World Studio / Li Engine

**Branch:** `feat/world-studio-impl-1` → `main`

## Preflight (required)

```bash
./scripts/merge-world-studio-preflight.sh
```

## Create draft PR (GitHub CLI)

```bash
gh pr create \
  --base main \
  --head feat/world-studio-impl-1 \
  --title "feat: World Studio / Li Engine (impl-1–33, 100+ gates)" \
  --body-file docs/game-dev/PR-world-studio-impl-summary.md \
  --draft
```

## Metrics at merge (impl-33)

| Metric | Value |
|--------|--------|
| Composable gates | **103** (milestone 100) |
| Spin-up templates | **11** |
| Demo tabs | 12 |
| Vertical demos | 7 |

See [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md).
