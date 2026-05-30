# Li TextMate grammar (WP1)

Canonical **TextMate** grammar and **VS Code / Cursor** language contribution for Li (`.li`), maintained in the `lic` repo for a future [GitHub Linguist](https://github.com/github/linguist) vendor pass (**WP6**). Li is **not** listed on Linguist yet; this package is the upstream source only.

## Layout choice: `contrib/li-grammar/`

We use **`contrib/`** (not `editor/`) to match compiler-repo convention: editor assets live beside the language implementation without implying a separate product repo. The VS Code extension manifest and grammar ship in one folder; install docs for Cursor are in [`../li-vscode/README.md`](../li-vscode/README.md).

| Path | Role |
|------|------|
| `syntaxes/li.tmLanguage.json` | TextMate grammar (Linguist-compatible) |
| `language-configuration.json` | Comments `#`, brackets, off-side indent hints |
| `package.json` | VS Code `contributes.languages` + `contributes.grammars` |
| `scripts/smoke-grammar.sh` | JSON validity + lexer fixture path checks |

Keywords align with `compiler/lexer/include/li/token.hpp` and the doc-shareable highlighter in `benchmarks/scripts/render-li-code-image.py` (`LiLexer`).

## Install (local dev)

From this directory:

```bash
# Cursor or VS Code — symlink into extensions dir
code --install-extension .   # or: cursor --install-extension .
```

Or copy/symlink `contrib/li-grammar` into your extensions folder and reload the window.

## Smoke check

From repo root:

```bash
./contrib/li-grammar/scripts/smoke-grammar.sh
```

## License

MIT — see [LICENSE](LICENSE).

## Downstream (WP6)

When ready, open a PR to [github/linguist](https://github.com/github/linguist) that vendors `syntaxes/li.tmLanguage.json` and adds `.li` to `languages.yml`. Do **not** claim Li is on Linguist until that PR merges.
