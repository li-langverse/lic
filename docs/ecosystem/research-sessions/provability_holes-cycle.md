# Proof-gap digest — session `4c1f93b0-62ef-44f7-b08c-2c1cbca18ac9` (cycle 1)

**Agent:** `proof_gap_researcher` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem · **PH-2e, PH-2f**  
**Session:** `4c1f93b0-62ef-44f7-b08c-2c1cbca18ac9` · **Cycle:** 1 · **Status:** `complete`  
**Completed steps:** `read_register`, `contract_tier`, `synthesize_step`  
**Whitepaper:** `research-findings/whitepapers/2026-05/provability_holes/prov-r0-cycle1-proof-gap-digest/`  
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

- `trusted_surface` — `lic/docs/semantics/trusted.lean` (deferred to synthesize or follow-up).
- `synthesize_step` — full digest + optional research-findings publish.

---

## Step: `contract_tier` — li-tests contract tiers (2026-05-27)

### Executive summary (contract_tier)

- **Three manifest tiers** map to outcomes: **Tier A** (`compile_ok` / `compile_fail` / `lic check`) = syntax + typecheck; **Tier B** (`verify_ok` / `verify_open_ok`) = `lic build` (+ open-VC policy); **Tier C** (`prove_lean_ok`) = strict build + zero open AutoVC + `lake build AutoVC`.
- **`verify_ok` ≡ `compile_ok` path** in `run_all.sh` (both call `lic build` without proof flags) — naming overclaims vs Tier C (`run_all.sh:218-226`).
- **Manifest corruption (G-test-verify):** duplicate `outcome` keys in one `[[tests]]` block → parser keeps **last** value (`collect_manifest_rows`); fixed 3 blocks: `sqrt_open_bound` ran as `verify_ok` not `prove_lean_ok`; `false_disjoint_decorator_bare_row` never ran; `shadow_echo_via_import` ran as `compile_ok` for wrong file.
- **Tier A soundness hole encoded:** `proof_gaps/false_ensures_still_builds.li` — `ensures result == 0` but returns 42; `lic check` exit 0; strict `lic build` exit 1 (open VC); `--allow-open-vc` links and **binary exits 42**.
- **Tier A negatives work:** `prove_reject/missing_contracts.li` → E0301/E0302; `weak_ensures_true.li` → E0303 (`typecheck.cpp:1614-1627`, `1557-1583`).
- **`missing_decreases.li`:** manifest expects `decreases` substring but specimen **parse-fails** (no `decreases` on `while`) — G-CONTRACT-02 not exercised at typecheck today.
- **`run_all.sh` broken** on branch (`syntax error` line 187 — duplicated `check_deny_warn` / unclosed `compile_ok` blocks) — blocks `run_all.sh proof_gaps`; tests run via direct `lic` invocations.

### Hypothesis outcomes (contract_tier)

- `HYPOTHESIS: verified — Manifest duplicate outcome keys silently downgrade Tier C rows to Tier B | evidence: manifest.toml:231-233 (pre-fix); collect_manifest_rows last-wins (run_all.sh:355); python sim → sqrt_open_bound verify_ok`
- `HYPOTHESIS: verified — Tier A allows false ensures at lic check; Tier B strict build fails open VC; escape hatch ships wrong program | evidence: proof_gaps/false_ensures_still_builds.li; lic check exit 0; lic build exit 1; lic build --allow-open-vc → /tmp/pg_false_ensures exit 42`
- `HYPOTHESIS: verified — verify_ok and compile_ok share the same run_all.sh branch | evidence: run_all.sh:218 compile_ok|verify_ok`
- `HYPOTHESIS: falsified — missing_decreases.li is rejected with decreases-specific error at lic check | evidence: lic check → parse errors (expected ':'), not decreases enforcement`
- `HYPOTHESIS: verified — E0303 rejects ensures true on value-returning proc (Tier A+) | evidence: prove_reject/weak_ensures_true.li; typecheck.cpp:1577-1582`
- `HYPOTHESIS: deferred — prove_lean_ok corpus count matches register “22 rows” until run_all.sh repaired | evidence: run_all.sh syntax error line 187; manual count 21 prove_lean_ok after manifest fix`

### Contract tier map (manifest outcomes)

| Tier | Manifest outcomes | Gate | Proves postcondition? |
|------|-------------------|------|------------------------|
| **A** | `parse_*`, `compile_ok`, `compile_fail`, `check_*` | parse / `lic check` / typecheck | **No** — presence of clauses only (`typecheck.cpp:1590-1627`) |
| **B** | `verify_ok`, `verify_open_ok`, `compile_open_ok` | `lic build` (strict or `--allow-open-vc`) | **Partial** — open VC fails strict build; discharge not universal |
| **C** | `prove_lean_ok` | strict build + `check-autovc-open-goals.sh` + `lake build AutoVC` | **Closed slice only** — per-specimen discharge scripts |

### Commands run (contract_tier)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic
./build/compiler/lic/lic check li-tests/proof_gaps/false_ensures_still_builds.li          # exit 0
./build/compiler/lic/lic build li-tests/proof_gaps/false_ensures_still_builds.li -o /tmp/pg_false_ensures  # exit 1 (open VC)
./build/compiler/lic/lic build --allow-open-vc --no-lean-verify li-tests/proof_gaps/false_ensures_still_builds.li -o /tmp/pg_false_ensures  # exit 0
/tmp/pg_false_ensures  # exit 42
./build/compiler/lic/lic check li-tests/prove_reject/weak_ensures_true.li   # exit 1 E0303
./build/compiler/lic/lic check li-tests/prove_reject/missing_decreases.li   # exit 1 parse (not decreases)
python3 # duplicate outcome scan → 3 blocks pre-fix, 0 post-fix
./li-tests/run_all.sh proof_gaps  # exit 2 — run_all.sh syntax error (pre-existing)
```

### Evidence pack (contract_tier)

| Finding | Location |
|---------|----------|
| Tier A requires/ensures presence | `compiler/types/typecheck.cpp:1614-1627` |
| E0303 weak ensures | `compiler/types/typecheck.cpp:1577-1582` |
| verify_ok = compile_ok branch | `li-tests/run_all.sh:218-226` |
| prove_lean_ok gate | `li-tests/run_all.sh:228-254` |
| Manifest last-wins parser | `li-tests/run_all.sh:355` |
| False ensures repro | `li-tests/proof_gaps/false_ensures_still_builds.li` |
| AutoVC open ensures | `build/generated/AutoVC.lean` (`vc_lies_about_return_ensures_0`) |
| Corrupted race_shared_memory block | `li-tests/manifest.toml:497-504` (fixed) |
| sqrt_open_bound dual outcome | `li-tests/manifest.toml:231-233` (fixed) |

### Recommended issues/PRs (contract_tier)

| Repo | Title | Labels |
|------|-------|--------|
| `lic` | `fix(tests): repair run_all.sh duplicate case branches (blocks all manifest runs)` | `tooling`, `pillar:provable` |
| `lic` | `test(manifest): add check_manifest_duplicate_keys.sh in CI` | `pillar:provable`, `PH-2f` |
| `lic` | `fix(lean): dedupe sqrt_open_bound_spec in Discharge.lean` | `pillar:provable`, `PH-2f` |
| `lic` | `docs(verification): document Tier A/B/C ↔ manifest outcomes` | `documentation`, `PH-2e` |

### Deferred (contract_tier)

- Loop `decreases` enforcement (G-CONTRACT-02) — needs grammar/typecheck + non-parse-fail specimen.
- `run_all.sh` repair — blocks manifest-driven `prove_lean_ok` batch verification.

---

## Step: `synthesize_step` — proof-gap digest (2026-05-27)

### Executive summary (≤8 bullets)

- **`lic build` is not a universal proof certificate** — Tier B runs Lean typecheck when lake is present, but open VCs, trusted axioms, and partial discharge remain (**G-lean**, **G-vc**).
- **Tier B Lean gate is broken today** — duplicate `sqrt_open_bound_spec` in `Discharge.lean` (lines 75–79 and 119–124) causes all default `lic build` lake steps to fail; `check_discharge_duplicate_defs.sh` encodes the guard.
- **Contract tiers A/B/C are mislabeled in CI** — `verify_ok` shares the `compile_ok` branch in `run_all.sh`; only `prove_lean_ok` enforces zero open AutoVC + `lake build AutoVC`.
- **Tier A soundness hole (verified)** — `proof_gaps/false_ensures_still_builds.li`: `lic check` exit 0; strict build exit 1; `--allow-open-vc` links and **binary exits 42** with `ensures result == 0`.
- **Manifest integrity bug (fixed this session)** — duplicate `outcome` keys last-wins silently downgraded Tier C rows; three blocks corrected in `manifest.toml`.
- **Register doc drift** — `provability-gaps.md` repeats G-lean/G-vc/G-par rows → `plan-completion-audit` reports **26 Partial** (~17 unique G-* ids).
- **Trusted surface is minimal but dual-pathed** — `trusted.lean` holds IO/Net/libm axioms; `Discharge.lean` also defines `Li.TrustedMath` sqrt path → **codegen↔Lean drift** alongside duplicate spec.
- **No `trusted.lean` edits** this session; human RFC required for axiom growth.

### 1. Compiler / semantics gaps

| Gap | Status | Evidence | Repro |
|-----|--------|----------|-------|
| **G-lean** — build ≠ kernel certificate | Partial | `provability-gaps.md:19-22`; `main.cpp:612-644` | `lic build` on closed specimen still has open/universal VCs |
| **G-lean** — Tier B lake blocked | **Regression** | `Discharge.lean:75-79`, `119-124` | `./li-tests/tooling/check_discharge_duplicate_defs.sh` → exit 1 |
| **G-meta** — no compiler≡Lean proof | Missing | register gap table | — |
| **G-par** — AST policy, Lean open | Partial | `race_shared_memory/` | register → `li-tests/race_shared_memory/` |
| **Register inflation** | Doc | duplicate rows `provability-gaps.md:35-53` | `plan-completion-audit.py` → `provability_partial=26` |
| **run_all.sh** broken | Tooling | duplicated `check_deny_warn` / `compile_ok` | `./li-tests/run_all.sh proof_gaps` → syntax error ~187 |

**Hypothesis outcomes (compiler):**

- `HYPOTHESIS: verified — Register: lic build is not a universal proof certificate | evidence: provability-gaps.md:19-22; main.cpp:627-644`
- `HYPOTHESIS: falsified — lic build never invokes Lean verification | evidence: main.cpp:639-644; lake invoked on build`
- `HYPOTHESIS: verified — Duplicate sqrt_open_bound_spec blocks Tier B lake | evidence: Discharge.lean:75-79,119-124; check_discharge_duplicate_defs.sh exit 1`
- `HYPOTHESIS: verified — plan-completion-audit over-counts Partial G-* due to duplicate register rows | evidence: plan-completion-audit.py:27-28`

### 2. Contract gaps

| Tier | Outcomes | Gate | Proves postcondition? |
|------|----------|------|------------------------|
| **A** | `compile_ok`, `check_*`, `compile_fail` | parse / `lic check` | **No** — clause presence only (`typecheck.cpp:1614-1627`) |
| **B** | `verify_ok`, `verify_open_ok` | `lic build` (+ `--allow-open-vc`) | **Partial** — open VC fails strict build |
| **C** | `prove_lean_ok` | strict build + open-goal script + `lake build AutoVC` | **Closed slice** per specimen |

**Soundness holes:**

- **G-CONTRACT-01** — false `ensures` at Tier A: `li-tests/proof_gaps/false_ensures_still_builds.li` (`lic check` exit 0; `--allow-open-vc` ships wrong return).
- **G-CONTRACT-02** — `missing_decreases.li` parse-fails before `decreases` enforcement (not E030x).
- **Manifest honesty** — duplicate `outcome` keys (fixed); `verify_ok` naming overclaims vs Tier C.

**Hypothesis outcomes (contracts):**

- `HYPOTHESIS: verified — Manifest duplicate outcome keys silently downgrade Tier C | evidence: collect_manifest_rows last-wins (run_all.sh:355); 3 blocks fixed`
- `HYPOTHESIS: verified — Tier A allows false ensures; --allow-open-vc ships violating binary | evidence: false_ensures_still_builds.li; lic check exit 0; /tmp/pg_false_ensures exit 42`
- `HYPOTHESIS: verified — verify_ok and compile_ok share run_all.sh branch | evidence: run_all.sh:218`
- `HYPOTHESIS: falsified — missing_decreases.li rejected with decreases-specific error | evidence: parse error at lic check`
- `HYPOTHESIS: verified — E0303 rejects ensures true on value proc | evidence: prove_reject/weak_ensures_true.li; typecheck.cpp:1577-1582`
- `HYPOTHESIS: deferred — prove_lean_ok batch matches register “22 rows” | evidence: run_all.sh syntax error; grep count 22 post-fix`

### 3. Trusted surface

**File:** `docs/semantics/trusted.lean` (48 lines) — **only** user-facing axiom file per `semantics/README.md`.

| Symbol | Role | G-* |
|--------|------|-----|
| `IO`, `IO.bind`, `IO.pure`, `present_frame`, `poll_event` | SDL/frame seam | **G-trust** |
| `Net`, `Net.*`, `tcp_*_stub` | httpd P0 syscall surface | **G-net** / **G-trust** |
| `li_rt_sqrt`, `li_rt_sqrt_square_bound` | libm accuracy (**G-hw**) | **G-trust**, **G-hw** |

**Codegen↔Lean drift (no trusted.lean edit):**

- `Discharge.lean` defines **two** sqrt discharge paths: `Li.TrustedMath.li_rt_sqrt` (lines 66–79) and `Li.Trusted.li_rt_sqrt` (lines 119–124) with **duplicate** `sqrt_open_bound_spec` name.
- `proof-database/DISCREPANCIES.md` lists 4× `trusted_axiom` + 2× `hardware_axiom` as **wontfix** (audited externals).
- `Core.lean` stub — **T-GetElem** partial; full MIR preservation planned (**G-trust** Partial+).

**Hypothesis outcomes (trusted):**

- `HYPOTHESIS: verified — trusted.lean remains the sole axiom injection point for user modules | evidence: semantics/README.md:9-16; trusted.lean namespace Li.Trusted only`
- `HYPOTHESIS: verified — Discharge.lean duplicates sqrt spec across TrustedMath and Trusted namespaces | evidence: Discharge.lean:75-79 vs 119-124; blocks lake`
- `HYPOTHESIS: deferred — mat2_at2 trusted vs MIR @ semantic alignment | evidence: DISCREPANCIES.md disc-mat2-trusted-vs-mir pending`

### 4. External trust boundaries (human decision if outside lic)

| Boundary | Li policy | Agent action |
|----------|-----------|--------------|
| **libm / FP hardware** | `li_rt_sqrt_square_bound` axiom (**G-hw**) | Document; no axiom expansion without RFC |
| **OS / SDL IO** | `IO` axioms | httpd/net expansion → RFC per master plan |
| **TCP stubs** | `Net` + `tcp_*_stub` | P0 httpd; real syscall proofs out of scope |
| **Register markdown cleanup** | Human doc PR | Dedupe Still-open table |
| **Discharge.lean dedupe** | Implementation PR | **Not** via `trusted.lean` |

### 5. Evidence pack (file:line, G-*, repro)

| Finding | G-* | Location | Repro command |
|---------|-----|----------|---------------|
| Build ≠ certificate | G-lean | `provability-gaps.md:19-22` | read register summary |
| Tier B pipeline | G-lean | `compiler/lic/main.cpp:612-644` | `lic build discharge_trivial.li` |
| Discharge duplicate | G-lean, G-vc | `Discharge.lean:75-79`, `119-124` | `check_discharge_duplicate_defs.sh` |
| prove_lean_ok gate | G-test-verify | `run_all.sh:228-254` | `grep prove_lean_ok manifest.toml` |
| verify_ok ≡ compile_ok | G-test-verify | `run_all.sh:218` | inspect case branch |
| False ensures Tier A | G-vc | `proof_gaps/false_ensures_still_builds.li` | `lic check` (0); `lic build --allow-open-vc` → exit 42 |
| Tier A requires presence | G-vc | `typecheck.cpp:1614-1627` | — |
| E0303 weak ensures | G-vc | `typecheck.cpp:1577-1582` | `lic check prove_reject/weak_ensures_true.li` |
| Trusted axioms inventory | G-trust | `trusted.lean:8-46` | `scripts/proof-db/compare_reference.py` |
| Audit over-count | — | `plan-completion-audit.py:27-28` | `python3 ../benchmarks/scripts/plan-completion-audit.py` |

### Commands run (synthesize)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic
./li-tests/tooling/check_discharge_duplicate_defs.sh   # exit 1: sqrt_open_bound_spec
grep -c prove_lean_ok li-tests/manifest.toml            # 22
./build/compiler/lic/lic check li-tests/proof_gaps/false_ensures_still_builds.li  # exit 0
wc -l docs/semantics/trusted.lean                       # 48
```

### Recommended issues/PRs (synthesize)

| Repo | Title | Labels |
|------|-------|--------|
| `lic` | `fix(lean): dedupe sqrt_open_bound_spec in Discharge.lean (unblock Tier B build)` | `pillar:provable`, `PH-2f` |
| `lic` | `fix(tests): repair run_all.sh duplicate case branches` | `tooling`, `pillar:provable` |
| `lic` | `docs(verification): dedupe provability-gaps.md Still open rows` | `documentation`, `PH-2e` |
| `lic` | `test(manifest): check_manifest_duplicate_keys.sh in CI` | `pillar:provable`, `PH-2f` |
| `lic` | `docs(verification): document Tier A/B/C ↔ manifest outcomes` | `documentation`, `PH-2e` |
| `lic` | `feat(contracts): reject false ensures at lic check (G-CONTRACT-01)` | `pillar:provable`, `PH-2e` |

### Deferred (synthesize)

- Universal AutoVC discharge / **G-meta** compiler≡Lean proof.
- Loop `decreases` enforcement specimen (G-CONTRACT-02).
- `mat2_at2` trusted vs MIR semantic closure (`disc-mat2-trusted-vs-mir`).
- Wire `check_discharge_duplicate_defs.sh` into `contracts_discharge_corpus.sh`.
- Batch `prove_lean_ok` verification after `run_all.sh` repair.
