# Studio naming — brand vs app vs packages

**Package repos** follow [package-import-naming.md](package-import-naming.md) — repo name = import path.

---

## Four layers

| Layer | Name | GitHub repo | In code |
|-------|------|-------------|---------|
| **Brand** | Li World Studio | — | — |
| **Application** (editor, demo) | Studio app | **`studio-app`** | binary `studio-app` — **not imported** |
| **Package** | studio | **`studio`** | `import studio` |
| **Submodule** | studio.ai | **`studio.ai`** | `import studio.ai` |
| **Package** | world | **`world`** | `import world` — ECS, not the editor |

**Mnemonic:** **`studio`** = import · **`studio-app`** = product you run · **`studio.ai`** = agent submodule.

---

## Deprecated slugs

| Avoid | Use |
|-------|-----|
| `li-world-studio`, `li-studio-app` confusion with `li-studio` prefix on packages | App: **`studio-app`** · package: **`studio`** |
| `li-studio`, `li-studio-ai` as **published** names | **`studio`**, **`studio.ai`** |
| Demos in `lic/deploy/` | **`studio-app/demo/`** |

---

## Sibling layout

```text
lic/           # compiler
studio-app/    # application (demo, mocks, native shell)
studio/        # import studio
studio.ai/     # import studio.ai
world/         # import world
ui/
gui/
```

```bash
./scripts/bootstrap-li-studio-app-repo.sh ../studio-app
```

See [li-studio-repos.md](li-studio-repos.md).
