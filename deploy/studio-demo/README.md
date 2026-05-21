# Li World Studio — demo showcase

> **Repo home (target):** **`studio-app`** — see [MOVED.md](MOVED.md) · [package-import-naming.md](../../docs/ecosystem/package-import-naming.md).  
> This copy under **`lic/deploy/`** is temporary until the product repo is created.

Interactive **agent-first studio shell** (outliner, viewport, **Agent chat dock**) with animated verticals:

- **Agent dock** — chat bubbles, plan card, Apply/Reject, `/build` hints (right rail)  
- **Gate chip** — `lic build · PASS` in toolbar + inline in transcript  
- **⌘K palette** — same `ui_cmd_*` IDs as native plan  

Other verticals:

- **Rocket** — custom / inverse gravity + Lorentz factor  
- **Racing** — automotive LiDAR loop  
- **Robot** — 6-DOF arm  
- **Drug LITL** — hypothesis → DFT pipeline  
- **Bioeng** — DBTL + bioreactor overlay  
- **MMO** — gateway + shards  

## Quick start

```bash
./scripts/open-studio-design-preview.sh              # interactive (canonical)
./scripts/open-studio-design-preview.sh --capture  # PNG gallery → .artifacts/ (gitignored)
```

Or:

```bash
python3 -m http.server 8765 --directory deploy/studio-demo
# http://localhost:8765/
```

**No PNG/WebM in git** — see `mockups/README.md`. Demo reel: `./scripts/record-studio-demo.sh` → `videos/` (gitignored).

Docs: [docs/game-dev/demo-showcase.md](../../docs/game-dev/demo-showcase.md)
