# Compiler error and warning codes

Stable **E** codes are errors (fail `lic check`). **W** codes are warnings (printed, exit 0 today).

## Numerics / fixed-point (warnings)

| Code | Agent id | When |
|------|----------|------|
| W0501 | `numerics.int_mul_overflow` | `int` multiply at ≤32-bit width |
| W0502 | `numerics.int_div_trunc` | integer `/` (truncates; prefer `//` or multiply+shift) |

## Contracts (warnings)

| Code | Agent id | When |
|------|----------|------|
| W0601 | `contract.trivial_ensures` | `ensures true` on a value-returning `def` (default: warn; strengthen postcondition) |

## Contracts (errors, strict mode)

| Code | Agent id | When |
|------|----------|------|
| E0303 | `contract.trivial_ensures` | Same as W0601 when **`lic build --strict-contracts`** or **`LI_STRICT_CONTRACTS=1`** |

`extern proc` may still use `ensures true` for opaque FFI. `def` with **`-> unit`** may use `ensures true` (no `result`).

## Type and policy (errors)

| Code | Agent id | When |
|------|----------|------|
| E0101 | `parse.indent` | Bad indentation |
| E0201 | `type.index` | Bad index |
| E0202 | `type.mismatch` | Type mismatch (incl. int/float mix, width mix) |
| E0301 | `contract.requires` | Missing `requires` |
| E0302 | `contract.ensures` | Missing `ensures` |
| E0310 | `borrow.conflict` | Borrow conflict |
| E0330 | `resolve.shadow` | Stdlib shadow |

Full JSON envelope: [diagnostic-v1 schema](../schemas/diagnostic-v1.json).
