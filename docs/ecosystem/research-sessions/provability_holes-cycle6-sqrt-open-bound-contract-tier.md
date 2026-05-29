# provability_holes — cycle 6 (G-vc / P-float sqrt contract tier)

**Run:** `proof_gap_researcher-2026-05-29-sqrt-contract-tier` · **Goal:** `provability_holes` · **north_star_fit:** ecosystem, PH-2e, PH-2f

## Focus

**G-vc / G-lean / P-float:** `sqrt_open_bound.li` is the canonical **intentionally open** float contract — real `Float.abs` Prop in AutoVC, **no** `_proved` theorem, **`lic build` fails** without `--allow-open-vc`, while **`lic check` passes** (not a certificate).

## Digest

### 1. Compiler / semantics gaps

- `lic check` does not run open-VC counting (`main.cpp` build path only, ~603–613).
- Runtime `li_rt_sqrt` body is trusted C; semantic gap is **proof**, not codegen soundness for this specimen.

### 2. Contract gaps

- User `ensures abs(result * result - x) < 1e-12` lowers to `Float.abs ((result * result) - x) < 1e-12` (`vc_emit_lean.cpp:224-228`, `build/generated/AutoVC.lean:13`).
- Extern callee `li_rt_sqrt` has `ensures true` — no callee-return linkage VC; only `vc_sqrt_open_call0_li_rt_sqrt_requires_0 := True` with trivial proof (`AutoVC.lean:16-17`).
- Non-trivial ensures omit `_proved` when `prop != True` (`vc_emit_lean.cpp:411-417` — only `True` or mat2 paths get theorems).

### 3. Trusted surface

- No `trusted.lean` edits. `Discharge.lean:60-61` keeps `sqrt_open_bound_placeholder : True` (documented deferral).

### 4. External trust boundaries

- `li_rt_sqrt` IEEE/FP behavior is an **external** trust boundary until **P-float** lemmas land; closing belongs in `Discharge.lean` + discharge corpus, not axiom growth in `trusted.lean`.

### 5. Evidence pack

| G-* | Repro |
|-----|--------|
| **G-vc** / **P-float** | `bash li-tests/tooling/sqrt_open_bound_contract_tier.sh` → ok |
| **G-lean** | `lic build li-tests/contracts_verify/sqrt_open_bound.li` → exit 1, 1 open obligation |
| **G-lean** | `lic build --allow-open-vc …` → exit 0; `lake build AutoVC` typechecks |
| **G-vc** (contrast) | `bash li-tests/tooling/vc_emit_contracts.sh` — `sqrt_contract.li` closed witness path |
| **Tier-0 gate** | `LI_ALLOW_OPEN_VC=1 lic build …` → warning + exit 1 (`main.cpp:244`) |

### Hypothesis outcomes

- `HYPOTHESIS: verified — sqrt_open ensures emits Float.abs Prop not True | evidence: AutoVC.lean:13; sqrt_open_bound_contract_tier.sh`
- `HYPOTHESIS: verified — vc_sqrt_open_ensures_0 has no _proved theorem (open goal) | evidence: check-autovc-open-goals.sh; vc_emit_lean.cpp:411-417`
- `HYPOTHESIS: verified — lic build fails without --allow-open-vc | evidence: exit 1; main.cpp:603-613`
- `HYPOTHESIS: verified — lic check passes on specimen (check ≠ certificate) | evidence: lic check sqrt_open_bound.li exit 0`
- `HYPOTHESIS: verified — LI_ALLOW_OPEN_VC env ignored | evidence: main.cpp:244; env build exit 1`
- `HYPOTHESIS: falsified — callee ensures true discharges caller abs bound | evidence: no callee ensures VC; only requires True proved`
- `HYPOTHESIS: falsified — open bound lowers to True stub | evidence: AutoVC.lean:13`
- `HYPOTHESIS: deferred — close via trusted axiom without P-float lemmas | evidence: policy; use Discharge + real sqrt error bound`

### Commands

```bash
lic=build/compiler/lic/lic
$lic check li-tests/contracts_verify/sqrt_open_bound.li                    # exit 0
$lic build li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null       # exit 1
$lic build --allow-open-vc li-tests/contracts_verify/sqrt_open_bound.li -o /dev/null  # exit 0
bash li-tests/tooling/sqrt_open_bound_contract_tier.sh                   # ok
```
