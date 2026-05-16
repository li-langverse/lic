# Vision & roadmap governance

<!-- DOC-ecosystem-vision-roadmap -->

**Where visions live** so agents and humans do not fork the story per repo.

## Layers

| Scope | Canonical home | Updates when |
|-------|----------------|--------------|
| **Language + compiler + org** | [Master plan](../superpowers/plans/2026-05-14-li-master-plan.md) | Pillars, phases **PH-***, new repo policy, cross-cutting gates |
| **Public roadmap (future)** | `li-langverse/roadmap` repo (not created yet) | Quarterly themes, release trains, user-facing milestones |
| **Product / package** | Each package `README.md`, `PUBLISH.md`, `docs/traceability.md` | Package scope only — not language syntax |
| **Server (li-httpd)** | [li-httpd plan](../superpowers/plans/2026-05-16-li-httpd-plan.md) + **`lis`** repo | Agent gateway features |
| **Living gaps** | [provability-gaps.md](../verification/provability-gaps.md) | What is **not** proved yet |

**Rule:** If a change affects **more than one package** or **Li pillars**, update the **master plan** (same PR or immediate follow-up). Do not hide ecosystem vision only in a package README.

### Future `roadmap` repo (planned — human creates)

**Deferred** until milestones outgrow the master plan. Do not create the repo from agent sessions without explicit human approval ([master plan — human-only actions](../superpowers/plans/2026-05-14-li-master-plan.md)).

When the org outgrows one markdown file:

- **`li-langverse/roadmap`** — Markdown + milestones; links to **PH-** ids; no implementation code
- Master plan stays **normative** for agents; roadmap is **communicative** for contributors and users
- Agents: read **master plan first**; roadmap second for dates and themes

---

## Li vision (non-negotiable)

All ecosystem work must reinforce:

1. **Easy** — Nim-like surface; low ceremony; TOML/config desugar
2. **AI-first** — agents, streaming, observability, safe defaults at the edge
3. **Secure** — proofs + typed config + CVE-informed tests + minimal trusted base
4. **Provable** — `lic build` = Lean; no `sorry` in user code
5. **Blazingly fast** — LLVM, SIMD, OpenMP; measured regressions; no perf claims without benches

See [engineering-standards.md](engineering-standards.md) for how agents enforce this daily.
