# Planned UI mockups

**Canonical preview:** the **interactive HTML prototype** — not PNG files in git.

```bash
cd lic
./scripts/open-studio-design-preview.sh
```

Optional **local PNG gallery** (gitignored under `.artifacts/studio-mockups/`):

```bash
./scripts/capture-studio-mockup-screenshots.sh
./scripts/open-studio-design-preview.sh --gallery
```

**Path:** `deploy/studio-demo/index.html` · **Product home (target):** `studio-app/demo/`

---

## Design intent (all workspaces)

| Workspace | Tab (`?demo=`) | Chrome |
|-----------|----------------|--------|
| **Game** | `rocket` | Outliner · 3D viewport · **agent dock** (teal) · `lic build · PASS` |
| **Scientific** | `scientific` | Heat field · validity · agent + bench |
| **Agent** | `agent` | Diagnose / patch focus |
| **Publish** | `publish` | Figures · PublishBundle hash |
| **Cinematic** | *(future native)* | 4-panel NLE — not in HTML tab yet |
| **Canvas** | *(future G5)* | Spatial graph — use agent tab + [li-canvas-agentic-rfc](specs/li-canvas-agentic-rfc.md) |

---

## Tokens (v4 — theme picker in prototype)

Three palettes via `data-theme` on `<html>` (top bar swatches):

| Theme | Use | Agent accent | Gate OK (`lic build · PASS`) |
|-------|-----|--------------|------------------------------|
| **aurora** (default) | Balanced studio | `#9eb8ff` periwinkle | `#c9b066` champagne gold |
| **ember** | Gaming / warm | `#ffb86c` amber | `#d4af37` engine gold (not UE `#FFE000`) |
| **slate** | Scientific / pro | `#8ec8ff` sky | `#9ec5e8` frost blue |

No mint/teal “success green”. **Warn** stays orange (`--warn`) so it never clashes with pass gold.

Shared surfaces (aurora): `--bg-deep` `#0b0d12`, `--bg-surface` `#12151c`, `--accent` `#7c9cff`

See `deploy/studio-demo/studio.css` and [studio-ux-design-system-rfc](specs/studio-ux-design-system-rfc.md).

---

## Why no images in repo

- Keeps **`lic`** compiler-focused ([lic-compiler-repo-boundary.mdc](../../.cursor/rules/lic-compiler-repo-boundary.mdc))
- Screenshots drift from the prototype; **HTML is source of truth**
- Share visuals via local capture, CI artifact, or `studio-app` release — not committed PNGs

**Maps to:** G3 `dock.agent` · `ui_layout_agent_first` · packages `studio`, `studio.ai`
