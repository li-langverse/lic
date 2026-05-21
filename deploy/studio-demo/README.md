# Li World Studio — demo showcase

> **Repo home (target):** [`li-world-studio`](https://github.com/li-langverse/li-world-studio) — see [MOVED.md](MOVED.md) · [li-studio-repos.md](../../docs/ecosystem/li-studio-repos.md).  
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
python3 -m http.server 8765 --directory deploy/studio-demo
# http://localhost:8765/preview.html   ← all v2 images + demo video
# http://localhost:8765                ← interactive studio
```

**v2 mockups:** `mockups/*-v2.png` · **Demo reel:** `videos/world-studio-demo-reel.webm`

## Demo video

Pre-rendered reel: [videos/world-studio-demo-reel.webm](videos/world-studio-demo-reel.webm)

Re-record:

```bash
./scripts/record-studio-demo.sh
# DURATION=30 FPS=12 ./scripts/record-studio-demo.sh
```

Docs: [docs/game-dev/demo-showcase.md](../../docs/game-dev/demo-showcase.md)
