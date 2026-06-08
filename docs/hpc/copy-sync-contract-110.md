# Copy / sync contract — memory spaces (#110)

**Feeds:** [#15](https://github.com/li-langverse/lic/issues/15) decorator lowering · **G-gpu** address-space proofs

Cross-space data movement is **always named** in source. The compiler rejects reads from `Device` without a prior sync from `Host` (and vice versa when host consumes device results).

## Sync intrinsics (spec names)

| Intrinsic | Direction | Preconditions | MIR tag (planned) |
|-----------|-----------|---------------|-------------------|
| `@sync_device(view)` | Host → Device | `view` has `hostbuffer` or `View[..., Host, ...]` mirror | `mir_sync_host_to_device` |
| `@sync_host(view)` | Device → Host | Kernel on `Device` completed in same execution space | `mir_sync_device_to_host` |

**Not in v1:** implicit sync on `View` subscript; Kokkos-style `deep_copy` as a silent runtime call.

## Decorator stack → sync obligations

| Stack | `ExecutionSpace` | `MemorySpace` access | Required sync before device kernel |
|-------|------------------|--------------------|------------------------------------|
| `@cpu` `@parallel` | `OpenMP` | `Host` only | None |
| `@cpu` + `hostbuffer`/`devicebuffer` pair | `OpenMP` on host staging | `Host` writes, then `@sync_device` | **Yes** — explicit `@sync_device` |
| `@gpu` | `SYCL`/`Cuda` (reserved) | `Device` | `@sync_device` before launch; `@sync_host` before host checksum |
| `@serial` | `Serial` | `Host` | None |

## Cross-space read (compile_fail target)

```li
# compile_fail — device read without sync (post-#15 parser)
@gpu
def bad_device_read(buf: devicebuffer[float]) -> float
  # ERROR: cross-space read without @sync_host
  return buf[0]
```

Legal pattern:

```li
@cpu
def stage_heat(u_host: hostbuffer[float], u_dev: devicebuffer[float]) -> unit
  # ... fill u_host ...
  @sync_device(u_dev)  # copies from paired host mirror
  # @gpu kernel uses u_dev
  @sync_host(u_dev)    # before host checksum / verify.py oracle compare
```

## Layout ABI (#128)

Sync copies respect `Layout` / stride from [#128](https://github.com/li-langverse/lic/issues/128). Until ABI freezes, tier-2 pilot uses **contiguous** `hostbuffer`/`devicebuffer` only (no strided `ndview` in stage 2).

## Telemetry

`lic build --dump-mir` will list `mir_sync_*` after #15 lands. Until then, contract is **spec + docs**; gates are `li-tests/hpc/memory_spaces_enum_ok.li` and migration checklist on `heat_equation_2d`.
