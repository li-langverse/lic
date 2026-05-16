# Li compiler error catalog

**Audience:** Li users and contributors adding diagnostics in `lic`.  
**Source of truth:** `compiler/diagnostics/include/li/error_codes.hpp`

Every user-facing error uses a stable **`E####`** code, plain-language **message**, and **hint**.  
Human: `file:line:col: error [E0301]: …` plus `hint: …`.  
JSON (`lic check --format=json`): `"code":"E0301"`, `"fix_hint":"…"`.

## Catalog (v1)

| Code | Category | Message (template) | Fix hint |
|------|----------|-------------------|----------|
| **E0101** | parse | Indentation problem. | Spaces only; +2 per block level after `:`. |
| **E0201** | type | Index outside provable array bounds. | Constant index, refinement loop var, or `requires` proof. |
| **E0202** | type | Type mismatch. | Fix types or use proved conversion. |
| **E0301** | contract | Missing `requires` on proc. | Add `requires` above `=`. |
| **E0302** | contract | Missing `ensures` on proc. | Add `ensures` above `=`. |
| **E0310** | borrow | Borrow conflict. | End active borrows before reuse. |
| **E0311** | borrow | Use after move. | Use new owner or borrow earlier. |
| **E0320** | policy | `parallel for` needs disjoint proof. | `requires disjoint_elem(...)` or `@parallel(disjoint=…)`. |
| **E0321** | policy | `@parallel` missing `disjoint=`. | `@parallel(disjoint=disjoint_elem(…))`. |
| **E0330** | policy | Stdlib name shadow. | Rename or define under `std/`. |
| **E0340** | policy | `Any` forbidden. | Concrete or generic type. |
| **E0350** | policy | Parallel shared-memory overlap. | Disjoint proof or private buffers. |
| **E0401** | control | `break` outside loop. | Move into `while`/`for`. |
| **E0402** | control | `continue` outside loop. | Move into `while`/`for`. |

## Related

- [Errors & control flow spec](../superpowers/specs/2026-05-16-li-errors-and-control-flow.md)
- [Provability gaps — G-errors](../verification/provability-gaps.md)
