# Release notes: AL-12 `li-seq` scaffold (2026-05-23)

## Summary

**wave-d-14-seq-scaffold (AL-12):** first **`import seq`** package with `SeqShot` / `SeqTimeline` types and `seq_active_shot_at` + `seq_local_time_in_span`; composable smoke test.

## Changes

- `packages/li-seq/` — scaffold via `li-new-package`; `import_name = "seq"`; `workload_class=stub`
- `packages/li-seq/src/lib.li` — shot/timeline types, two-shot resolve, closed-form `seq_timeline_smoke_entry` → `1010`
- `li-tests/composable/import_seq_shot_timeline.li` — `compile_open_ok`
- `packages/li.toml` — workspace member `li-seq`

## Plan

Marks `wave-d-14-seq-scaffold` completed on compiler-studio plan loop.
