# Li Studio — repository map

**Naming:** [studio-naming.md](studio-naming.md) — **`li-studio-app`** (editor) vs **`li-studio`** (package).  
**`lic` boundary:** [.cursor/rules/lic-compiler-repo-boundary.mdc](../../.cursor/rules/lic-compiler-repo-boundary.mdc)

---

## Repo map

| Repo | Role | Owns |
|------|------|------|
| **[lic](https://github.com/li-langverse/lic)** | Toolchain | Compiler, `std`, `lic build`, composable harness |
| **[li-studio-app](https://github.com/li-langverse/li-studio-app)** *(create)* | **Application** | `demo/`, mockups, video, UX docs, native **`studio-app`** target |
| **[li-studio](https://github.com/li-langverse/li-studio)** | **Package** | `import studio` — shell, play, publish, commands |
| **[li-studio-ai](https://github.com/li-langverse/li-studio-ai)** | **Package** | `import studio.ai` — diagnose, patch |
| **[li-ui](https://github.com/li-langverse/li-ui)** | **Package** | Layouts, `ui_cmd_*`, transcript types |
| **[li-gui](https://github.com/li-langverse/li-gui)** | **Package** | Native widgets |
| **[li-world](https://github.com/li-langverse/li-world)** | **Package** | ECS / `GameWorld` — **not** the editor app |
| **li-render**, **li-sim**, … | Engine | See [world-studio-packages.md](world-studio-packages.md) |

```text
li-studio-app          # product repo (clone this for UX)
  └── depends on → li-studio, li-studio-ai, li-ui, li-gui, li-world, …
  └── built with   → lic (sibling)
```

---

## Migrate out of `lic`

| From `lic` | To `li-studio-app` |
|------------|---------------------|
| `deploy/studio-demo/` | `demo/` |
| Studio record/open scripts | `scripts/` |
| UX docs (`planned-ui-mockups`, …) | `docs/` |

Do **not** recreate `lic/deploy/studio-demo` after migration.

---

## Bootstrap

```bash
cd lic
./scripts/bootstrap-li-studio-app-repo.sh ../li-studio-app
cd ../li-studio-app && git init && git add . && git commit -m "chore: bootstrap"
# gh repo create li-langverse/li-studio-app --source=. --push
```

---

## Where to work

| Task | Repo |
|------|------|
| Mockups, HTML demo, WebM | **li-studio-app** |
| `studio.*` API | **li-studio** |
| `studio.ai` | **li-studio-ai** |
| Compiler / gates | **lic** |

---

## Tracking

- [ ] Create **`li-langverse/li-studio-app`** (not `li-world-studio`)
- [ ] Retire `li-world-studio` name in docs/issues
- [ ] Binary rename `world-studio` → `studio-app` when native target lands
