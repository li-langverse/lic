# li-seq

Cinematic / sequencing package — shots, master timeline, clip scheduling (`workload_class=stub`).

**Status:** stub (`seq_workload_class_stub` → 0); encode and `studio.publish` parity deferred.

**Import:** `import seq` — `SeqShot`, `SeqTimeline`, `shot_new`, `timeline_new_two_shots`, `seq_active_shot_at`, `seq_local_time_in_span`.

`clip_id` links `import anim` clips by convention; no cross-package import until publish wire (wave E).

## Build

```bash
lic build src/lib.li -o li-seq
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-li-seq` |
| Org repo | https://github.com/li-langverse/li-seq |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
