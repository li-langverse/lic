# Li World Studio — demo showcase

Interactive **studio shell prototype** (outliner, viewport, adaptive panels) with animated verticals:

- **Rocket** — custom / inverse gravity + Lorentz factor  
- **Racing** — automotive LiDAR loop  
- **Robot** — 6-DOF arm  
- **Drug LITL** — hypothesis → DFT pipeline  
- **Bioeng** — DBTL + bioreactor overlay  
- **MMO** — gateway + shards  

## Quick start

```bash
python3 -m http.server 8765 --directory deploy/studio-demo
# http://localhost:8765
```

## Demo video

Pre-rendered reel: [videos/world-studio-demo-reel.webm](videos/world-studio-demo-reel.webm)

Re-record:

```bash
./scripts/record-studio-demo.sh
# DURATION=30 FPS=12 ./scripts/record-studio-demo.sh
```

Docs: [docs/game-dev/demo-showcase.md](../../docs/game-dev/demo-showcase.md)
