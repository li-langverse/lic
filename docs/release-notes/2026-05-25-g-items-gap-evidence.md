# G-* provability gap evidence

**Status:** Ready for review | **Repo:** li-langverse/lic | **PH:** 2f, 7d-c, 2i

## Summary

Structured `disjoint_*` AST policy, `MirDecorator.parallel`, math shape + P-linalg + witnessed-ensures tooling; gap register updated (**Partial** only).

## Agent continuation

1. Read `docs/verification/provability-gaps.md`
2. Run `./li-tests/run_all.sh race_shared_memory decorator_exploits math_linalg` and `./li-tests/tooling/contracts_discharge_corpus.sh`
3. `lake build` in `docs/semantics` on devbox
4. Blocked: G-par Lean proofs; G-meta/G-gpu (out of scope)

## Not changed

G-meta, G-gpu, G-authz, G-hw, G-wrong-spec; G-test-verify (already Done).

## Breaking / Security / Performance / Downstream

N/A.
