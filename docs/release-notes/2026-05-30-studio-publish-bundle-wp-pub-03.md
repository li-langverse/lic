# WP-PUB-03: publish_bundle reproducibility manifest

**Date:** 2026-05-30  
**WP:** WP-PUB-03  
**Todo:** `wsm-w6-repro-bundle`

## Summary

Native Li contract for reproducibility bundles: `studio_publish_bundle` assembles manifest fields (lic version, engine profile, determinism tier, sim checksum, world SHA256, figure/table entry counts) after `lic build` proof pass. MCP `publish_bundle` dispatch returns zip magic tag on success.

## Proof

```bash
lic check packages/li-studio/li-tests/smoke/studio_publish_bundle.li
./scripts/world-studio-plan-gates.sh
```

## Files

- `packages/li-studio/src/lib.li` — bundle types, three-click flow, MCP dispatch
- `packages/li-studio/li-tests/smoke/studio_publish_bundle.li`
