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
  --title "feat: World Studio / Li Engine (impl-1–32)" \
  --body-file docs/game-dev/PR-world-studio-impl-summary.md \
  --draft
```

## Metrics at merge (impl-32)

| Metric | Value |
|--------|--------|
| Composable gates | **100** |
| Spin-up templates | **10** |
| Demo tabs | 11 |
| Vertical demos | 7 |

See [MERGE-world-studio-checklist.md](MERGE-world-studio-checklist.md).
