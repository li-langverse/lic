# Release note: Chapel 2.3+ Python/NumPy interop reference policy plan (lic#54)

**Date:** 2026-06-07  
**Type:** Planning / documentation only — no compiler or runtime behavior change  
**Issue:** [lic#54](https://github.com/li-langverse/lic/issues/54)

## Summary

Adds a **Chapel 2.3 → Li foreign bindings reference policy** for AI-first scientific computing. Extracts Chapel Python/NumPy interop ergonomics into normative rubric rows **without adopting Chapel runtime or unproved FFI shortcuts**.

## Artifacts

| Path | Role |
|------|------|
| `docs/superpowers/plans/2026-06-07-li-chapel-23-python-interop-reference-policy.md` | Implementation plan |
| `docs/superpowers/specs/2026-06-07-li-foreign-bindings-reference-policy.md` | Normative FB-01…FB-08 checklist |

## north_star_fit

AI-first foreign bindings reference · **Vision-LLM**, **PH-IO-4/5/7**, **PH-ML** · **G-ai**, **G-trust**, **G-ml**

## Gates

- `./scripts/check-doc-provability-claims.sh` exit 0
- No benchmark threshold changes

## Next steps

Human **`plan-approved`** on #54 → implementers scope PH-FFI / `std/foreign` tracks separately; lic#113 companion for HPC portability.
