---
name: li-error-catalog
description: Add Li compiler diagnostics with stable E#### codes. Use when adding diag_error or editing error_codes.hpp or docs/language/errors.md.
---

# Li error catalog

1. Add `ErrorCode` in `compiler/diagnostics/include/li/error_codes.hpp`.
2. Add row to `docs/language/errors.md`.
3. Call `diag_error(bag, loc, ErrorCode::…, message, hint)`.
4. Add `compile_fail` test or extend `li-tests/tooling/error_codes_smoke.sh`.
