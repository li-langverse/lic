# LKIR syntax (PH-HW Wave 2 pilot)

**Status:** Pilot schema v1 — textual `.lkir` modules under `packages/lig/lkir/`.

## Line kinds

| Opcode | Meaning | Example |
|--------|---------|---------|
| `tile` | Launch tile geometry `(tx, ty, tz)` | `tile 4 4 1` |
| `load_a` | Stage A tile from global memory | `load_a f32` |
| `load_b` | Stage B tile from global memory | `load_b f32` |
| `barrier` | Workgroup sync | `barrier` |
| `store_c` | Write C tile to global memory | `store_c f32` |
| `end` | Module terminator (optional) | `end` |

Comments start with `;`. Blank lines are ignored.

## Worked example

See `matmul_f32.lkir` — six non-comment lines matching `lkir_matmul_module_line_count()` in `lkir/lib.li`.

## Lowering (honest stubs)

| Target | Env gate | Runtime status |
|--------|----------|----------------|
| SPIR-V / Vulkan | — | `lig_backend_vulkan_spirv()` id 5; `li_rt_lig_kernel_run` returns `-1` until WP-HW-06 |
| CUDA PTX | `LIG_EMIT_CUDA=1` | `bid==1` returns `-1` without env |
| HIP / Metal | `LIG_EMIT_HIP=1`, `LIG_EMIT_METAL=1` | not wired in Wave 2 |

RFC: [lig-rfc.md](../../docs/game-dev/specs/lig-rfc.md)
