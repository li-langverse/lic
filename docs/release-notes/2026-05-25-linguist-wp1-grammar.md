# Release notes: Linguist WP1 — Li TextMate grammar

**Status:** Ready for review  
**Repo:** li-langverse/lic  
**PR:** feat/linguist-wp1-grammar  
**PH / REQ:** Linguist WP1 (grammar source), WP5 (editor scaffold)  
**Author:** agent

---

## Summary (one sentence)

Adds canonical TextMate grammar and a VS Code/Cursor extension scaffold under `contrib/li-grammar/` so a future Linguist WP6 PR can vendor `.li` highlighting without claiming upstream recognition yet.

## Agent continuation (required)

1. Read: `contrib/li-grammar/README.md`, `contrib/li-grammar/syntaxes/li.tmLanguage.json`, `compiler/lexer/include/li/token.hpp`.
2. Run: `./contrib/li-grammar/scripts/smoke-grammar.sh`; install locally with `code --install-extension contrib/li-grammar` and open `li-tests/lexer_parser/fib.li`.
3. Then: WP6 — open PR to [github/linguist](https://github.com/github/linguist) vendoring `li.tmLanguage.json` + `languages.yml` entry (human review).
4. Blocked on: **none** for WP1; Linguist merge is human-gated and must not be claimed until merged.

## Changed (specific)

| Area | What | Evidence |
|------|------|----------|
| Grammar | TextMate `source.li` — comments `#`, strings, numbers, `..<`, contracts, `def`/`proc`, `import`, decorators `@`, `parallel for`, keywords from `token.hpp` | `contrib/li-grammar/syntaxes/li.tmLanguage.json` |
| Editor | `package.json` language id `li`, extension `.li`, `language-configuration.json` off-side indent | `contrib/li-grammar/package.json` |
| Docs | MIT LICENSE, README (WP6 link, `contrib/` layout rationale) | `contrib/li-grammar/README.md`, `LICENSE` |
| Cursor pointer | Install steps only | `contrib/li-vscode/README.md` |
| CI smoke | JSON validate + three lexer fixtures exist | `contrib/li-grammar/scripts/smoke-grammar.sh` |

## Not changed (scope fence)

- **GitHub Linguist upstream** — no PR to `github/linguist`; Li is **not** on Linguist yet.
- **Compiler lexer/parser** — no `compiler/lexer` edits.
- **lic check / runtime / emit** — unchanged.
- **Published VS Marketplace extension** — local/dev install only.

## Breaking changes

None.

## Security

N/A — static grammar JSON and editor manifest only; no runtime or network surface.

## Performance

N/A — editor highlighting only; no compiler or bench impact.

## Downstream

| Repo | Action |
|------|--------|
| linguist (WP6) | Vendor `syntaxes/li.tmLanguage.json` when ready |
| lip / lit / lis | N/A |

## CHANGELOG entry (paste into Unreleased)

```markdown
### Added
- **Linguist WP1 — Li TextMate grammar:** `contrib/li-grammar/` (`.li` syntax, VS Code/Cursor extension manifest, smoke script); install pointer `contrib/li-vscode/` — [2026-05-25-linguist-wp1-grammar.md](docs/release-notes/2026-05-25-linguist-wp1-grammar.md).
```
