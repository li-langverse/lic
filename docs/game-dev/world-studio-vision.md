# Li World Studio — AI-first game authoring vision

**Status:** Vision / master plan (not shipped)  
**Audience:** Architects, agents, contributors planning modules above Unity/Unreal-class tooling  
**Related:** [GAME_DEV.md](../physics/GAME_DEV.md), [SIMULATION_UI_READINESS.md](../physics/SIMULATION_UI_READINESS.md), [philosophy.md](../language/philosophy.md), [master plan](../superpowers/plans/2026-05-14-li-master-plan.md)

---

## 1. One-sentence vision

**Li World Studio** is an **agent-native, provably correct world builder**: you describe a world in prose (or sketch it), **local models** propose layouts and assets, **Li physics + scene graph** simulate it with contracts, and the **editor GUI** stays as simple as Python to read — while going **beyond** classic engines by making proof, replay, and AI iteration first-class, not bolted on.

“Above Unity/Unreal” does **not** mean “more features on day one.” It means:

| Classic engine default | Li World Studio default |
|------------------------|-------------------------|
| C#/C++ gameplay + hidden physics | **Li `proc`s with `requires`/`ensures`** on game + sim step |
| Editor state = opaque binary | **World = versioned, diffable Li + assets** (agents can patch) |
| AI = marketplace plugins | **AI = first workflow** (local LLM/VLM, structured tool calls) |
| Determinism optional | **Deterministic sim tier** + recorded seeds for regression |
| Asset pipeline external | **Generate → prove bounds → hot-reload** in one loop |

Rendering may still delegate to **GPU backends** (Vulkan/Metal/WebGPU) in early phases; the differentiator is **authoring + simulation + proof + agents**, not a from-scratch rasterizer on day one.

---

## 2. Design north star (AI-first)

1. **Prompt → structured world** — NL/sketch/audio in; **schema-valid** scene + physics + narrative graph out (never raw binary-only).
2. **Local-first models** — Ollama/llama.cpp/MLX-class runners; optional cloud with explicit `raises Net` and audit trail.
3. **Agents are users** — Every editor action has a **stable API** (`world.create_biome`, `entity.place`, `physics.set_tier`) so Cursor/CLI/automation == human menus.
4. **Prove what matters** — Game rules and sim invariants (`energy_drift`, `no_interpenetration` stubs → full) gate `lic build` before publish.
5. **Read like prose** — Modules `world`, `scene`, `physics.*`, `studio.ui`; see [philosophy.md](../language/philosophy.md).

---

## 3. Current Li baseline (2026)

What exists today (stubs → integratable):

| Layer | Package / path | Maturity |
|-------|----------------|----------|
| Math | `li-math` | Vec3, Quat, Mat4, AABB — **expand** |
| Numerics | `li-math-numerics` | Integrators — **expand** |
| Physics domains | `li-physics-*` | Tier-2 benches, partial runtime — **expand** |
| Physics runtime | `li-physics-runtime` | Single-body step, scene hooks — **expand** |
| Scene | `li-scene` | EntityId, Transform3, graph hooks — **expand** |
| UI | `li-ui` | 2D frame/input stubs — **replace/expand** with studio |
| I/O | `std/io`, `std/csv` | PH-IO-4 stubs — **implement** |
| Compiler | `lic` | Proof gate, MIR, LLVM — **extend** for hot reload / plugins |
| Agents | `li-httpd`, `lis`, benchmarks agent-kit | Gateway — **wire** to studio API |
| Game sample | `examples/tetris/` | Proof pattern — **template** for `game_step` |

**Gap:** No viewport, no asset DB, no terrain, no AI tool schema, no undo graph, no build/player packaging.

---

## 4. State of the art (what we replicate and beat)

### 4.1 Traditional engines (baseline to exceed on *workflow*)

| Product | Strength | Weakness for AI/proof |
|---------|----------|------------------------|
| **Unity 6** | Ecosystem, UGUI, Asset Store, DOTS emerging | Opaque scenes; AI tools fragmented; no proof |
| **Unreal 5** | Nanite/Lumen, Blueprints, World Partition | Heavy; C++ complexity; agent-hostile binary assets |
| **Godot 4** | Open, GDScript, lightweight | Smaller AAA path; same opaque scene tree |
| **Bevy** (Rust) | ECS, data-oriented | No proof; AI still external |

**Li beat condition:** Same *authoring speed* via AI, plus **exportable Li source** for rules/sim and **CI proof** on worlds.

### 4.2 AI world & asset generation (replicate pipelines)

| Area | SOTA examples | Li integration |
|------|---------------|----------------|
| Text → 3D mesh | Meshy, Tripo, Rodin, SF3D | `studio.gen.mesh` → glTF + collision proxy |
| Text → layout | Promethean AI (layout), SceneCraft | `studio.gen.layout` → `Scene` + constraints |
| Image → 3D | InstantMesh, Trellis, SF3D | `studio.gen.from_image` |
| Gaussian / NeRF worlds | Nerfstudio, 3DGS flythrough | `studio.render.splat` preview; bake to mesh for physics |
| Text → world (research) | LatticeWorld, HY-World 2.0, NeoWorld | **Target:** Li-native world graph + UE-quality preview optional |
| NPC / dialog AI | Inworld, Convai | `studio.ai.character` with local LLM + `requires` policy |
| Code gen | Copilot, Cursor | **Native:** Li game logic gen with `lic build` loop |

### 4.3 Authoring GUIs (UX target)

| Product | Pattern to steal |
|---------|------------------|
| **Unreal Editor** | Viewport, outliner, details, content browser |
| **Unity** | Inspector, play mode, prefabs |
| **Blender** | Modifiers stack, non-destructive history |
| **Roblox Studio** | Simple part tree, instant play |
| **Dreams / S&box** | In-engine creative loop |

**Li simplification:** Fewer panels; **command palette + agent chat** as primary; expert panels optional.

### 4.4 Local models (2026 practical stack)

| Role | Typical local stack | Studio module |
|------|---------------------|---------------|
| Layout / DSL | Llama 3.x 8B–70B, Qwen2.5, Mistral | `studio.llm.local` |
| Vision / sketch | LLaVA, Qwen-VL, Florence | `studio.vlm.local` |
| Mesh / texture | SDXL, Flux (local), specialized checkpoints | `studio.diffusion.local` |
| Embeddings / search | nomic-embed, bge | `studio.rag.assets` |
| Speech (optional) | Whisper.cpp | `studio.audio.transcribe` |

**Principle:** Default **offline**; cloud is opt-in with typed consent in project `li.toml`.

---

## 5. Target architecture

```text
┌─────────────────────────────────────────────────────────────────┐
│  Studio shell (li-studio) — viewport, panels, command palette    │
│  studio.ui · studio.commands · studio.undo                      │
├─────────────────────────────────────────────────────────────────┤
│  AI orchestration (li-studio-ai)                                 │
│  tool schema · local_llm · rag · plan/apply/verify loop          │
├─────────────────────────────────────────────────────────────────┤
│  World model (li-world) — biomes, layers, narrative, rules       │
│  world.* · import scene · import physics.runtime                 │
├─────────────────────────────────────────────────────────────────┤
│  Scene + assets (expand li-scene, new li-assets)                 │
│  entities · prefabs · glTF/USD ingest · LOD                      │
├─────────────────────────────────────────────────────────────────┤
│  Simulation (expand li-physics-*)                                │
│  rigid · particles · fluids · cloth · provenance tier            │
├─────────────────────────────────────────────────────────────────┤
│  Render bridge (li-render — Phase R)                             │
│  WebGPU/Vulkan backend · draw lists from scene                   │
├─────────────────────────────────────────────────────────────────┤
│  Player / publish (li-player)                                    │
│  lic build → proved binary + asset bundle                        │
└─────────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │ lic build (proof)            │ agent API (HTTP/stdio)
         │                              │
    li-langverse/lic              lis / li-httpd / Cursor
```

**World file (conceptual):** `world.li` + `assets/` + `studio.toml` — all text-first for agents.

---

## 6. Module plan — NEW packages

| Import | GitHub repo | Purpose | Phase |
|--------|-------------|---------|-------|
| `studio` | `li-studio` | Editor shell, play mode, project model | GD-1 |
| `studio.ui` | (in studio) | Panels, docking, theme, input routing | GD-1 |
| `studio.commands` | (in studio) | Undo/redo, macro recording, agent verbs | GD-1 |
| `world` | `li-world` | Biome, terrain graph, spawn rules, metadata | GD-2 |
| `world.gen` | (in world) | Procedural + AI layout application | GD-2 |
| `assets` | `li-assets` | glTF/USD/PNG ingest, IDs, deps | GD-2 |
| `studio.ai` | `li-studio-ai` | Tool schema, local model runners, RAG | GD-3 |
| `render` | `li-render` | Draw list, materials, camera (backend FFI) | GD-4 |
| `player` | `li-player` | Ship proved builds, fullscreen run | GD-4 |
| `studio.net` | optional | Cloud model bridge (`raises Net`) | GD-5 |

**Repo naming:** follows [repo-naming.md](../ecosystem/repo-naming.md) (`import world` → `li-world`).

---

## 7. Module plan — EXPAND existing

| Module | Today | Expand to |
|--------|-------|-----------|
| `li-ui` | 2D Color/Rect/Input | **Studio chrome**: panels, widgets, layout, accessibility |
| `li-scene` | Flat node list hooks | **Full graph**: parent/child, prefab, tags, layers |
| `li-physics-runtime` | 1 body, substep | **N-body**, broadphase, scene sync both ways |
| `li-physics-rigid` | AABB/sphere stub | PGS/sequential impulse, joints, character controller |
| `li-physics-particles` | Basic | GPU-friendly SOA, emitters |
| `li-physics-fluids` | Tier-2 kernels | Game-scale SPH heightfield |
| `li-math` | Vec/Mat | Frustum, raycast, spline paths for camera/tools |
| `std/io` | Stub | Watch folders, async read for assets |
| `std/csv` | Stub | Telemetry + bench ingest for studio perf |
| `lic` | Batch compile | **Hot reload** slice (game logic), incremental VC cache |
| `li-httpd` | Gateway | **Studio agent API**: `POST /world/apply_patch` |

---

## 8. AI-first workflows (concrete)

### 8.1 Create world from text (local)

```text
User: "Coastal village at dusk, low poly, physics-safe props"
  → studio.ai.plan (local LLM, JSON schema)
  → world.gen.apply_layout(plan)
  → assets.resolve_or_generate(mesh prompts)
  → physics.validate_static_colliders
  → lic build (world rules + sim contracts)
  → viewport preview
```

**Improve vs SOTA:** Plan is **Li source + scene graph**, not only Unreal `.umap` — agent can `git diff` it.

### 8.2 Sketch → layout (local VLM)

- Tablet layer → `studio.vlm` → extruded zones (water, road, buildable).
- Zones map to `world.layers` with proved bounds (`requires area > 0`).

### 8.3 Iterate with proof

```li
proc game_step(world: GameWorld, input: InputState) -> unit
  requires world.time >= 0.0
  ensures player_alive(world) or world.game_over
  decreases world.tick_budget
=
  studio_poll_input(input)
  physics_step(world.physics, world.dt)
  world.tick_budget = world.tick_budget - 1
```

Failed proof → agent gets **structured diagnostic** (not a crash in play mode).

### 8.4 Regression for worlds

- **World seed + asset manifest hash** → deterministic physics tier-0 replay.
- CI: `lic build` + `studio.test.snapshot(world)` in `li-tests/game_dev/`.

---

## 9. Phased roadmap (PH-GD)

| Phase | ID | Deliverable | Proof / bench |
|-------|-----|-------------|---------------|
| **0** | PH-GD-0 | Vision doc (this), issue tree, agent API sketch | — |
| **1** | PH-GD-1 | **Studio MVP**: viewport stub, outliner, inspector, play/pause, `studio.commands` undo | `li-tests/game_dev/studio_smoke.li` |
| **2** | PH-GD-2 | **World model**: `li-world`, terrain heightfield, entity placement, save/load text | Tier-0: save/load roundtrip |
| **3** | PH-GD-3 | **AI loop**: `li-studio-ai`, Ollama tool calls, apply_patch, `lic check` in loop | Agent integration test vs golden world |
| **4** | PH-GD-4 | **Assets**: glTF ingest, collision proxies, `studio.gen` mesh hook | Import + physics sleep stack bench |
| **5** | PH-GD-5 | **Render**: `li-render` draw list, PBR-lite, scene sync | Frame time bench (no proof on GPU) |
| **6** | PH-GD-6 | **Scale**: fluids/particles in editor, World Partition–style streaming | Tier-2 benches green |
| **7** | PH-GD-7 | **Publish**: `li-player`, proved game packages | Tetris-class + mini open world demo |

**Dependency order:** PH-GD-1 blocks on `li-scene` graph + `li-ui` panels; PH-GD-3 blocks on `lis` agent protocol; PH-GD-5 can parallelize with physics expand.

---

## 10. Replication + improvement matrix

| Capability | Industry SOTA | Li plan | Improve how |
|------------|---------------|---------|-------------|
| Scene hierarchy | Unity/UE outliner | `li-scene` graph + text export | Git-diffable; agent patchable |
| World partition | UE5 streaming | `world.streaming` grid | Prove load bounds; no silent unload |
| Physics | PhysX/Havok | `li-physics-*` | Provable invariants; tier picker |
| AI layout | Promethean / research | `world.gen` + local LLM | Build-verify loop with `lic` |
| 3D from text | Meshy/Tripo | `studio.gen.mesh` | Auto collision + LOD policy |
| NPC dialog | Inworld | `studio.ai.character` | Policy in `requires`; local model |
| Hot reload | Unity play mode | `lic` incremental | Only after VC cache safe |
| Networking | Netcode | **Later** GD-NET | Spec with proved sync subset |
| Visual fidelity | Lumen/Nanite | `li-render` + optional UE bridge | **Optional** export, not lock-in |

---

## 11. Technology choices (recommended)

| Concern | Recommendation | Rationale |
|---------|----------------|-----------|
| Viewport | **wgpu** or **SDL3 + Metal/Vulkan** via thin C (`li_rt`) | Cross-platform; keep proof out of GPU |
| UI framework | **Li-owned immediate mode** first (extend `li-ui`) | Agents read layout code; no XAML |
| Asset format | **glTF 2.0** primary, USD optional | Tooling everywhere |
| Local LLM | **Ollama API** + **llama.cpp** embed | De facto local standard |
| Tool protocol | **JSON schema** + MCP-compatible surface | Cursor/lis reuse |
| Scripting | **Li only** (no second language) | Single proof pipeline |

---

## 12. Compiler & runtime requirements

| Feature | Needed for | PH link |
|---------|------------|---------|
| Package `import` graph | Studio modules call physics | Import resolver (lic#57) |
| Dynamic library hot reload | Play mode code tweak | Compiler RFC |
| `extern` GPU / audio | Render bridge | Trusted C audit |
| `@physics(tier=…)` elaboration | One-click sim quality | PHY-n policy |
| `watch` on `std/io` | Asset hot reload | PH-IO-4 |

---

## 13. Risks and mitigations

| Risk | Mitigation |
|------|------------|
| Scope = build UE5 | **Render bridge** + prove sim; delegate AAA graphics optionally |
| Local models too weak | Hybrid cloud tier; small models for DSL, big for one-shot gen |
| Proof too slow for interact | `lic check` in editor; full `lic build` on save/publish |
| Agent runaway edits | `studio.commands` undo + max patch size + human approve gate |

---

## 14. Success metrics

| Metric | Target (GD-7) |
|--------|-----------------|
| Text → playable stub world | < 5 min on M-series laptop (local 8B) |
| Agent patch → green `lic check` | > 80% on curated benchmark prompts |
| Physics tier-2 | All game-adjacent benches ≤ 1.2× C++ |
| World project size | 10⁴ entities, streaming on |
| User readability | New author understands `world.li` in < 10 min |

---

## 15. Immediate next actions (org)

1. **Roadmap:** Add PH-GD-0…7 to master plan tracker (proposal in `roadmap` repo).  
2. **Issues:** Epic `world-studio` with GD-1 subtasks (scene graph, studio shell).  
3. **Package:** Scaffold `li-studio` with `--import-name studio`.  
4. **Agent API:** Draft OpenAPI for `world.apply_patch` in `lis`.  
5. **Do not** merge scope into `li-demo` (automation sandbox per org rule).

---

## 16. Related links

- [GAME_DEV.md](../physics/GAME_DEV.md) — current physics integration  
- [SIMULATION_UI_READINESS.md](../physics/SIMULATION_UI_READINESS.md) — shipped stubs  
- [import-style.md](../language/import-style.md) — module naming  
- [composable-by-default.md](../ecosystem/composable-by-default.md) — APIs not monoliths  
- [li-httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) — agent gateway  

**Maintainers:** Update this doc when PH-GD phases ship or SOTA shifts (quarterly review).
