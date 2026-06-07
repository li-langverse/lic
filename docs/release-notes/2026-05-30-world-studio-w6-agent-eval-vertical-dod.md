# Release notes: 2026-05-30 — world-studio W6 agent eval + vertical DoD

## Summary

Closes the final World Studio master plan loop todos: **WP-AG-06** patch eval harness (≥70% fix-rate) and **wsm-w6-vertical-dod** composable Definition-of-Done for all seven runtime profiles.

## Changes

| WP | Deliverable | Proof |
|----|-------------|-------|
| WP-AG-06 | `studio_ai_patch_eval_*`, `fixtures/patch-eval/manifest.toml` | `studio_ai_patch_eval.li`, `studio-patch-eval-gate.sh` |
| wsm-w6 | `studio_vertical_dod_*` per profile | `studio_vertical_dod.li`, `studio-vertical-dod-gate.sh` |

## Gates

```bash
./scripts/world-studio-plan-gates.sh
./scripts/world-studio-plan-completion-gate.sh
```
