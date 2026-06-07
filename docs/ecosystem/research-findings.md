# Research findings (whitepapers)

Published goal-directed research lives in the sibling repo **[research-findings](https://github.com/li-langverse/research-findings)** (path from **lic**: `../research-findings`).

## Quick scan

- Human: [SCAN.md](https://github.com/li-langverse/research-findings/blob/main/SCAN.md)
- Machine: [index.yaml](https://github.com/li-langverse/research-findings/blob/main/index.yaml)

## Layout

`whitepapers/YYYY-MM/<goal-id>/<slug>/` — `README.md`, `artifacts.json`, `snippets/`

Agents publish via skill **`publish-research-whitepaper`** in `li-cursor-agents`. Rebuild catalog:

```bash
cd ../li-cursor-agents && ./scripts/publish-research-whitepaper.sh
```

## Related

- MD backlog: `sim-md-research-backlog.md`
- Chem backlog: `sim-chem-research-backlog.md`
- Grading: `sim-algo-research-grading.md`
