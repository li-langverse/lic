# Official package naming (= import path)

**Status:** Canonical (2026-05)  
**Cursor rule:** `.cursor/rules/li-package-import-naming.mdc`

---

## Rule

Packages **officially released** by li-langverse are named **how they are imported**:

```li
import studio
import studio.ai
import world
import sim.scientific
```

→ Repos and lip registry names: **`studio`**, **`studio.ai`**, **`world`**, **`sim.scientific`** — not `li-studio`, `li-studio-ai`, `li-world`, …

---

## Submodule pattern

| Parent import | Submodule import | Released repo |
|---------------|------------------|---------------|
| `studio` | `studio.ai` | `github.com/li-langverse/studio.ai` |
| `sim` | `sim.scientific` | `sim.scientific` |
| `store` | `store.realtime` | `store.realtime` |
| `net` | `net.httpd` | `net.httpd` |

Use **dots** in repo slugs where the import uses dots (GitHub allows `.` in repository names).

---

## Exceptions

| Category | Naming | Why |
|----------|--------|-----|
| Toolchain | `lic`, `lip`, `lit`, `roadmap` | Not lip-importable libraries |
| Std registry slices | `li-std-core`, `li-std-math`, … | Roadmap convention — imports may differ |
| **Applications** | `studio-app` | Runnable editor + demo — **no** `import studio-app` |

See [studio-naming.md](studio-naming.md) for brand vs **`studio-app`** product repo.

---

## Monorepo vs published mirror

| Where | Path / name today | Published target |
|-------|-------------------|------------------|
| `lic` integration | `packages/studio/` | Repo **`studio`** |
| `lic` integration | `packages/studio.ai/` | Repo **`studio.ai`** |
| `lic` integration | `packages/world/` | Repo **`world`** |

`li.toml` should converge:

```toml
[package]
name = "studio"

[package.metadata.li]
import_name = "studio"
github_repo = "studio"
```

---

## Migration (tracking)

- [x] `import_repo_names.py` — repo slug = import path
- [x] `align-package-repo-names.py --metadata-only --apply` — `li.toml` + `PUBLISH.md`
- [x] `align-package-repo-names.py --apply` — rename `packages/<import>/`
- [ ] `push-import-aligned-mirrors.sh --create` — org repos on GitHub (maintainer)
- [ ] Register in roadmap **official-packages**

**World Studio import table:** [world-studio-packages.md](world-studio-packages.md)
