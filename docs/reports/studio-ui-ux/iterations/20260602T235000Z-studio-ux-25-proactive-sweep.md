# Studio UI/UX iteration — `studio-ux-25-proactive-sweep-20260531`

**UTC:** 2026-06-02T23:50:00Z  
**Branch:** `chore/agent-code_implementer-1780443505316-studio-ux-25`  
**North star:** PH-UX easy capture path + ecosystem honesty (issue #399, briefing wave-5).

## Summary

Added `scripts/studio-ui-ux-check-capture-deps.sh` (issue #399) — runs the capture-deps probe, asserts JSON on disk, soft-warns when native/HTML capture is unavailable, and supports strict mode for CI. Wired into `studio-ui-ux-plan-gates.sh` and `ci-studio-ui-ux-native.sh`. Refreshed `studio-ui-ux-write-briefing-snapshot.py` wave-5 gap detection (stale PH-ML PRs, failed-PR triage, capture-deps soft gate).

## Shipped

- `scripts/studio-ui-ux-check-capture-deps.sh` — assert + soft/strict gate
- `scripts/studio-ui-ux-plan-gates.sh` — prefers check script over raw probe
- `scripts/ci-studio-ui-ux-native.sh` — strict capture-deps before native capture
- `scripts/studio-ui-ux-write-briefing-snapshot.py` — wave-5 gaps + follow-ups

## PH-UX gates

| Gate | Target | Measured | Pass |
|------|--------|----------|------|
| capture_deps_json | written | yes | yes |
| native_capture | SDL+Xvfb | runner-dependent | soft warn |
| html_capture | chrome | runner-dependent | soft warn |

## Agentic AI SOTA (≥3 refs)

- [Cursor agent](https://cursor.com/docs/agent/overview) — honest blocked capture vs silent skip
- [Linear command menu](https://linear.app/docs/command-menu) — fast palette path (UX-04 follow-up in #722)
- [GitHub Copilot](https://docs.github.com/en/copilot) — GPU fail recovery strip (UX-08 follow-up in #723)

## Regressions

none — additive scripts only

## Deferred

- Close stale PH-ML PRs #681/#678 on merged `cursor/ph-ml-program-complete` base (human triage)
- Merge studio-ux-16/17 PRs #722/#723 when review completes
