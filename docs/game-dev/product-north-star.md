# Product north star — four killers, mathematically proven

**Status:** Canonical (2026-05)  
**Owner:** Product / PH-GD / PH-UX / PH-SIM  
**Related:** [world-studio-vision.md](world-studio-vision.md) · [unified-studio-ux-vision.md](unified-studio-ux-vision.md) · [philosophy.md](../language/philosophy.md)

---

## 1. The goal (one paragraph)

**Li World Studio** must deliver **killer UI/UX**, **killer performance**, and **killer results** — and every claim must be **mathematically provable** or **measurement-backed** in-repo, not keynote slides.

Proof is **not** “safe to play games” only. It covers **reliable engineering simulation**, **physics and numerics you can trust**, **deterministic replay**, and **publication-grade exports** — plus games and creator ship paths on the **same** engine and Studio loop.

Humans get AAA-grade chrome; agents get stable IDs and gates; **games, CFD-class proxies, MD, robotics, AM, and lab pipelines** share one **proof + bench + validity** spine.

---

## 2. Four killers + proof (non-negotiable)

```text
                    ┌─────────────────────────────────────┐
                    │     MATHEMATICALLY PROVEN (core)     │
                    │ lic · physics validity · numerics   │
                    └─────────────────┬───────────────────┘
          ┌───────────────────────────┼───────────────────────────┐
          ▼                           ▼                           ▼
   KILLER UI/UX              KILLER PERFORMANCE           KILLER RESULTS
   one shell, agents         timed kernels, 60 fps        correct outputs,
   ≤3 clicks                 tier-2 oracles               repro publish
```

| Pillar | User feels | We prove / measure | In-repo today (honest) |
|--------|------------|--------------------|-------------------------|
| **Killer UI/UX** | Fast, obvious, beautiful; agent “just works” | 60 fps chrome; &lt;100 ms workspace switch; WCAG AA; composable UI smokes | `li-ui` agent-first types; HTML demo; plan G0–G8 |
| **Killer performance** | Viewport and sim stay smooth at scale | `render_frame_present`, `world_engine`, `gaming_full`; ratio vs cpp; no regression in CI | Tier-2 timed rows + validity |
| **Killer results** | Sims, games, exports **match expectation** | Checksums, drift metrics, oracle refs (LJ, heat, …); publish **hash** | Bench catalog + `studio.publish` stub |
| **Mathematically proven** | “This build and this **sim run** are trustworthy” | `lic` contracts; physics/numeric **validity**; determinism tier; engineering gates | `lic` + tier-2 + composables |

**Rule:** No pillar stands alone. UI shows **gate + validity**; performance without validity is **invalid**; results without repro hash are **not shipped**; agents cannot skip **proof**. A fast wrong PDE is a **failure**, not a win.

---

## 3. Reliability scope — not just “safe to play”

| Domain | What “reliable” means | Proof / measurement |
|--------|----------------------|---------------------|
| **Games** | Deterministic tick, fair replication, shippable build | `lic build`, replay seed, `game_world_soa_*` validity |
| **Rigid / soft body** | Stable integrator, sane contacts | `sim_physics_frame`, energy/drift where defined |
| **Scientific / engineering** | Field evolution matches discrete oracle (heat, LJ, …) | Tier-2 row + **named SOTA proxy** + checksum/drift |
| **Custom / game physics** | Law mode explicit; no false conservation claims | `law_mode` realistic \| arbitrary \| hybrid; `physics.custom` |
| **Robotics / automotive** | Same step API as game; sensor replay | `sim.robotics`, `sim.automotive`, profile determinism |
| **Additive manufacturing** | Thermal/warp within tolerance before print | `require_sim_pass`, export audit (CRITICAL) |
| **Drug / bio / chem** | Stage outputs tied to pipeline hash | LITL/DBTL manifest + `li-chem` job refs |
| **Cinematic / publish** | Frame hash reproducible | `seq` + `studio.publish` bundle |

**One engine, many profiles** — [li-engine-unified-sim-rfc](specs/li-engine-unified-sim-rfc.md). Reliability is **profile-aware**, not game-only.

---

## 4. What “mathematically proven” means (precise)

| Layer | Mechanism | What we claim |
|-------|-----------|---------------|
| **Language** | `requires`, `ensures`, `decreases` on `def` | Local correctness of functions and APIs |
| **Build** | `lic build` / `lic check` | Project compiles; proof obligations discharged (where enabled) |
| **Integration** | Composable import smokes (`li-tests`) | Packages link; no silent ABI drift across sim profiles |
| **Physics semantics** | `law_mode`, `sim_step` vs `sim_step_arbitrary` | Realistic vs toy laws **explicit**; arbitrary laws don’t fake conservation |
| **Numerics** | Tier-2 **validity** (checksum, drift, energy, CFL-style guards where defined) | Discrete evolution **consistent** with reference — not “fast but wrong” |
| **Units & types** | Typed quantities in sim/chem APIs (roadmap) | Engineering hygiene — nm vs m, s vs ms caught before run |
| **Determinism** | `determinism_tier`, replay, `seq` frame hash | Same inputs → same observables (game tick, sim step, export frame) |
| **Engineering export** | `require_sim_pass`, AM audit, PH-PUB | No G-code / report / print without passing sim validity |
| **Publish** | PH-PUB bundle: sources + bench row + manifest hash | Third party can **reproduce** the figure, field plot, or export |

### 4.1 Physics & simulation trust (engineering-grade)

What users expect from COMSOL/ANSYS/OpenFOAM-class tools — what we implement **honestly**:

| Expectation | Li mechanism | Honest today |
|-------------|--------------|--------------|
| Correct discrete scheme for a **named** problem | Oracle rows (`heat_equation_2d`, `md_lennard_jones`, …) | Tier-2 proxies, not full NS FEA |
| Stability over long horizons | Drift / energy metrics in validity | Per-bench; expand with profile |
| Boundary conditions & ICs in source | `world.li` / sim profile config (diffable) | Stubs → full inspector |
| No silent integrator swap | One `sim.step` family per profile | `physics.runtime` wiring in progress |
| Report for paper / compliance | PH-PUB + bench CSV + hash | Publish stub |

**Anti-goal:** Marketing “engineering simulation” without a **green validity row** for that workload class.

**What we do not claim without evidence:**

- “Proved faster than UE5” → need `ue-baselines.csv` + same workload  
- “Proved CFD equals OpenFOAM” → need field oracle + mesh study + validity column  
- “Certified for aviation/medical sign-off” → out of scope until compliance program says so  
- “Proved secure” → CRITICAL package audit path ([compliance RFC](specs/critical-package-compliance-rfc.md))

**UI copy:** **“build passed”** · **“validity green (heat_2d / LJ / …)”** · **“drift ≤ ε”** · **“repro id `…`”** — never “trust me, it looks right in the viewport.”

---

## 5. Killer UI/UX (provable surface)

| UX target | Metric | Proof hook |
|-----------|--------|------------|
| Viewport / canvas | ≥60 fps pan/zoom | `render_frame_present` bench + validity |
| Workspace switch | &lt;100 ms | Studio perf smoke (native G2+) |
| Primary flows | ≤3 clicks | UX checklist per profile |
| Agent patch | Visible gate &lt;2 s local | `lic check` on every `UiAgentAction` |
| Trust | Gate chip always on | Failed build **blocks** play, **sim run**, and export |
| Engineering | Validity + units in inspector | Field legend, drift line, oracle name on bench panel |

**Vision:** [unified-studio-ux-vision.md](unified-studio-ux-vision.md)  
**Build:** [li-native-gui-plan.md](plans/li-native-gui-plan.md) G0–G8

**Differentiator:** Roblox/Figma-level UX **plus** gate chip and validity badge — they don’t show **why** run is trusted.

---

## 6. Killer performance (provable speed)

| Workload class | Bench home | Validity |
|----------------|------------|----------|
| World / replication | `gaming_full`, `world_engine` | Row checksum / invariants |
| Physics step | `sim_physics_frame`, tier2 physics | Energy/drift where defined |
| Present / compositor | `render_frame_present` | Frame hash / timing envelope |
| Scientific proxies | `heat_equation_2d`, `md_lennard_jones`, fluids v0 | Named SOTA proxy in registry |

**Policies:**

- Report **ratio vs cpp** (or documented baseline) on same commit SHA  
- **No speed claim** on rows without green validity  
- Regressions fail CI when ratio crosses threshold (dashboard policy)

**Differentiator:** Keynotes show FPS; we show **FPS + validity.json + commit**.

---

## 7. Killer results (provable outcomes)

| Outcome | User action | Proof artifact |
|---------|-------------|----------------|
| Game build runs | ▶ Play | `lic build` ok + replay seed |
| **Engineering sim** | Run `sim_scientific` / tier-2 bench | CSV + **validity** + oracle name (e.g. OpenFOAM-class heat, GROMACS-class LJ) |
| **Physics frame** | `sim_step` / robotics cell | `sim_physics_frame` validity; determinism tier |
| **Custom laws** | Arbitrary / hybrid mode | `law_mode` logged; no false conservation in contract |
| AM part | Export G-code | `require_sim_pass` + export audit log |
| Cinematic | Publish MP4/WebM | `seq` determinism hash + preset id |
| Drug / bio stage | Advance LITL | Stage manifest + pipeline hash |
| Paper / investor | Publish bundle | PH-PUB: figures + fields + repro script |

**Differentiator:** ParaView screenshot vs **bundle that rebuilds the figure**.

---

## 8. One loop in the product (all four pillars)

Every serious action uses the same loop — **visible in UI** — whether ▶ Play, **Run sim**, or **Export**:

```text
Author (human or agent) → *.li / canvas / sim profile
        → lic build          ──► PROOF (gate chip — types + contracts)
        → run                ──► play | sim_step | tier-2 bench | RL env tick
        → validity check     ──► RESULTS (drift, checksum, energy, oracle id)
        → publish / export   ──► hash + bench rows (G-code, MP4, PH-PUB)
```

**Studio must show:** gate state, **profile**, last bench row, **validity summary (incl. physics/numeric)**, publish hash — not hide proof in a log file.

---

## 9. Marketing & demos (evidence-based)

**Say:**

> World Studio: killer UI and agents on one engine — **proved before you run** (game, sim, or export), **timed under load**, **engineering results you can reproduce**.

**Show (90 s — pick profile):**

*Game path:* pan → agent patch → gate → ▶ play → replay seed  

*Engineering path:* `sim_scientific` → run `heat_equation_2d` → **validity green + drift** → field in viewport → publish hash  

*Both:* status overlay ms/frame; never beauty-only

**Never show:** fullscreen beauty without gate/validity/status.

---

## 10. Scorecard (qualitative → measurable)

| Competitor class | UI | Perf story | Results story | Proof |
|------------------|-----|------------|---------------|-------|
| UE / Unity | Strong | Keynote FPS | Build works sometimes | Compile, not Li contracts |
| Roblox | Strong + agent | Platform scale | Live UGC | Runtime errors |
| COMSOL / ANSYS | OK | HPC | Reports | Solver math, opaque project |
| OpenFOAM / GROMACS | CLI + logs | Cluster | Published studies | Repro manual, no unified UI gate |
| Figma / Cursor | Strong UX | N/A | Files | No sim gate |
| **Li target** | **Unified shell** | **Tier-2 + validity** | **Publish bundle** | **`lic` + physics validity + composables** |

---

## 11. Engineering priorities (ordered by north star)

| P | Pillar | Deliverable |
|---|--------|-------------|
| P0 | Proof | Gate chip blocks **play, sim run, and export** on fail; MCP runs `lic_check` first |
| P0 | Proof | **Validity required** for every perf/sim claim (dashboard + UI badge) |
| P0 | Physics | `sim_step` + `law_mode` documented; arbitrary laws don’t claim false `ensures` |
| P0 | Engineering | Bench panel shows **oracle name + drift/checksum** for scientific profile |
| P0 | UX | Unified workspace + ⌘K + transcript ([unified-studio-ux-vision](unified-studio-ux-vision.md)) |
| P1 | Performance | `render_frame_present` + `world_engine` in CI with thresholds |
| P1 | Results | Publish drawer shows hash + bench row ids |
| P1 | Results | `seq` frame hash on export path |
| P2 | UX | Native studio shell (G2) with status overlay |
| P2 | Proof | Expand composable gates per new package (`li-gui`, `li-seq`) |
| P2 | Physics | Wire `physics.runtime` into `li-sim` package path (composable green) |
| P3 | Engineering | OpenFOAM/GROMACS-class field oracles where explicitly claimed |

---

## 12. One sentence for the team

**Build nothing that looks killer unless the gate, the physics/numeric validity, and the repro hash can show it — for games and engineering sims alike.**
