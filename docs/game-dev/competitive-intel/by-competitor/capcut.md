# CapCut — competitive notes (creator video / short-form)

**Dimension:** [Cinematic §9](../ui-ux-by-dimension.md#9-cinematic--video-editing)  
**Media:** CC-* in [media-catalog.md](../media-catalog.md) · `media/local/capcut/`

## Product positioning

- **Creator-first** short-form editor (TikTok ecosystem); desktop Mac/PC.  
- **AI-forward:** auto-captions, script-to-video, smart search, auto reframe, filler-word removal.  
- Not a game cinematic tool — **fast social export** is the hero.

## UI layout (what works)

```text
[Media bin]     [ Preview + transport ]
[ Multi-track timeline — video + audio ]
                [ Inspector — clip props ]
```

| Panel | Steal for Li |
|-------|----------------|
| Media top-left | Asset browser + stock (we: `li-assets`) |
| Preview top-right | `seq` preview + scrub |
| Timeline bottom | `li-seq` tracks — same muscle memory |
| Inspector right | Shot/clip properties, speed, color |
| One-click export presets | `studio.publish_video` presets (1080p30, 4K, vertical 9:16) |
| AI captions track | Optional `seq` subtitle track (v2) |

## Pain points

- Cloud/account lock-in; project not diffable git  
- AI edits without reproducibility hash  
- No link to **3D engine** / sim validity  

## Li mapping

| CapCut | Li |
|--------|-----|
| Timeline | `seq/*.li` |
| Export 4K / social | `studio.publish_video` + **frame hash** |
| Script-to-video | Agent → `seq` + `lic build` (gated) |
| Auto reframe | `seq` shot aspect presets |

➕ **Deterministic export + repro bundle** — CapCut cannot tie video to `world.li` / bench validity.

## Capture targets

- Full desktop default layout  
- Export dialog with resolution presets  
- Auto-captions panel
