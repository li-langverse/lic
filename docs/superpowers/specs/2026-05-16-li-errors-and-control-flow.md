# Li errors & control flow (normative target)

**Date:** 2026-05-16 · **Status:** Planning (slices in `lic`)

See [Error catalog](../../language/errors.md) for stable `E####` codes.

## User-defined errors (target)

```nim
error NotFound: "no row for id {id}"
proc load(id: int) -> Row
  raises NotFound
  requires id >= 0
  ensures result.id == id
=
  raise NotFound(id=id)
```

| Feature | Status |
|---------|--------|
| `error Name: "…"` | **Parse** — `li-tests/errors/parse_error_decl.li` |
| `raise` / `throws` on errors | Spec only |
| `type AppError = …` sum | Spec only |

## Warnings

- `warning` / `@warning` — visible by default; `lic check --deny-warnings` (stub) for CI.

## Control flow

| Construct | Status |
|-----------|--------|
| `break` / `continue` in `while`, `for` | **Implemented** |
| `for i in a..<b:` | **Implemented** |
| `switch` | Spec only |
| `try` / `catch` / `finally` | Spec only — must not bypass Lean/contracts |

Strict-by-default: exception paths need proof obligations (G-errors).
