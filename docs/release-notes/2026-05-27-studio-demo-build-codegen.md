# Studio demo build + LLVM object-arg codegen (2026-05-27)

## Compiler

- **MIR call sites:** flatten `var` / object actuals passed as field access (`compose.layout`) or call results (`gui_viewport_selection_none()`), fixing LLVM "Incorrect number of arguments" on `li-studio-demo` link.
- **Allocas:** hoist `__li_o_*` locals to the entry block so conditional stores dominate loads (fixes "Instruction does not dominate all uses").

## li-studio-demo

- Build from repo root: `lic build --allow-open-vc --no-lean-verify packages/li-studio/src/main.li -o build/li-studio-demo`
- Runtime present loop exits 0 for default `STUDIO_DEMO_FRAMES=3` with mock host input.
- **Honesty:** `LIG_HOST_PRESENT=1` still labels `native_pixel_source=paint_blit` / SDL present host — not wgpu-rs readback.

## Scripts

- `./scripts/studio-shell-demo-present-loop.sh` — CI smokes + optional `STUDIO_SHELL_DEMO_BUILD_RUN=1`
- `./scripts/studio-shell-demo-interactive.sh` — SDL/mock input poll + per-tick demo binary; optional `LIG_HOST_PRESENT=1` present tick
