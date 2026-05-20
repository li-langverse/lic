# Product north star — four killers, mathematically proven

**Status:** Canonical (2026-05)  
**Owner:** Product / PH-GD / PH-UX / PH-SIM  
**Related:** [world-studio-vision.md](world-studio-vision.md) · [unified-studio-ux-vision.md](unified-studio-ux-vision.md) · [philosophy.md](../language/philosophy.md)

---

## 1. The goal (one paragraph)

**Li World Studio** must deliver **killer UI/UX**, **killer performance**, and **killer results** — and every claim must be **mathematically provable** or **measurement-backed** in-repo, not keynote slides. Humans get AAA-grade chrome; agents get stable IDs and gates; physics, numerics, and shipped artifacts share one **proof + bench + validity** spine.

---

## 2. Four killers + proof (non-negotiable)

```text
                    ┌─────────────────────────────────────┐
                    │     MATHEMATICALLY PROVEN (core)     │
                    │  lic build · contracts · validity    │
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
| **Mathematically proven** | “This build is safe to run/ship” | `requires`/`ensures`/`decreases`; `lic build`; composable gates; diagnose JSON | `lic` + ~175+ composable imports |

**Rule:** No pillar stands alone. UI shows **gate + validity**; performance without validity is **invalid**; results without repro hash are **not shipped**; agents cannot skip **proof**.

---

## 3. What “mathematically proven” means (precise)

| Layer | Mechanism | What we claim |
|-------|-----------|---------------|
| **Language** | `requires`, `ensures`, `decreases` on `def` | Local correctness of functions |
| **Build** | `lic build` / `lic check` | Project compiles + proof obligations discharged (where enabled) |
| **Integration** | Composable import smokes (`li-tests`) | Packages link; no silent ABI drift |
| **Numerics** | Tier-2 **validity** (checksum, drift, energy, …) | This run’s numbers are **consistent**, not “fast but wrong” |
| **Determinism** | `determinism_tier`, replay, `seq` frame hash | Same inputs → same observable outputs |
| **Publish** | PH-PUB bundle: sources + bench row + manifest hash | Third party can **reproduce** the figure/export |

**What we do not claim without evidence:**

- “Proved faster than UE5” → need `ue-baselines.csv` + same workload  
- “Proved CFD equals OpenFOAM” → need field oracle + mesh study  
- “Proved secure” → CRITICAL package audit path ([compliance RFC](specs/critical-package-compliance-rfc.md))

**UI copy:** Say **“build passed”** / **“validity green”** / **“repro id `…`”** — not “mathematically perfect universe simulator.”

---

## 4. Killer UI/UX (provable surface)

| UX target | Metric | Proof hook |
|-----------|--------|------------|
| Viewport / canvas | ≥60 fps pan/zoom | `render_frame_present` bench + validity |
| Workspace switch | &lt;100 ms | Studio perf smoke (native G2+) |
| Primary flows | ≤3 clicks | UX checklist per profile |
| Agent patch | Visible gate &lt;2 s local | `lic check` on every `UiAgentAction` |
| Trust | Gate chip always on | Failed build **blocks** play/export |

**Vision:** [unified-studio-ux-vision.md](unified-studio-ux-vision.md)  
**Build:** [li-native-gui-plan.md](plans/li-native-gui-plan.md) G0–G8

**Differentiator:** Roblox/Figma-level UX **plus** gate chip and validity badge — they don’t show **why** run is trusted.

---

## 5. Killer performance (provable speed)

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

## 6. Killer results (provable outcomes)

| Outcome | User action | Proof artifact |
|---------|-------------|----------------|
| Game build runs | ▶ Play | `lic build` ok + replay seed |
| Sim study | Run bench profile | CSV + validity + oracle name |
| AM part | Export G-code | `require_sim_pass` + export audit log |
| Cinematic | Publish MP4/WebM | `seq` determinism hash + preset id |
| Drug / bio stage | Advance LITL | Stage manifest + pipeline hash |
| Paper / investor | Publish bundle | PH-PUB: figures + repro script |

**Differentiator:** ParaView screenshot vs **bundle that rebuilds the figure**.

---

## 7. One loop in the product (all four pillars)

Every serious action uses the same loop — **visible in UI**:

```text
Author (human or agent) → *.li / canvas compile
        → lic build          ──► KILLER PROOF (gate chip)
        → run (play / bench / sim step)
        → validity check     ──► KILLER RESULTS (badge + row id)
        → publish / export   ──► hash on screen
```

**Studio must show:** gate state, last bench row, validity summary, publish hash — not hide proof in a log file.

---

## 8. Marketing & demos (evidence-based)

**Say:**

> World Studio: killer UI and agents on one engine — **proved before play**, **timed under load**, **results you can reproduce**.

**Show (90 s demo script):**

1. Canvas or viewport — smooth pan (**UX**)  
2. Agent patch → gate turns green (**proof**)  
3. ▶ Play or run bench → validity line (**results**)  
4. Status overlay: ms/frame ratio (**performance**)  
5. Publish → copy repro id (**results + proof**)

**Never show:** fullscreen beauty without gate/validity/status.

---

## 9. Scorecard (qualitative → measurable)

| Competitor class | UI | Perf story | Results story | Proof |
|------------------|-----|------------|---------------|-------|
| UE / Unity | Strong | Keynote FPS | Build works sometimes | Compile, not Li contracts |
| Roblox | Strong + agent | Platform scale | Live UGC | Runtime errors |
| COMSOL / ANSYS | OK | HPC | Reports | Solver math, opaque project |
| Figma / Cursor | Strong UX | N/A | Files | No sim gate |
| **Li target** | **Unified shell** | **Tier-2 + validity** | **Publish bundle** | **`lic` + composables** |

---

## 10. Engineering priorities (ordered by north star)

| P | Pillar | Deliverable |
|---|--------|-------------|
| P0 | Proof | Gate chip + block play/export on fail; MCP always runs `lic_check` first |
| P0 | Proof | Validity column required in bench dashboard docs |
| P0 | UX | Unified workspace + ⌘K + transcript ([unified-studio-ux-vision](unified-studio-ux-vision.md)) |
| P1 | Performance | `render_frame_present` + `world_engine` in CI with thresholds |
| P1 | Results | Publish drawer shows hash + bench row ids |
| P1 | Results | `seq` frame hash on export path |
| P2 | UX | Native studio shell (G2) with status overlay |
| P2 | Proof | Expand composable gates per new package (`li-gui`, `li-seq`) |
| P3 | Results | UE/OR/OpenFOAM parity oracles where claimed |

---

## 11. One sentence for the team

**Build nothing that looks killer unless the gate, the bench, and the hash can show it.**
