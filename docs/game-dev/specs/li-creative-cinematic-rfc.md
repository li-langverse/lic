# RFC: Creative stack — 3D scene, animation, cinematics, video

**Status:** Draft  
**Parent:** [li-native-gui-plan.md](../plans/li-native-gui-plan.md) v0.4  
**Policy:** Li only — `li-scene`, `li-anim`, `li-seq`, `li-render`, `studio.publish`

## Problem

World Studio must support **creative authoring**: 3D scenes, character/object animation, **cinematic timelines**, and **video export** — not only HUDs and agent graphs. Creators and agents need diffable Li sources, same gates as `world.li`.

## Proposal

### Packages (Li)

| Package | Role |
|---------|------|
| `li-scene` | Scene graph, `Transform3`, sync to physics |
| `li-anim` | `Clip`, channels, keyframes, playback sample |
| `li-seq` | Timeline, tracks, shots, camera cuts, events |
| `li-render` | Frame render for viewport + offline export |
| `li-gpu` | Present + encode frames → video container |
| `li-assets` | glTF, textures, audio refs |
| `li-studio` | Workspaces: Scene, Animate, Cinematic, Publish |
| `li-gui` | Canvas nodes: Sequence, Shot, Camera, AnimationClip, VideoExport |

### Project layout

```text
scene/main.li
anim/hero_walk.li
seq/intro_cinematic.li
assets/hero.gltf
publish/video.toml
```

### Determinism

`seq_playback_at(t)` + fixed `dt` + seed → **frame checksum** for replay and honest video export (pairs with `sim_replay_*`).

### Video export

`studio.publish_video(preset)` → WebM/MP4 path + `PublishBundle.content_hash` — repro bundle in git-LFS or artifact store (policy TBD).

### Agent MCP (future)

`seq_add_shot`, `seq_add_track`, `anim_add_keyframe`, `publish_render_video`, `scene_place_node`

### Phases

Parent plan **G6** (scene + anim), **G7** (seq + video), **G8** (creator UGC).

## SOTA reference (UX only)

Unreal Sequencer, Unity Timeline, Blender VSE, Godot AnimationPlayer — **patterns only**, Li implementation.

## Open questions

- [ ] Offline render vs real-time capture for v1 export?
- [ ] Audio in seq v1?
- [ ] Max timeline length / resolution presets?
