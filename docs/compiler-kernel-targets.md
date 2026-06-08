# Li compiler — freestanding kernel targets

**lic** is the Li compiler. Kernel **source** lives in [**lik**](https://github.com/li-langverse/lik);
normative kernel ABI: `lik/docs/kernel-abi.md`.

## Freestanding targets (M1+)

| Triple | Role |
|--------|------|
| `i686-unknown-none` | M1 primary bring-up |
| `x86_64-unknown-none` | planned |
| `aarch64-unknown-none` | planned |

Build kernel artifacts from **lik**:

```bash
export LIC_ROOT=/path/to/lic
export LIK_ROOT=/path/to/lik
cd /path/to/lik
bash scripts/build-hello-kern.sh
bash scripts/smoke-hello-kern.sh ../build/hello_kern.elf
```

Serial smoke is **`lic smoke-kernel <elf>`** — Li-native verification: lic loads the
freestanding ELF32, interprets i686 `@hw` (`outb` → COM1 0x3F8, `hlt`), no QEMU/Python.
Wrapped by `lik/scripts/smoke-hello-kern.sh` for gates and `dev-vm.sh`.

## `@hw` intrinsics (compiler lowering)

Kernel drivers use `@hw` intrinsics; **lic** lowers them. No whitelist of allowed port
numbers at compile time — full-width port/phys addresses for the target arch.

M1 minimum surface:

| Intrinsic | Lowering |
|-----------|----------|
| `@hw.outb(port, value)` | x86 `outb` |
| `@hw.hlt()` | x86 `hlt` |

Additional intrinsics (MMIO, IRQ, fences) are added to the audited catalog as milestones land.

## What is not in lic

- Kernel application source (`hello_kern`, drivers, MM) → **lik**
- OS distro tooling (`dev-vm.sh`, gates) → **li-os**
