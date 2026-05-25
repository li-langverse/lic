# Release notes: manifest prove_lean_ok (G-test-verify)

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/g-items-wave  
**PH / REQ:** PH-2f, G-test-verify  
**Author:** agent

---

## Summary (one sentence)

Closes **G-test-verify** by adding `prove_lean_ok` to `li-tests/run_all.sh` and retagging 14 closed `contracts_verify` specimens so CI distinguishes strict compile from Lean+AutoVC discharge.

## Agent continuation (required)

1. Read: `docs/verification/proof-corpus-roadmap.md` § G-test-verify; `li-tests/run_all.sh` `prove_lean_ok` branch.
2. Run: `LI_REPO_ROOT=$PWD ./li-tests/run_all.sh contracts_verify` and `./li-tests/tooling/contracts_discharge_corpus.sh`; with elan: `command -v lake && lake build AutoVC` in `docs/semantics`.
3. Then: retag remaining `verify_ok` rows when `discharge_*_lean.sh` covers them; wire CI semantics job with elan so `prove_lean_ok` does not skip.
4. Blocked on: **G-lean Done** (kernel default gate), **P-float** (`sqrt_open_bound`), **G-par** / **G-dec** Lean proofs — not this PR.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| `li-tests/run_all.sh` | `prove_lean_ok`: build + `check-autovc-open-goals.sh` + `lake build AutoVC` | New outcome branch |
| `li-tests/manifest.toml` | 14 `contracts_verify` → `prove_lean_ok` | P-linalg + discharge scripts |
| `docs/verification/provability-gaps.md` | **G-test-verify** → **Done**; **How we know** for G-vc/G-lean/G-par/G-dec/G-math closed slices | Gap register |
| `docs/verification/proof-corpus-roadmap.md` | Manifest outcome docs | No overclaim on `verify_ok` |
| `li-tests/tooling/contracts_discharge_corpus.sh` | Caller-requires discharge scripts in corpus gate | `discharge_caller_requires_lean.sh`, `discharge_caller_requires_local_lean.sh` |

## Not changed (scope fence)

- **G-lean** / **G-vc** / **G-trust** — Lean kernel still not universal proof certificate on every `lic build`.
- **G-par**, **G-dec**, **G-math** full broadcast/matmul — compiler proof work beyond closed test slices.
- **G-meta**, **G-gpu**, **G-hw**, **G-wrong-spec**, **G-authz** — not claimed Done.
- **lip** / **lit** / **li-cursor-agents** — no cross-repo pins.
- Master plan tracker checkboxes — plan-tracker agent only.

## Breaking changes

None.

## Security

N/A — test harness only; no new attack surface.

## Performance

N/A — `prove_lean_ok` adds lake when installed; skipped without elan.

## Downstream

| Repo | Action |
|------|--------|
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

- **G-test-verify Done:** `prove_lean_ok` manifest outcome + 14 closed `contracts_verify` rows — `docs/release-notes/2026-05-25-g-test-verify-prove-lean-ok.md`.
