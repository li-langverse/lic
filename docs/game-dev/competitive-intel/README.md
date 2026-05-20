# Competitive intel — videos, screenshots, product intros

**Purpose:** Research catalog + analysis for World Studio / Li native GUI (plan v0.4).  
**Policy:** We **do not** commit third-party video files or scraped screenshots without license — we store **links, metadata, and our analysis**. Team members may add captures under `media/local/` per [CAPTURE.md](CAPTURE.md).

| Doc | Contents |
|-----|----------|
| **[material-study-notes.md](material-study-notes.md)** | **Local UI pulls → plan deltas** (run checkout script first) |
| **[ui-ux-by-dimension.md](ui-ux-by-dimension.md)** | **UI/UX learnings — every dimension (game, CAE, CAD, lab, …)** |
| **[recent-published.md](recent-published.md)** | **Aggregated announcements + demo videos (2024–2026)** |
| [media-catalog.md](media-catalog.md) | Full URL tables + docs/screenshot sources |
| [analysis.md](analysis.md) | Cross-competitor synthesis → Li recommendations |
| [catalog.json](catalog.json) | Machine-readable index (`announcement` \| `demo` \| `doc`) |
| [by-competitor/](by-competitor/) | One-pagers per product |

**Last updated:** 2026-05-20

## Quick use

1. Read **ui-ux-by-dimension.md** for per-industry UI/UX patterns and Li mapping.  
2. Read **recent-published.md** for latest announcements and demo videos.  
3. Read **analysis.md** for product decisions.  
4. Use **media-catalog.md** for full URL tables and screenshot sources.  
5. **Checkout reference media locally** (not in git):
   ```bash
   ./scripts/checkout-competitive-media.sh
   ```
   → `media/local/<competitor>/` + `media/local/manifest.json` (gitignored).  
6. Add your own captures per [CAPTURE.md](CAPTURE.md) — see dimension **capture backlog** in ui-ux-by-dimension.  
7. Apply patterns via **[unified-studio-ux-vision.md](../unified-studio-ux-vision.md)** (one shell).  
8. Iterate [li-native-gui-plan.md](../plans/li-native-gui-plan.md) from analysis § Li mapping.

## Competitors covered

**Games:** Unreal · Unity · Godot · Roblox · UEFN  
**Design / graph:** Figma · Houdini · ComfyUI (ref) · Cursor  
**DCC / video:** Blender · **CapCut** (creator NLE)  
**Sci / CAE:** ParaView · COMSOL · OpenFOAM/GROMACS (workflow)  
**CAD / AM:** Fusion/SolidWorks (patterns) · Cura/slicers  
**Robotics:** Gazebo · Isaac (patterns)  
**Lab:** Benchling · LITL-class pipelines

## Honesty

This is **UX/pattern research**, not a claim that Li implements these features. Links may go stale — verify before demos.
