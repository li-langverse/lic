# Li for VS Code / Cursor

Thin pointer: the installable extension lives in **[`../li-grammar/`](../li-grammar/)** (grammar + `package.json` in one package).

## Quick install

```bash
cd contrib/li-grammar
code --install-extension .
# or, if the Cursor CLI is on PATH:
cursor --install-extension .
```

Reload the editor, open any `.li` file, and set language mode to **Li** if needed.

## Verify

From `lic` repo root:

```bash
./contrib/li-grammar/scripts/smoke-grammar.sh
```

## Linguist

This repo does **not** ship GitHub Linguist recognition yet. After WP1 grammar stabilizes, WP6 vendors `contrib/li-grammar/syntaxes/li.tmLanguage.json` into [github/linguist](https://github.com/github/linguist).
