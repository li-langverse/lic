# li-gpu

PH-HW GPU package — device backends, LKIR stub, wgpu smoke composable.

**Status:** stub (`gpu_workload_class_stub` → 0) until LKIR codegen and trusted wgpu FFI land.

**Import:** `import gpu` — `gpu_device_new`, `wgpu_smoke_entry`, `lkir_module_*`.

See [li-gpu-lkir-rfc.md](../../docs/game-dev/specs/li-gpu-lkir-rfc.md).

## Build

```bash
lic build src/lib.li -o li-gpu
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## License

Apache-2.0 OR MIT
