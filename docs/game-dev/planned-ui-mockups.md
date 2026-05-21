# Planned UI mockups (concept art)

Visual targets for **Li World Studio** native shell — generated from [unified-studio-ux-vision.md](unified-studio-ux-vision.md) and competitive material study.

**Files (in repo):** `lic/deploy/studio-demo/mockups/`

---

## 1. Game / viewport workspace

![Game viewport mockup](../../deploy/studio-demo/mockups/li-studio-viewport-game.png)

- Outliner + **3D viewport** + inspector  
- Toolbar: workspace, profile, **gate PASS**, Play, Agent, ⌘K, Publish  
- Bottom: timeline + **agent transcript**  
- Status overlay: fps + bench OK  

**Maps to:** G3 Studio shell · `engine.profile = game`

---

## 2. Cinematic — 4-panel NLE

![Cinematic NLE mockup](../../deploy/studio-demo/mockups/li-studio-cinematic-nle.png)

- **Media bin** · **Preview** · **Timeline** · **Inspector** (CapCut/DaVinci pattern)  
- Export presets: 1080p30, 9:16, 4K + **repro hash**  
- Workspace: Cinematic  

**Maps to:** G7 `li-seq` · `studio.publish_video`

---

## 3. Infinite agentic canvas

![Agentic canvas mockup](../../deploy/studio-demo/mockups/li-studio-agentic-canvas.png)

- Spatial graph: `world.li`, `Sequence`, `gui`, `sim`, **AgentPlan**  
- Node status colors (pass / building)  
- Links: Spawns, Compiles, Validates  
- Default for drug/bio + agent-heavy sessions  

**Maps to:** G5 `gui.canvas` · [li-canvas-agentic-rfc](specs/li-canvas-agentic-rfc.md)

---

## 4. Scientific simulation

![Scientific sim mockup](../../deploy/studio-demo/mockups/li-studio-scientific-sim.png)

- Field viewport (heat map)  
- Inspector: **Params | Validity | Info**  
- Validity green: `heat_equation_2d`, drift, oracle name  
- Bottom: bench runs table  

**Maps to:** `sim_scientific` · tier-2 validity chrome

---

## 5. Agent dock (v2 — hero chat)

![Agent chat v2 mockup](../../deploy/studio-demo/mockups/li-studio-agent-chat-v2.png)

- **Right rail = Agent first** (380px) — not a footnote in inspector  
- **Chat bubbles** — user / agent / system roles + timestamps  
- **Plan card** — steps before apply (Roblox Assistant / Cursor class)  
- **Gate inline** — `lic build · PASS` inside transcript + top chip  
- **Apply / Reject** — human-in-the-loop after diagnose  
- **Composer** — `/build` `/bench` `/patch` hint chips  

**Live prototype:** `deploy/studio-demo/` — open in browser; agent dock matches this mock.

**Maps to:** G3 `dock.agent` · [studio-ux-design-system-rfc](specs/studio-ux-design-system-rfc.md) `ui_layout_agent_first`

---

## Design tokens (v2 target)

| Token | Value |
|-------|--------|
| `--bg-deep` | `#0f1219` |
| `--bg-surface` | `#161b26` |
| `--bg-elevated` | `#1c2233` |
| `--accent-agent` | `#2dd4bf` (teal — not violet) |
| `--accent-workspace` | `#5b9cf5` |
| `--pass` | `#34d399` |
| `--fail` | `#f87171` |
| Typography | IBM Plex Sans / Mono · 12–13px chrome |

Formalize in `specs/studio-ux-design-system-rfc.md` when native `li-ui` paint lands.

---

## Not shown (future mocks)

- AM / slicer plater + 3-step export wizard  
- LITL / bio adaptive stage strip  
- GUI theme editor (Roblox Style Editor class)  
- Publish drawer full layout  

Request additional mocks in `#ph-ux` when a workspace is ready to implement.
