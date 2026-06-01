# BUG-C-09 — prelude linalg manifest tier

**Gap script:** `li-tests/tooling/prelude_linalg_manifest_tier_gap.sh`  
**Status:** Open

## Summary (from gap script)

G-test-verify / G-math / PH-2i: prelude scale|axpy|norm codegen exists but manifest marks `verify_ok` while AutoVC is trivial main-only.

## Owner action

Align manifest tiers with real AutoVC discharge or downgrade to `compile_ok` only.
