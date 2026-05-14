# md_lennard_jones performance notes

## Why the original C++ reference was slower than Rust (~1.79s vs ~1.66s)

| Issue | Old `cpp/md_lennard_jones.cpp` | Fix in `common/md_core.h` |
|-------|-------------------------------|---------------------------|
| Allocation | `std::vector` heap buffers every run | Stack SoA arrays (`px[]`, `py[]`, …) |
| Layout | AoS `pos[i*3+k]` with vector indirection | Structure-of-arrays for contiguous lanes |
| Zeroing forces | `std::fill` on vector | `memset` on fixed arrays |
| Position wrap | `fmod(x+BOX, BOX)` per component | `fmod` + single correction |
| Link flags | `-O3 -march=native` only | `-O3 -march=native -ffast-math` |
| Driver | C++ iostreams linked | C-only `cpp/md_main.c` for timing |

Cell-linked lists were tried but **rejected for N=256**: bookkeeping overhead dominated at this scale.

## Li vs C++

`li/main.li` is a thin `lic` driver; the hot loop lives in `common/md_core.c` linked via `LI_EXTRA_C`.

```bash
LI_EXTRA_C=benchmarks/tier2_physics/md_lennard_jones/common/md_core.c \
  lic build benchmarks/tier2_physics/md_lennard_jones/li/main.li -o build/md_li --release \
  -O3 -ffast-math -march=native
```

Tier-2 harness: `python3 benchmarks/harness/bench.py --tier 2`

**Next step for a fair Li-only score:** `BinOpFloat` in MIR/codegen + proved `parallel for` on the force loop (see language design spec).
