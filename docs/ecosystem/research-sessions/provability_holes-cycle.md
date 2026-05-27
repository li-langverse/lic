# Proof-gap digest — session `4c1f93b0-62ef-44f7-b08c-2c1cbca18ac9` (cycle 1)

**Agent:** `proof_gap_researcher` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem · **PH-2e, PH-2f**  
**Completed steps:** `read_register` · *queued:* `trusted_surface`, `contract_tier`, `synthesize_step`  
**Repo:** `lic` (`/home/s4il0r/Documents/Cursor/li-langverse/lic`)

---

## Step: `read_register` — `docs/verification/provability-gaps.md` (2026-05-27)

### Executive summary (read_register)

- Register is the canonical G-* inventory; summary table still states **`lic build` ≠ proof certificate** — accurate for universal kernel closure, not “no Lean.”
- **`lic build` now runs Tier B Lean** by default (`main.cpp` open-VC gate + `run_lean_verify_script`); this supersedes older “no Lean in build” digests.
- **G-test-verify** marked **Done**: 22× `prove_lean_ok` rows in `li-tests/manifest.toml`; `prove_lean_ok` path = strict build + zero open AutoVC + `lake build AutoVC` when elan present.
- **`verify_ok` ≡ `compile_ok`** for the default path (both call `li_lic_build` without proof flags) — manifest honesty gap vs `prove_lean_ok` remains intentional.
- **Register doc drift:** duplicate “Last updated” lines, repeated G-* rows in “Still open” and gap table → `plan-completion-audit.py` counts **26 Partial** (inflated; ~17 unique G-* ids).
- **Lean↔spec drift (new):** `Discharge.lean` declares `sqrt_open_bound_spec` twice (lines 75 and 119) → **all default `lic build` with lake fails** on closed specimens (`discharge_trivial.li` exit 1).
- **`Core.lean` exists** (`docs/semantics/Core.lean`); register **G-trust** Partial+ (T-GetElem) is consistent.
- No `trusted.lean` edits this step.

### Hypothesis outcomes (read_register)

- `HYPOTHESIS: verified — Register summary: lic build is not a universal proof certificate | evidence: provability-gaps.md:19-22, main.cpp:627-644 (open VC gate + lake, not full spec)`
- `HYPOTHESIS: falsified — lic build never invokes Lean verification | evidence: main.cpp:639-644; ./build/compiler/lic/lic build li-tests/contracts_verify/discharge_trivial.li → lake Discharge build attempted`
- `HYPOTHESIS: verified — G-test-verify Done: prove_lean_ok distinct from verify_ok | evidence: manifest.toml:3, run_all.sh:228-254 vs 218-226`
- `HYPOTHESIS: verified — plan-completion-audit over-counts Partial G-* due to duplicate register rows | evidence: plan-completion-audit.py:27-28; audit JSON partial list repeats **G-lean** 3×`
- `HYPOTHESIS: verified — Duplicate sqrt_open_bound_spec in Discharge.lean breaks default lic build Lean gate | evidence: Discharge.lean:75-79,119-124; lic build discharge_trivial.li → Discharge.lean:119 already been declared`
- `HYPOTHESIS: deferred — Full gap-register dedup automation in CI | evidence: added check_discharge_duplicate_defs.sh only; register markdown cleanup is human/doc PR`

### Register inventory (verified sample)

| ID | Register status | Spot-check evidence | Command / note |
|----|-----------------|---------------------|----------------|
| **G-lean** | Partial | Tier B lake; open VC fail; duplicate Discharge blocks lake | `lic build discharge_trivial.li` → exit 1 (Discharge dup) |
| **G-vc** | Partial | AutoVC emit + partial discharge scripts | `vc_emit_lean.cpp`, corpus scripts in register |
| **G-par** | Partial | `race_shared_memory/` AST rejects | register → `li-tests/race_shared_memory/` |
| **G-test-verify** | Done | 22 `prove_lean_ok` manifest rows | `grep -c prove_lean_ok li-tests/manifest.toml` → 22 |
| **G-trust** | Partial+ | `Core.lean` present | `docs/semantics/Core.lean` |
| **G-meta** | Missing | register + no compiler≡Lean proof | register gap table |
| **G-hw** | Axiomatic | documented limit | register |

### Commands run (read_register)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic
python3 ../benchmarks/scripts/plan-completion-audit.py  # provability_partial=26, missing=4
./build/compiler/lic/lic build li-tests/contracts_verify/sqrt_contract.li -o /tmp/pg_sqrt  # exit=1 (Discharge dup)
./build/compiler/lic/lic build li-tests/contracts_verify/discharge_trivial.li -o /tmp/pg_trivial  # exit=1 (Discharge dup)
chmod +x li-tests/tooling/check_discharge_duplicate_defs.sh
./li-tests/tooling/check_discharge_duplicate_defs.sh  # exit=1: sqrt_open_bound_spec
```

### Evidence pack (file:line)

| Finding | Location |
|---------|----------|
| Summary: build ≠ certificate | `docs/verification/provability-gaps.md:19-22` |
| Duplicate register rows | `provability-gaps.md:35-53` (G-lean/G-vc/G-par repeated) |
| Build pipeline (VC + optional lean) | `compiler/lic/main.cpp:612-644` |
| prove_lean_ok gate | `li-tests/run_all.sh:228-254` |
| verify_ok = compile path | `li-tests/run_all.sh:218-226` |
| Discharge duplicate def | `docs/semantics/Discharge.lean:75-79`, `119-124` |
| Audit regex | `benchmarks/scripts/plan-completion-audit.py:27-28` |

### Recommended issues/PRs (read_register)

| Repo | Title | Labels |
|------|-------|--------|
| `lic` | `fix(lean): dedupe sqrt_open_bound_spec in Discharge.lean (blocks Tier B build)` | `pillar:provable`, `PH-2f` |
| `lic` | `docs(verification): dedupe provability-gaps.md Still open + gap table rows` | `pillar:provable`, `documentation` |
| `lic` | `test(tooling): wire check_discharge_duplicate_defs into contracts_discharge_corpus` | `pillar:provable` |
| `lic` | `chore(tests): resolve run_all.sh duplicate compile_ok branches` | `tooling` |

### Deferred (read_register)

- `trusted_surface` — `lic/docs/semantics/trusted.lean` (next queue step).
- `contract_tier` — li-tests contract tiers (next queue step).
- `synthesize_step` — full digest + optional research-findings publish.
