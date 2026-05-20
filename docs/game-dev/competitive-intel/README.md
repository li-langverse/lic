# Competitive intel — videos, screenshots, product intros

**Purpose:** Research catalog + analysis for World Studio / Li native GUI (plan v0.4).  
**Policy:** We **do not** commit third-party video files or scraped screenshots without license — we store **links, metadata, and our analysis**. Team members may add captures under `media/local/` per [CAPTURE.md](CAPTURE.md).

| Doc | Contents |
|-----|----------|
| **[recent-published.md](recent-published.md)** | **Aggregated announcements + demo videos (2024–2026)** |
| [media-catalog.md](media-catalog.md) | Full URL tables + docs/screenshot sources |
| [analysis.md](analysis.md) | Cross-competitor synthesis → Li recommendations |
| [catalog.json](catalog.json) | Machine-readable index (`announcement` \| `demo` \| `doc`) |
| [by-competitor/](by-competitor/) | One-pagers per product |

**Last updated:** 2026-05-20

## Quick use

1. Read **recent-published.md** for latest announcements and demo videos.  
2. Read **analysis.md** for product decisions.  
3. Use **media-catalog.md** for full URL tables and screenshot sources.  
4. **Checkout reference media locally** (not in git):
   ```bash
   ./scripts/checkout-competitive-media.sh
   ```
   → `media/local/<competitor>/` + `media/local/manifest.json` (gitignored).  
5. Add your own captures per [CAPTURE.md](CAPTURE.md).  
6. Apply patterns via **[unified-studio-ux-vision.md](../unified-studio-ux-vision.md)** (game + sim + CAD + agent, one shell).  
7. Iterate [li-native-gui-plan.md](../plans/li-native-gui-plan.md) from analysis § Li mapping.

## Competitors covered

Unreal Engine · Unity · Godot · Roblox Studio · Blender · Figma · Fortnite UEFN · (reference: Cursor, ComfyUI)

## Honesty

This is **UX/pattern research**, not a claim that Li implements these features. Links may go stale — verify before demos.
