# Release notes: AL-12 `li-anim` scaffold (2026-05-23)

## Summary

**wave-d-13-anim-scaffold (AL-12):** first **`import anim`** package with `AnimKeyframe` / `AnimClip` types and `anim_sample_clip` (explicit `quat_slerp` + vec3 lerp); composable smoke test.

## Changes

- `packages/li-anim/` — scaffold via `li-new-package`; `import_name = "anim"`; `workload_class=stub`
- `packages/li-anim/src/lib.li` — keyframe/clip types, two-key sample, closed-form `anim_sample_clip_smoke_mid_w`
- `li-tests/composable/import_anim_keyframe_clip.li` — `compile_open_ok`
- `packages/li.toml` — workspace member `li-anim`

## Plan

Marks `wave-d-13-anim-scaffold` completed on compiler-studio plan loop.
