# Studio naming — brand vs repos vs packages

**Problem:** `li-world-studio` vs `li-studio` sounds like the same thing. **`li-world`** is already the ECS package — “world” in a product repo name adds noise.

**Status:** Canonical naming (2026-05). Supersedes `li-world-studio` as a repo slug.

---

## Three layers (use the right word)

| Layer | Name | GitHub repo | Li import / binary |
|-------|------|-------------|-------------------|
| **Brand** (what users say) | **Li World Studio** | — | — |
| **Application** (editor you open) | **Studio app** | **`li-studio-app`** | binary: `studio-app` (was `world-studio`) |
| **Library** (shell API in code) | **studio package** | **`li-studio`** | `import studio` |
| **Agent library** | **studio.ai** | **`li-studio-ai`** | `import studio.ai` |
| **World simulation** | **world package** | **`li-world`** | `import world` — **not** the editor |

**Mnemonic:** **`li-studio`** = code you import · **`li-studio-app`** = repo you clone to run mocks and ship the editor.

---

## Deprecated → use instead

| Avoid (confusing) | Use |
|-------------------|-----|
| `li-world-studio` (repo) | **`li-studio-app`** |
| “the studio repo” (ambiguous) | **`li-studio-app`** or **`li-studio`** — pick one |
| `world-studio` (binary target) | **`studio-app`** |
| Putting demos in `lic/deploy/` | **`li-studio-app/demo/`** |

---

## Sibling folder layout

```text
~/li-langverse/
  lic/              # compiler only
  li-studio-app/    # ← product: demo/, mockups, UX docs, native app
  li-studio/        # ← package mirror: import studio
  li-studio-ai/
  li-world/         # ← ECS / realms (not the editor)
  li-ui/
  li-gui/
```

---

## Env vars

```bash
export LIC_ROOT=../lic
export STUDIO_APP_ROOT=../li-studio-app   # not LI_WORLD_STUDIO_ROOT
```

---

## Bootstrap app repo from lic

```bash
./scripts/bootstrap-li-studio-app-repo.sh ../li-studio-app
```

See [li-studio-repos.md](li-studio-repos.md) for full repo map.
