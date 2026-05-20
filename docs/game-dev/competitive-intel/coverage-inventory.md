# Local media coverage inventory

**Refresh:** `./scripts/checkout-competitive-media.sh`  
**Index:** `media/local/manifest.json` (gitignored)  
**Videos:** `media/local/clips/videos/` when `DOWNLOAD_VIDEOS=1` (off by default — YouTube often blocks CI/bots; use local machine + cookies)

---

## What “full pull” means here

| Tier | Description | In repo? |
|------|-------------|----------|
| **A — Links** | catalog.json + media-catalog.md | ✅ git |
| **B — Stills** | Screenshots, doc figures, marketing UI | ✅ `media/local/` (gitignored) |
| **C — Thumbs** | YouTube preview JPG | ✅ `clips/*-thumb.jpg` |
| **D — Short video** | yt-dlp ≤480p, &lt;20 min, ≤120MB each | ✅ `clips/videos/` (optional) |
| **E — Manual** | Your OBS capture of live apps | You → `media/local/` |

We do **not** mirror entire competitor sites or 4K keynotes in git.

---

## Coverage by competitor (after expanded checkout)

| Competitor | B stills | C thumb | D video | Notes |
|------------|:--------:|:-------:|:-------:|-------|
| Godot | ✅ strong | ✅ | optional | 22 editor webp |
| Unity | ✅ | ✅ | optional | UI Builder + **Timeline** |
| Unreal | ✅ | ✅ | optional | Sequencer + **MRQ** docs |
| Roblox | ✅ | ✅ | optional | Studio + **Assistant** |
| UEFN / FN | partial | ✅ | ✅ short | |
| CapCut | ✅ strong | ✅ | optional | 18+ webp |
| Blender | ✅ | ✅ | optional | VSE svg |
| DaVinci | ✅ | — | — | Cut/edit promos |
| VS Code | ✅ | — | — | Official doc PNGs |
| Cursor | OG | — | — | |
| Figma / Make | ✅ | — | — | UI3 + **Make** sanity |
| Houdini | ✅ | — | — | Node graphs |
| ParaView | ✅ | ✅ | optional | Docs + CVW |
| COMSOL | ✅ **Model Builder** | ✅ | optional | Was gap — now filled |
| SimScale | ✅ | — | — | |
| Benchling | ✅ | — | — | |
| Isaac Sim | ✅ | — | — | |
| Miro | ✅ | — | — | Board marketing |
| Jupyter | ✅ | — | — | |
| Cura / Prusa | thumb | ✅ | optional | **Plater UI still manual** |
| COMSOL-class ANSYS | — | — | — | URLs only |
| Fusion / SolidWorks CAD | — | — | — | **Manual capture** |
| Gazebo | — | — | — | **Manual capture** |
| Premiere / Resolve full | partial | — | — | |

---

## Commands

```bash
# Images + thumbs + short videos (default)
./scripts/checkout-competitive-media.sh

# Images only (faster)
DOWNLOAD_VIDEOS=0 ./scripts/checkout-competitive-media.sh

# See what you have
jq '.file_count, (.files | group_by(.competitor) | map({(.[0].competitor): length}))' \
  docs/game-dev/competitive-intel/media/local/manifest.json
```

---

## Manual capture still needed (highest UX value)

1. **Cura 5** — main window plater + layer slider  
2. **Fusion 360** — timeline + simulate  
3. **Gazebo** — scene + joint panel  
4. **ANSYS Discovery** — mesh + results  

Save as `media/local/<name>/YYYY-MM-DD_main.png`.

---

## Study path

1. [coverage-inventory.md](coverage-inventory.md) (this file)  
2. Open files listed in [material-study-notes.md](material-study-notes.md)  
3. Read [ui-ux-by-dimension.md](ui-ux-by-dimension.md)  
4. Implement [li-native-gui-plan.md](../plans/li-native-gui-plan.md) v0.6
