# Welcome to Li

**理** — principle, reason.

Li helps you write programs that are **checked before they run**: types, memory, loops that end, and parallel work that does not trample shared data. When the check succeeds, you get fast native code with **vectors** and **many CPU cores** built in.

<div class="grid cards" markdown>

-   :material-hand-wave:{ .lg .middle } **New here?**

    ---

    Start with [Hello world](guide/hello-world.md) and the [Examples gallery](guide/examples-gallery.md).

-   :material-book-open-variant:{ .lg .middle } **Learn the language**

    ---

    [Language handbook](language/overview.md) — types, numbers, SIMD, parallel, contracts.

-   :material-cog:{ .lg .middle } **How the compiler works**

    ---

    [Build pipeline](compiler/build-pipeline.md) and [Why provable](compiler/why-provable.md).

-   :material-shield-check:{ .lg .middle } **Trust but verify**

    ---

    [All tests](testing/overview.md) and [Security audits](testing/security.md).

</div>

## Three promises

| | |
|---|---|
| **Prove it** | `lic build` fails if proofs do not close. |
| **Write it easily** | Readable syntax; Python-like types without `Any`. |
| **Run it fast** | LLVM + SIMD + `parallel for` after proof. |

## Quick example

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hello from Li"
  return 0
```

## Install and build

[Getting started — tools](guide/getting-started-tools.md)

## Full documentation map

| Section | Contents |
|---------|----------|
| [Guide](guide/hello-world.md) | Tutorials and copy-paste examples |
| [Language](language/overview.md) | Every type, feature, and rule |
| [Compiler](compiler/build-pipeline.md) | Compile-time behavior |
| [Testing](testing/overview.md) | Suites, fuzz, CI, audits |
| [Reference spec](superpowers/specs/2026-05-14-li-language-design.md) | Normative design (technical) |

## Project status

The compiler is under active development. Phase tracker: [Master plan](superpowers/plans/2026-05-14-li-master-plan.md). Native HPC (SIMD + OpenMP): [Phase 7 plan](superpowers/plans/2026-05-14-phase-07-native-hpc.md).
