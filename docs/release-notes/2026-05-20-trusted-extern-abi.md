# Trusted runtime ABI in the compiler

## Summary

Adds `std/runtime/seam.li` as the single Li declaration surface for `runtime/li_rt.c` and `li_rt_net.c`, plus compiler gate **E0331** so new product code imports the seam instead of declaring ad hoc `extern proc`.

## Agent continuation

1. **Read:** `docs/compiler/trusted-extern-abi.md`, `std/runtime/seam.li`, `compiler/types/trusted_extern.cpp`.
2. **Run:** `export LI_REPO_ROOT=<lic-checkout>`; `lic check packages/li-net-httpd/src/lib.li`; `./scripts/check-trusted-extern.sh`.
3. **Then:** shrink `httpd_drain_slot_i` C logic back into Li when perf allows; sync manifest via script from `li_rt.h`.
4. **Blocked on:** push 403 for `cursor[bot]` if applicable.

## Changed

| Path | Evidence |
|------|----------|
| `std/runtime/seam.li` | Canonical trusted `extern proc` list |
| `packages/li-net/src/lib.li` | `import std.runtime.seam` only |
| `compiler/types/trusted_extern.cpp` | E0331 gate + manifest set |
| `compiler/lic/main.cpp` | Calls `check_trusted_extern_abi` |
| `security/trusted-extern-manifest.toml` | Governance manifest |
| Physics/math packages | Import seam instead of duplicate `li_rt_sqrt` extern |

## Not changed

- Link model (still `CallExtern` → C symbol name).
- Bench/kernel `extern` in `benchmarks/` (exempt paths).
- Raw syscall emission from Li codegen (future work).

## Breaking

New `extern proc` outside seam + exempt paths fails **E0331** at `lic check` / `lic build`.

## Security

Narrows trusted creep: undeclared FFI declarations rejected in product paths.

## Performance

N/A

## Downstream

Set **`LI_REPO_ROOT`** to the `lic` checkout root so `import std.runtime.seam` resolves (`std/runtime/seam.li`).
