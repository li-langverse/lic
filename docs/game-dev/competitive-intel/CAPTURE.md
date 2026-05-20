# How to save screenshots & clips locally

We **cannot** redistribute Epic/Unity/Roblox marketing assets in the public repo. Save captures **on your machine** for internal review.

## Folder layout

```text
competitive-intel/media/local/
  unreal-engine/
  unity/
  godot/
  roblox/
  blender/
  figma/
  fortnite-uefn/
  clips/              # short screen recordings (.webm)
```

Already in repo `.gitignore` — binaries never commit.

**Quick checkout** (official doc images + YouTube thumbs):

```bash
./scripts/checkout-competitive-media.sh
```

Roblox CDN note: use `prod.docsiteassets.roblox.com`, not `create.roblox.com/docs/assets/…` (404).

## Suggested captures (per competitor)

| Shot | UE | Unity | Godot | Roblox |
|------|-----|-------|-------|--------|
| Full editor default layout | ✓ | ✓ | ✓ | ✓ |
| Viewport + outliner | ✓ | ✓ | ✓ | ✓ |
| Cinematic / timeline | Sequencer | Timeline | AnimationPlayer | UEFN Cinematic Device |
| UI authoring | UMG | UI Builder | Control inspector | UI tab + Style Editor |
| Infinite / spatial canvas | — | — | — | — | Figma ✓ |

**Resolution:** 1920×1080 PNG; name `YYYY-MM-DD_<feature>_<view>.png`.

## Video clips

- Use OBS 30–120s clips of: product keynote hero moment, Sequencer scrub, UI Builder, Roblox UI tab.  
- Store as `clips/<competitor>_<title>.webm`.  
- Update `catalog.json` `local_path` field when added.

## Official doc screenshots (hotlink in notes only)

Many docs embed images on CDNs tied to their sites — prefer **your own capture** for stable references.

Roblox documents reference paths like `assets/studio/general/Editor-Window.jpg` on `create.roblox.com` — open the doc in browser and save from there.
