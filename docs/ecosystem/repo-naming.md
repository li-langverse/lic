# GitHub repo naming (import-aligned)

**Canonical:** [package-import-naming.md](package-import-naming.md)

## Rule

**Official package repo name = Li import path** (including dots for submodules).

| Import | GitHub repo | Monorepo folder |
|--------|-------------|-----------------|
| `studio` | `studio` | `packages/studio` |
| `studio.ai` | `studio.ai` | `packages/studio.ai` |
| `world` | `world` | `packages/world` |
| `sim.scientific` | `sim.scientific` | `packages/sim.scientific` |
| `physics.relativity` | `physics.relativity` | `packages/physics.relativity` |

**Not** `li-studio`, `li-studio-ai`, or `li-` + hyphenated import.

## Tooling

```bash
# Patch li.toml + PUBLISH.md metadata
python3 scripts/align-package-repo-names.py --metadata-only --apply

# Rename packages/<legacy>/ → packages/<import>/
python3 scripts/align-package-repo-names.py --apply

# Push mirrors (create org repos on first run)
./scripts/push-import-aligned-mirrors.sh --create
```

Single package:

```bash
./scripts/push-official-package-repo.sh studio --create
```

## Exceptions

| Kind | Naming |
|------|--------|
| Toolchain | `lic`, `lip`, `lit` |
| Application | `studio-app` (not imported) |

## Legacy

Older docs used `li-` + hyphens (`li-physics-relativity`). **Do not create new repos** with that pattern.
