# Competitive intel — World Studio / Li Engine

**Purpose:** Give agents **actionable UI/UX and domain-tool patterns** when implementing `li-ui`, `li-studio`, and sim profiles. This is **Layer C** intel; algorithm parity lives in `benchmarks/competitive/verticals.toml` and tier benches.

## Read order for UI work

1. [ui-ux-by-dimension.md](ui-ux-by-dimension.md) — 14 dimensions, incumbents, steal list, Li gap
2. [../competitive-landscape.md](../competitive-landscape.md) — one-page beat conditions
3. [../../ecosystem/algorithms-and-libraries-plan.md](../../ecosystem/algorithms-and-libraries-plan.md) §3–4 — vertical matrix + Layer B

## Offline snapshots (`downloads/`)

| File | Source | Use |
|------|--------|-----|
| `paraview-properties-panel.html` | ParaView 6.x docs | Scientific viz property panel |
| `prusa-ui-overview.html` | Prusa Knowledge Base | AM slicer layout + export flow |
| `blender-panel-api.html` | Blender Python API | N-panel / sub-panel hierarchy |

Refresh with:

```bash
source ~/Documents/Cursor/.env   # TAVILY_API_KEY
./scripts/fetch-competitive-intel.sh
./scripts/fetch-competitive-intel.sh --tavily   # AI reports + search JSON
```

First-time Tavily on this machine:

```bash
./scripts/setup-tavily-cli.sh    # uv + tavily-cli; needs TAVILY_API_KEY
```

| Tavily artifact | Content |
|-----------------|--------|
| `downloads/research-drug-discovery-ui.md` | Benchling / LiveDesign / Recursion / LOWE comparison (JSON body) |
| `downloads/research-scientific-editor-ui.md` | Docking & properties-panel guidelines |
| `downloads/search-*.json` | Isaac Sim, Unreal dock UX snippets |

## Maintenance

- Update `last_reviewed` in `sources.manifest.json` when re-fetching
- Quarterly: cross-check [competitive-landscape.md](../competitive-landscape.md) and `verticals.toml`
- File PH-UX issues via `li-cursor-agents` ui-ux-remediation template when a dimension regresses
