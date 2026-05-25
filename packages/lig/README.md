# lig (`import lig`)

PH-HW **WP4–5** — LKIR kernel launch, VRAM budget ledger, and gated `custom_lab` targets.

## Modules

| Path | Role |
|------|------|
| `src/lib.li` | Kernels, memory, custom, backend switch audit |
| `memory/lib.li` | HW-3 budget ledger slice |
| `custom/lib.li` | HW-4 target descriptors slice |
| `lkir/matmul_f32.li` | LKIR matmul pilot |

## Runtime FFI (WP4)

| Symbol | Role |
|--------|------|
| `li_rt_lig_backend_select_auto` | Pick cuda/hip/metal/wgpu |
| `li_rt_lig_kernel_run` | Launch catalog kernel by id |
| `li_rt_lig_kernel_last_validity_ratio` | CPU oracle validity ratio |

Implementations: `runtime/li_rt_lig.c`.

## Memory gate (HW-3)

- Default budget: **96 MiB** (`lig_memory_budget_mib()`).
- Tier estimate: **1024 B / particle**.
- Peak snapshot: `data/ph-hw/latest-lig-memory.json` via `scripts/ph-hw-refresh-lig-memory-json.sh`.

## Custom lab gate (HW-4)

- Lab id **`custom_lab_fpga`** → `lig_custom_lab_id_fpga() == 5`.
- `lig_custom_load_signed_driver` returns **0** on OSS builds.
- LKIR target descriptor v2: [lig-custom-targets.md](../../docs/game-dev/lig-custom-targets.md).

## SBOM (IMPORTANT tier)

| Component | Version / pin | License | Notes |
|-----------|---------------|---------|-------|
| `runtime/li_rt_lig.c` | in-tree | Apache-2.0 OR MIT | Host matmul oracle + backend probe |
| LKIR matmul pilot | `lkir/matmul_f32.li` | Apache-2.0 OR MIT | No vendor source strings |
| Custom lab driver slot | gated stub | — | OSS: load returns 0 |
| wgpu / CUDA / HIP / Metal | platform SDK | vendor | Trusted FFI when present path lands (WP3) |

## Smokes

```bash
lic check packages/lig/li-tests/smoke/builds.li
lic check packages/lig/li-tests/smoke/memory_budget.li
lic check packages/lig/li-tests/smoke/kernel_matmul_parity.li
```

See [docs/traceability.md](docs/traceability.md).
