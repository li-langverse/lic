# Release notes: 2026-05-25 — linguist-wp346-handoff

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** branch `feat/linguist-wp346-handoff`  
**PH / REQ:** ecosystem / GitHub language detection (no PH id)  
**Author:** agent

---

## Summary (one sentence)

Adds the Li → GitHub Linguist playbook, usage-evidence audit process, and upstream patch bundle so Julian can open the linguist PR after WP1/2 merge without agent commits on github-linguist.

## Agent continuation (required)

1. Read: `docs/ecosystem/github-linguist.md`, `docs/ecosystem/github-linguist-usage-evidence.md`, `contrib/linguist-upstream/JULIAN_HANDOFF.md`.
2. Run: none required on lic after merge; Julian runs `bundle exec rake test` on linguist fork per `contrib/linguist-upstream/PATCH_INSTRUCTIONS.md`.
3. Then: merge WP1 (`feat/linguist-wp1-grammar`) and WP2 (`feat/linguist-wp2-samples`) before Julian executes WP7; agents do not touch github-linguist.
4. Blocked on: **WP3 usage volume** (human seeding + weekly search log); **WP7** Linguist PR (Julian committer only).

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Playbook | `docs/ecosystem/github-linguist.md` — prerequisites, parallel WPs, G0–G8, agent stop line | Doc review |
| Usage evidence | `docs/ecosystem/github-linguist-usage-evidence.md` — ~1220 global `extension:li`, 0 `org:li-langverse` at audit; human steps | Audit table dated 2026-05-25 |
| Patch bundle | `contrib/linguist-upstream/` — `languages-li.snippet.yml`, `heuristics-li.fragment.yml`, `PATCH_INSTRUCTIONS.md`, `README.md` | Paths listed |
| Handoff | `contrib/linguist-upstream/JULIAN_HANDOFF.md` — fork, git identity, PR template | Bold no-agent-committer rule |
| Changelog | `CHANGELOG.md` `[Unreleased]` entry | This file |

Links to WP1/WP2 paths (on their branches until merged):

- WP1 grammar: [`contrib/li-grammar/`](https://github.com/li-langverse/lic/tree/feat/linguist-wp1-grammar/contrib/li-grammar) (`feat/linguist-wp1-grammar`)
- WP2 samples: [`contrib/linguist-samples/Li/`](https://github.com/li-langverse/lic/tree/feat/linguist-wp2-samples/contrib/linguist-samples/Li) (`feat/linguist-wp2-samples`)

## Not changed (scope fence)

- No commits to `github-linguist/linguist` or Julian's fork from automation.
- WP1 grammar repo publish (`li-grammar` URL still TBD placeholder in patch instructions).
- WP2 sample files not copied onto this branch (remain on `feat/linguist-wp2-samples`).
- No claim that Linguist usage threshold (≥2000 indexed `.li`) is met.
- Linguist grammar submodule not added to lic vendor tree.

## Breaking changes

None.

## Security

N/A — documentation and draft YAML only; no runtime or trusted surface.

## Performance

N/A — no compiler or bench changes.

## Downstream

| Repo | Action |
|------|--------|
| github-linguist/linguist | Julian opens PR after WP1/2/3 gates |
| li-grammar (future) | Publish from WP1 before `script/add-grammar` |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **GitHub Linguist handoff (WP3/4/6/7):** playbook, usage-evidence process, `contrib/linguist-upstream/` patch bundle; Julian-only upstream PR — [2026-05-25-linguist-wp346-handoff.md](docs/release-notes/2026-05-25-linguist-wp346-handoff.md).
```
