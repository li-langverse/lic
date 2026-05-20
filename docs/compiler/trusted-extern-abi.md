# Trusted runtime ABI (`extern proc` ↔ C)

Li programs that talk to the OS link against **`runtime/li_rt.c`** and **`runtime/li_rt_net.c`**. The compiler does not emit syscalls yet; it emits **`call @symbol`** where the Li name equals the C symbol.

## API vs ABI (short)

| | **API** | **ABI** |
|---|--------|--------|
| Who cares | You, reading `.li` | Compiler + linker |
| Shape | `extern proc tcp_listen(port: int) raises Net -> int` | Registers, symbol `tcp_listen`, ELF layout |

## What to use in new software

1. **`import std.runtime.seam`** (or **`import net`**, which re-exports the seam via `packages/li-net`).
2. Call seam symbols (`tcp_listen`, `li_rt_sqrt`, …) — do **not** add new `extern proc` in your module.
3. If you need a new OS primitive: add C in `runtime/li_rt*.c`, declare once in **`std/runtime/seam.li`**, register in **`security/trusted-extern-manifest.toml`**, and extend **`compiler/types/trusted_extern.cpp`** manifest set.

## Compiler gate (`E0331`)

On `lic check` / `lic build`, **`check_trusted_extern_abi()`** runs per file:

- **`extern proc` allowed** only in `std/runtime/seam.li` and `std/bytes/bytes.li`.
- **Exempt** paths: `li-tests/`, `benchmarks/`, `examples/`, `bootstrap/` (negative tests, bench kernels, libc demos).
- Any other file that declares `extern proc` → **E0331** with hint to import `std.runtime.seam`.

Imported modules are checked when resolved (`import_resolve.cpp`).

## Link model (unchanged)

```text
lib.li  →  Mir CallExtern("tcp_listen")  →  LLVM call @tcp_listen  →  li_rt_net.c
```

No manifest entry → compile error in the seam file. Seam entry without C symbol → link error.

## Not in the seam

- **Compiler intrinsics** lowered without user `extern` (`echo` → `li_rt_print_int`, OpenMP, async helpers in `emit.cpp`).
- **Bench-only kernels** (`li_matmul_naive_kernel`, …) linked via `LI_EXTRA_C` — exempt paths only.
- **libc** (`puts`, `strcmp`) — tests/examples only; not part of the trusted runtime manifest.

## Related

- `runtime/li_rt.h` — C header mirror
- `security/trusted-extern-manifest.toml` — governance list
- `.cursor/rules/li-li-only-outside-lic.mdc` — product vs seam discipline
