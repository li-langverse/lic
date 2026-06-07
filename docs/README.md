# Li documentation (`lic` tree)

Handbook and site content for Li lives in a **separate repository** so GitHub Pages can use its own subdomain (e.g. `docs.yourdomain.com`).

| | |
|---|---|
| **Edit the handbook** | [github.com/li-langverse/lic-docs](https://github.com/li-langverse/lic-docs) |
| **Published site** | [li-langverse.github.io/lic-docs](https://li-langverse.github.io/lic-docs/) |
| **Compiler** | [github.com/li-langverse/lic](https://github.com/li-langverse/lic) (this repo) |

This `docs/` directory is kept in `lic` for compiler CI (Lean semantics under `docs/semantics/`, plan-loop gates, release-note links in `CHANGELOG.md`). **User-facing doc edits should land in `lic-docs` first**; we will converge on a git submodule so this tree tracks that repo automatically.

Build the site locally from a sibling checkout:

```bash
cd ../lic-docs && ./scripts/build-docs.sh
```

Or from `lic`: `./scripts/build-docs.sh` (delegates to `../lic-docs` when present).
