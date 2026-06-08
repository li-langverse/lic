# Li LLM-first design (research stub)

**Date:** 2026-05-16  
**Status:** Planning / research (**Vision-LLM** — partial on master plan)  
**Pillar priority:** Provability (#1) unchanged — this spec optimizes **agent ergonomics**, not proof shortcuts.  
**Plan map:** [plan-cross-links](../../ecosystem/plan-cross-links.md) · [master plan](../plans/2026-05-14-li-master-plan.md#documentation--provability-honesty-cross-cutting) · [provability-gaps](../../verification/provability-gaps.md) (no **G-*** closure from JSON diagnostics alone)

## What this page is for

Capture how Li language, tooling, and docs should minimize **token cost** for LLM agents reading and editing code, without weakening `lic build` or Lean contracts.

**Prerequisites:** [2026-05-14-li-language-design.md](2026-05-14-li-language-design.md), [agent-handover-formats.md](../../ecosystem/agent-handover-formats.md).

## Principles

1. **Agents read more than humans** — prefer stable, grep-friendly symbols and compact manifests over prose duplication.
2. **Structured beats pretty** — machine JSON for diagnostics, edits, and symbol indexes; human ANSI remains default on the terminal.
3. **Infer locally, prove globally** — IDE/`lic check` may omit redundant contract boilerplate in *display* layers only; **`lic build` still requires discharged proofs**.
4. **One canonical entry** — `docs/ecosystem/li-agent-manifest.toml` lists commands agents should call; avoid scattering ad-hoc scripts in prompts.
5. **Diff-friendly** — small files, stable ordering, avoid generated noise in primary source trees.

## Non-goals

| Non-goal | Reason |
|----------|--------|
| Skip `requires` / `ensures` / `decreases` in shipped source | Violates pillar 1 |
| `sorry`, `Any`, or trust-by-prompt | Forbidden in user code |
| Replace Lean with LLM “verification” | Proof certificate stays kernel-checked |
| Break default `lic check` human output | JSON is opt-in (`--format=json`, `lic diagnose`) |
| Terse syntax that cannot elaborate to Core | Sugar must desugar to provable core |

## Concrete ideas (phased)

### Syntax & surface (research)

- **Optional terse aliases** for common contract patterns (desugar to full `proc` specs).
- **Symbol compression** in internal IR / edit buffers (agent applies patches to compact JSON, human view expands).
- **Structured `import` manifest** — single `symbols.li.json` per package for cross-file navigation without parsing all sources.

### Tooling (v0 shipped in this repo)

| Idea | Status |
|------|--------|
| `lic check --format=json` | **Implemented** — `docs/schemas/diagnostic-v1.json` |
| `lic diagnose` | **Implemented** — JSON to stdout |
| `scripts/lic-fix-suggest.sh` | **Stub** — jq hints from JSON |
| Compact test manifest slice for agents | **Implemented** — `scripts/export-li-tests-agent-slice.sh` → `li-tests/agent-manifest.json` |
| `lic edit --patch=json` | **Spec only** — compact edit IR |
| TUI plain + JSON export | **Contract** — `docs/schemas/tui-a11y-v1.json` (harness in `li-cursor-agents`) |

### Docs & rules

- `.cursor/rules/li-llm-first.mdc` — token cost checklist for new syntax/docs.
- Agent skill: `.cursor/skills/agent-diagnose-fix-li/SKILL.md`.

### TUI accessibility export contract (agent + harness)

Terminal UIs consumed by agents and CI must expose **both** a human-readable plain export and a machine JSON audit envelope. Implementation lives in `li-cursor-agents/ux-harness` (adapters + fixtures); this spec is the cross-repo contract Li docs reference. JSON shape: [`docs/schemas/tui-a11y-v1.json`](../../schemas/tui-a11y-v1.json).

| Artifact | Path (per target) | Purpose |
|----------|-------------------|---------|
| **Plain frame** | `ux-harness/artifacts/<target>/frame.txt` | UTF-8 terminal snapshot after render; one screen per audit step. Agents grep this instead of replaying ANSI. |
| **Plain a11y** | `ux-harness/artifacts/<target>/a11y-plain.txt` | Semantic plain-text snapshot (`Surface:`, headings, status lines). No ANSI or box-drawing; emitted when `LI_TUI_EXPORT_A11Y=1`. |
| **Journey trace** | `ux-harness/artifacts/<target>/journey-log.json` | UX mode only — step trace for configured journeys (`key_nav_help`, `cli_to_tui`). |
| **UI audit envelope** | `ui-audit.json` (run root) | Aggregate UI pass/fail per target; schema `tui-a11y-v1` → `targets[]`. |
| **UX audit envelope** | `ux-audit.json` (run root) | Journey rubric scores, friction points, artifact paths; schema `tui-a11y-v1` → `targets[]` with `journeys`. |

**Environment flags (deterministic CI):**

- `UX_HARNESS=1` or `CI=1` or `LI_TUI_NONINTERACTIVE=1` — fixtures must not block on `read` when stdin is not a TTY (see [li-cursor-agents#30](https://github.com/li-langverse/li-cursor-agents/issues/30)).
- `LI_UX_SCRIPT` — piped key sequence for journey steps (`h` help, `q` quit); adapter sets this from `ux-targets.json` journeys.
- `LI_TUI_EXPORT_A11Y=1` — emit plain snapshot to stdout (no escape codes); harness writes `a11y-plain.txt`.
- `LI_TUI_ERROR=1` — exercise error surface on stderr (`Error:` banner); rubric `error_handling` derives from this branch.
- `NO_COLOR=1` — plain export must not depend on ANSI color for meaning.

**Harness commands (must complete &lt;5s non-interactive):**

```bash
python3 ux-harness/run_audit.py --target tui-app-fixture --mode ui
python3 ux-harness/run_audit.py --target tui-app-fixture --mode ux
```

UI mode records `frame.txt`; UX mode additionally records `journey-log.json`, `a11y-plain.txt`, and journey completion in `ux-audit.json`.

**Li repo obligations:** document targets in [gui-ux-quality-handoff](../../ecosystem/gui-ux-quality-handoff.md); do not claim WCAG closure from TUI plain export alone (chrome a11y remains Studio/native — [WORLD-STUDIO-MASTER-PLAN](../../game-dev/WORLD-STUDIO-MASTER-PLAN.md) PH-UX UX-10).

## Learned from (survey sketch)

| System | Takeaway for Li |
|--------|-----------------|
| LSP | Stable locations + codes; we mirror in JSON diagnostics |
| MCP tool descriptors | JSON Schema shapes for agent tools → our diagnostic schema |
| OpenAI function calling | Strict JSON schema for machine steps |
| AGENTS.md / Cursor rules | Repo-level entry; Li uses manifest + generated fragment |
| A2A / Devin handoffs | Task envelopes with command + evidence; Li: manifest + JSON diag + test script |

## Conflict resolution

When LLM-first convenience conflicts with provability: **provability wins** (same as language design spec).

## Related

- [Agent handover formats](../../ecosystem/agent-handover-formats.md)
- [li-agent-manifest.toml](../../ecosystem/li-agent-manifest.toml)
- [Provability gaps](../../verification/provability-gaps.md)
