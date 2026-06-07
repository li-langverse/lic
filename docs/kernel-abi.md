# Li kernel ABI (M1 stub)

Freestanding kernel target for LiOS M1. This document is the normative ABI stub for
Phase 0; Phase 1 fills in link rules and `@hw` serial bring-up.

## Target triple

| Field | Value |
|-------|--------|
| OS | none (freestanding) |
| Environment | kernel |
| Arch | x86_64 (M1 primary), aarch64 (optional Phase 2 row) |
| Endian | little |

Suggested LLVM triple: `x86_64-unknown-none`.

## Proof pillar

Kernel code is compiled with `lic build` and must carry proof certificates like userspace
targets. No `Any`, no unproved `unsafe`, and no silent narrowing conversions.

## Hardware intrinsics (`@hw`)

Kernel I/O uses **`@hw` intrinsics only** — no C or assembly in the kernel link graph.

Phase 1 minimum surface for `hello_kern`:

| Intrinsic | Purpose |
|-----------|---------|
| `@hw.outb(port, value)` | Write byte to I/O port (x86_64 COM1) |
| `@hw.hlt()` | Halt until interrupt |

Serial bring-up (x86_64 QEMU `-serial stdio`):

1. Program COM1 (port `0x3F8`) for 8N1.
2. Write `hello_kern\n` via `@hw.outb`.
3. `@hw.hlt()` in the idle loop.

## Link model (Phase 1)

- Entry: `_start` in `.text.boot`
- No libc, no pthread, no trusted C runtime objects
- Gate: `li-os/scripts/gates/check-zero-c.sh` on the produced ELF

## Build invocation (M1 Phase 1)

```bash
lic build --target i686-unknown-none --allow-open-vc --no-lean-verify \
  -o hello_kern.elf kernel/hello_kern.li
# or: bash scripts/build-hello-kern.sh
```

Phase 1 ships **i686 multiboot1** freestanding link (QEMU x86 guest). x86_64 long-mode
bring-up is Phase 1b follow-up.

## Serial smoke

```bash
python3 scripts/hello-kern-serial-smoke.py hello_kern.elf
bash scripts/gates/phase-p0-hello-kern-gate.sh   # in li-os checkout
```

## Related repos

- **li-os** — QEMU dev VM (`scripts/dev-vm.sh --smoke`), phase gates
- **lic** — compiler freestanding target + `@hw` lowering

## M1 phases

| Phase | ABI deliverable |
|-------|-----------------|
| 0 (this stub) | Document triple, `@hw` serial surface, zero-C policy |
| 1 | Working freestanding link + `hello_kern` |
| 2 | Documented CI + dev-vm smoke for x86_64 (aarch64 optional) |
