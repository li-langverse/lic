# Li documentation (`lic` tree)

| | |
|---|---|
| **Handbook index** | [docs/handbook/README.md](handbook/README.md) |
| **Plan map** | [docs/ecosystem/plan-cross-links.md](ecosystem/plan-cross-links.md) |
| **Published language site** | [li-langverse.github.io/li-language](https://li-langverse.github.io/li-language/) |
| **Edit user-facing Pages** | [github.com/li-langverse/lic-docs](https://github.com/li-langverse/lic-docs) |
| **Compiler** | [github.com/li-langverse/lic](https://github.com/li-langverse/lic) (this repo) |

This `docs/` directory is kept in `lic` for compiler CI (Lean semantics under `docs/semantics/`, plan-loop gates, release-note links in `CHANGELOG.md`). **User-facing doc edits should land in `lic-docs` first** when the split site is authoritative.

Build the site locally from a sibling checkout:

```bash
cd ../lic-docs && ./scripts/build-docs.sh
```

Or from `lic`: `./scripts/build-docs.sh` (delegates to `../lic-docs` when present).
