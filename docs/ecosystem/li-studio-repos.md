# Li Studio — repository map (target layout)

**Status:** Canonical org layout (2026-05)  
**Problem today:** World Studio **implementation** and **demo assets** live in the **`lic`** monorepo (`packages/li-studio`, `deploy/studio-demo`). Package READMEs already point at **separate GitHub repos** that should own the same code.

**Goal:** Humans and agents open **`li-world-studio`** for the app + mocks + video; open **`li-studio`** / **`li-studio-ai`** for libraries; keep **`lic`** as compiler, std, and integration harness.

---

## Repo map

| Repo | Owns | Does *not* own |
|------|------|----------------|
| **[li-langverse/lic](https://github.com/li-langverse/lic)** | Compiler, `lic build`, std, tier-2 benches, monorepo integration | Shipped Studio binary, marketing demo (migrate out) |
| **[li-langverse/li-studio](https://github.com/li-langverse/li-studio)** | `studio` package — shell, play mode, publish, `studio_command_execute` | Full desktop app wiring (→ world-studio) |
| **[li-langverse/li-studio-ai](https://github.com/li-langverse/li-studio-ai)** | `studio.ai` — diagnose, patch, agent gate | MCP host UI (→ world-studio or li-cursor-agents) |
| **[li-langverse/li-ui](https://github.com/li-langverse/li-ui)** | `ui` — layouts, `ui_cmd_*`, agent transcript types | Native paint (→ li-gui) |
| **[li-langverse/li-gui](https://github.com/li-langverse/li-gui)** | Native widgets / present path | — |
| **[li-langverse/li-world-studio](https://github.com/li-langverse/li-world-studio)** *(create)* | **Product repo:** `deploy/demo`, mockups, demo video, UX docs, `world-studio` app target, record scripts | Language/compiler |
| **li-render**, **li-world**, **li-sim**, … | Engine verticals (already listed in [world-studio-packages.md](world-studio-packages.md)) | Studio chrome |

**Sibling clone layout (recommended):**

```text
~/li-langverse/
  lic/                 # compiler + integration
  li-world-studio/     # app + demo + mocks  ← you open this for UX review
  li-studio/
  li-studio-ai/
  li-ui/
  li-gui/
  li-render/
  li-world/
  benchmarks/
```

---

## What moves out of `lic/deploy/`

| From `lic` | To `li-world-studio` |
|------------|-------------------------|
| `deploy/studio-demo/` | `demo/` (or `deploy/demo/`) |
| `scripts/record-studio-demo.sh`, `studio-demo-capture.mjs`, `gen-studio-demo-status.sh`, `open-studio-demo.sh` | `scripts/` |
| `docs/game-dev/planned-ui-mockups.md`, `demo-showcase.md`, `unified-studio-ux-vision.md`, UX RFCs | `docs/` (subset) |

Leave **stubs** in `lic` that link to `li-world-studio` (no duplicate canonical mocks).

---

## What moves out of `lic/packages/`

Each package under `lic/packages/li-studio*` has **PUBLISH.md** → `https://github.com/li-langverse/li-studio`. Extraction options:

1. **git subtree split** (one-time): `packages/li-studio` → `li-studio` repo root  
2. **Manual sync script** (until split): `./scripts/sync-package-repo.sh li-studio`  
3. **Monorepo stays source of truth** until registry phase — but **demo/UX never returns to `lic/deploy`**

`lic` keeps **composable smokes** that depend on vendored copies or `LIC_ROOT` + cloned siblings.

---

## Dependencies

```text
li-world-studio (app)
  ├── li-studio, li-studio-ai, li-ui, li-gui  (packages)
  ├── li-render, li-world, li-sim, …          (engine)
  └── lic                                     (build tool — PATH or sibling)
```

Env:

```bash
export LIC_ROOT=../lic
export LI_STUDIO_ROOT=../li-world-studio
```

---

## Bootstrap a new `li-world-studio` clone

From **`lic`** on branch `feat/agent-first-gui` (or `main` after merge):

```bash
./scripts/bootstrap-li-world-studio-repo.sh ../li-world-studio
cd ../li-world-studio
git init && git add . && git commit -m "chore: bootstrap from lic"
# gh repo create li-langverse/li-world-studio --private --source=. --push
```

---

## Agent / Cursor rule of thumb

| Task | Open repo |
|------|-----------|
| UX mockups, demo video, HTML prototype | **li-world-studio** |
| `studio.*` / `studio.ai` API | **li-studio** / **li-studio-ai** |
| Composable gates, physics kernels | **lic** |
| Benchmarks dashboard | **benchmarks** |

---

## Tracking

- [ ] Create GitHub repo `li-langverse/li-world-studio`  
- [ ] Run bootstrap script; verify `demo/preview.html`  
- [ ] Split `li-studio` + `li-studio-ai` package mirrors  
- [ ] Replace `lic/deploy/studio-demo` with README pointer  
- [ ] Register repos in roadmap **official-packages**

See [world-studio-packages.md](world-studio-packages.md) · [studio-ux-design-system-rfc](../game-dev/specs/studio-ux-design-system-rfc.md).
