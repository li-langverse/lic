# li-anim

Cinematic / animation package — keyframes, clips, transform sampling (`workload_class=stub`).

**Status:** stub (`anim_workload_class_stub` → 0); blend trees and full Sequencer parity deferred.

**Import:** `import anim` — `AnimKeyframe`, `AnimClip`, `keyframe_new`, `clip_new_two_key`, `anim_sample_clip`.

Depends on `scene.Transform3` and `math.quat_slerp` (explicit linear algebra; no NumPy broadcast).

## Build

```bash
lic build src/lib.li -o li-anim
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-anim` |
| Org repo | https://github.com/li-langverse/li-anim |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
