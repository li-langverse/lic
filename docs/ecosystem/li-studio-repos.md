# Studio & engine — repository map

**Imports:** [package-import-naming.md](package-import-naming.md) — repo **`studio`**, not `li-studio`.  
**App vs package:** [studio-naming.md](studio-naming.md) — **`studio-app`** is the editor only.  
**`lic` boundary:** [lic-compiler-repo-boundary.mdc](../../.cursor/rules/lic-compiler-repo-boundary.mdc)

---

## Repos

| Repo | `import` | Role |
|------|----------|------|
| **lic** | — | Compiler, std, harness |
| **studio-app** | — | Application: demo/, mockups, native binary |
| **studio** | `studio` | Shell, play, publish |
| **studio.ai** | `studio.ai` | Diagnose, patch |
| **world** | `world` | ECS / GameWorld |
| **ui** | `ui` | Layouts, `ui_cmd_*` |
| **gui** | `gui` | Native widgets |
| **render**, **sim**, **sim.scientific**, … | same as import | [world-studio-packages.md](world-studio-packages.md) |

```text
studio-app  →  depends on studio, studio.ai, ui, gui, world, render, …
             →  built with lic
```

---

## Monorepo mirrors (`lic/packages/li-*`)

Integration copies under `lic/packages/studio/` are **temporary**; published org repos use **import names** (`studio`, `studio.ai`).

---

## Bootstrap application repo

```bash
./scripts/bootstrap-li-studio-app-repo.sh ../studio-app
```

---

## Where to work

| Task | Repo |
|------|------|
| UX / demo / video | **studio-app** |
| `import studio` API | **studio** |
| `import studio.ai` | **studio.ai** |
| `lic build` / gates | **lic** |
