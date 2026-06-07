# Proof-gap digest — session `97b0a884-e513-4a30-9793-5493bc1aed9e` (cycle 1)

**Agent:** `proof_gap_researcher` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem · **PH-2e, PH-2f**  
**Completed steps:** `read_register-1`, `contract_tier-2`, `synthesize_step` (proof-gap digest)  
**Repo:** `lic` · **Whitepaper:** `research-findings/whitepapers/2026-05/provability_holes/prov-r0-cycle1-proof-gap-digest/`

---

## Executive summary

- **`lic build` is no longer “compile-only”** — default path emits `AutoVC.lean`, fails on open VCs, and runs `lake build AutoVC` when Lean is installed (`compiler/lic/main.cpp:599-623`).
- **Certificate ≠ universal kernel discharge** — closed slices (`prove_lean_ok`, `sqrt_open_bound`, P-linalg Props) exist; **G-lean** / **G-vc** remain **Partial** per `docs/verification/provability-gaps.md`.
- **Contract tier boundary is testable** — false `ensures` rejected under strict build; `--allow-open-vc` downgrade is explicit (`false_ensures_*` fixtures + manifest outcomes).
- **`verify_ok` ≠ `prove_lean_ok`** — harness distinguishes build smoke from zero open goals + lake (`li-tests/run_all.sh:199-233`); **G-test-verify** marked **Done** in register.
- **Manifest honesty hardened** — `lint_manifest_no_duplicate_keys.sh` wired in `manifest.toml`; duplicate `outcome` keys can no longer silently downgrade tiers.
- **Trusted surface grew but stayed RFC-governed** — `trusted.lean` adds Net + libm `sqrt` axiom; **no edits** this session; `Core.lean` is a **stub**, `MIR.lean` still planned.
- **Parallel safety is structured + partial proofs** — `policy_module.cpp` / MIR `disjoint_proven` + `Discharge` disjoint specs; **G-par** Lean discharge still open.
- **Benchmark tier-0 verify is intentionally downgraded** — `benchmarks/harness/verify.py:33` uses `--allow-open-vc --no-lean-verify` (not a proof certificate).

---

## 1. Compiler / semantics gaps

| Gap | Evidence | Repro |
|-----|----------|-------|
| Open VCs block strict ship | `main.cpp:605-614` — counts open goals, exit 1 + `--allow-open-vc` hint | `./build/compiler/lic/lic build li-tests/contracts_verify/false_ensures_strict_reject.li` → exit 1 |
| `lic check` = frontend only | `main.cpp:489-491` — `lic_check_main`, no VC emit gate | `lic check` on contract file — no AutoVC failure |
| `Core.lean` stub, `MIR.lean` absent | `docs/semantics/README.md:10-12` | `find docs/semantics -name MIR.lean` → absent |
| Codegen preservation unproved | `provability-gaps.md:52` **G-meta** Missing | deferred |
| `verify_ok` still build-only | `run_all.sh:199-205` | `./li-tests/run_all.sh contracts_verify` — `sqrt_contract.li` passes as `verify_ok` without `prove_lean_ok` |

---

## 2. Contract gaps

| Tier | Spec | Today | Evidence |
|------|------|-------|----------|
| **A** | `requires`/`ensures`/`decreases` presence | Enforced at typecheck / policy | `prove_reject/missing_contracts.li` → compile_fail |
| **B** | VC discharge + lake | **Partial** — default build runs lake; witnesses + `Discharge.lean` for slices | `prove_lean_ok` + `check-autovc-open-goals.sh` |
| **C** | Refinement proof | **Partial** — `index_refinement.li` on `verify_ok` only | `manifest.toml` outcome |
| **Downgrade** | Documented open VC ship | `--allow-open-vc` CLI only; env `LI_ALLOW_OPEN_VC` ignored | `main.cpp:260-272` |

**Tier repro (this session):**

```bash
cd lic
LIC=./build/compiler/lic/lic
$LIC build li-tests/contracts_verify/false_ensures_strict_reject.li -o /tmp/t   # exit 1, hints allow-open-vc
$LIC build --allow-open-vc li-tests/contracts_verify/false_ensures_allow_open_ok.li -o /tmp/t2  # exit 0
./li-tests/run_all.sh contracts_verify   # pass=32 fail=0 (2026-05-28)
```

**Weak ensures:** `prove_reject/weak_ensures_true.li` — `ensures true` still compiles under strict build (social / **G-wrong-spec**, not tool-closable).

---

## 3. Trusted surface

| Item | Location | Notes |
|------|----------|-------|
| IO + Net axioms | `docs/semantics/trusted.lean:8-39` | Minimal extern surface |
| FP libm bound | `trusted.lean` + `Li.Discharge.sqrt_open_bound_spec` | **G-hw** / P-float slice |
| `Core.lean` stub | `docs/semantics/Core.lean` | `core_stub_ok` only — **G-trust** Partial |
| `extern proc` | typecheck skips body | Must match trusted listings |

**Session rule:** No `trusted.lean` edits.

---

## 4. External trust boundaries (human decision if outside lic)

| Boundary | Trust assumption | Owner |
|----------|------------------|-------|
| LLVM 18 codegen | Correct lowering until translation validation | Platform |
| Lake / Mathlib toolchain | Toolchain for AutoVC | Semantics WG |
| Tier-0 bench verify downgrade | `--allow-open-vc --no-lean-verify` smoke | Benchmarks harness |
| Tier-2 C++ reference kernels | Physics oracle for ratio tests | Benchmarks |
| User theorem quality | **G-wrong-spec** | Review culture |

---

## 5. Evidence pack

### Register (read_register)

- Source: `docs/verification/provability-gaps.md` (2026-05-26) — **Partial** / **Missing** / **Done** legend (not legacy `Open` rows).
- Briefing scorecard: `benchmarks/scripts/plan-completion-audit.py:134-141` scans `**Partial**` / `**Missing**` → `provability_partial` / `provability_missing`.

### Contract tier (contract_tier)

- Manifest lint: `./li-tests/tooling/lint_manifest_no_duplicate_keys.sh li-tests/manifest.toml` → exit 0.
- `sqrt_open_bound` closed: `lic build li-tests/contracts_verify/sqrt_open_bound.li` → exit 0 + lake ok.

### Hypothesis outcomes (cycle 1)

- `HYPOTHESIS: verified — Strict lic build rejects false ensures without --allow-open-vc | evidence: false_ensures_strict_reject.li exit=1; manifest compile_fail`
- `HYPOTHESIS: verified — --allow-open-vc is the explicit Tier-B downgrade for known-open postconditions | evidence: false_ensures_allow_open_ok.li + verify_open_ok in run_all.sh:243-255`
- `HYPOTHESIS: verified — prove_lean_ok differs from verify_ok (open goals + lake) | evidence: run_all.sh:207-233; contracts_verify pass=32`
- `HYPOTHESIS: verified — manifest duplicate keys are caught before silent tier drift | evidence: lint_manifest_no_duplicate_keys.sh exit=0`
- `HYPOTHESIS: falsified — lic build never invokes Lean (prior cycle claim) | evidence: main.cpp:617-619 lake verify on default build; sqrt_open_bound lake output`
- `HYPOTHESIS: falsified — prove_reject/uses_sorry.li fails only at parse | evidence: lic build → "sorry/admit/assume are forbidden in user code"`
- `HYPOTHESIS: verified — Benchmark tier-0 verify is build smoke with proof downgrade flags | evidence: benchmarks/harness/verify.py:4-6,33`
- `HYPOTHESIS: deferred — Compiler ≡ Lean semantics (G-meta) | evidence: MIR.lean absent; register Missing`

### Commands run (synthesize, 2026-05-28)

```bash
cd /home/s4il0r/Documents/Cursor/li-langverse/lic
LIC=./build/compiler/lic/lic
$LIC build li-tests/contracts_verify/false_ensures_strict_reject.li -o /tmp/li_gap_97b0     # exit 1
$LIC build --allow-open-vc li-tests/contracts_verify/false_ensures_allow_open_ok.li -o /tmp/li_gap_97b0_open  # exit 0
$LIC build li-tests/contracts_verify/sqrt_open_bound.li -o /tmp/li_sqrt_97b0               # exit 0
./li-tests/tooling/lint_manifest_no_duplicate_keys.sh li-tests/manifest.toml               # exit 0
./li-tests/run_all.sh contracts_verify   # pass=32
./li-tests/run_all.sh prove_reject       # pass=6
$LIC build li-tests/prove_reject/uses_sorry.li -o /dev/null  # semantic sorry ban
```

---

## Recommended issues/PRs

| Repo | Title | Labels |
|------|-------|--------|
| `lic` | `feat(verify): close remaining open AutoVC goals on verify_ok corpus` | `pillar:provable`, `PH-2f` |
| `lic` | `feat(semantics): MIR.lean preservation sketch (G-meta precursor)` | `pillar:provable`, `PH-2e` |
| `lic` | `test(contracts): migrate high-value verify_ok rows to prove_lean_ok` | `testing`, `PH-2f` |
| `lic` | `docs(verification): dedupe provability-gaps proof-db appendix blocks` | `documentation` |
| `benchmarks` | `chore(bench): document tier-0 verify downgrade in harness README` | `pillar:provable` |

---

## Deferred

- **G-meta** — compiler ↔ Lean equivalence (blocked on `MIR.lean` + preservation proofs).
- **Loop decreases enforcement** — `missing_decreases.li` still parse-level in some paths.
- **mat2 trusted vs MIR `@`** — semantic closed in `Discharge.lean`; codegen alignment tracked under **G-lean** row.
- **Enroll all contract rows as `prove_lean_ok`** — after lake CI capacity / open-goal closure plan.

---

## Error

None this session.
