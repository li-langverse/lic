# Package repos aligned with import paths

**Date:** 2026-05-21  
**Branch:** `feat/agent-first-gui`

## Summary

Official packages now use **repo name = Li import path**:

- `import studio` → [github.com/li-langverse/studio](https://github.com/li-langverse/studio)
- `import studio.ai` → [github.com/li-langverse/studio.ai](https://github.com/li-langverse/studio.ai)
- `import world` → [github.com/li-langverse/world](https://github.com/li-langverse/world)
- … and sibling `sim.*`, `physics.*`, `render`, `ui`, etc.

## Monorepo

- `packages/li-studio/` → `packages/studio/`
- `packages/li-studio-ai/` → `packages/studio.ai/`
- All workspace members renamed to match imports (dots allowed in folder names).

## Tooling

```bash
python3 scripts/align-package-repo-names.py --metadata-only --apply
python3 scripts/align-package-repo-names.py --apply
./scripts/push-import-aligned-mirrors.sh --create
```

## Docs

- [package-import-naming.md](../ecosystem/package-import-naming.md)
- [repo-naming.md](../ecosystem/repo-naming.md) (supersedes `li-` + hyphen convention)

## Not changed

- **`lic`** — compiler only  
- **`studio-app`** — product repo for demo/mocks (bootstrap script)
