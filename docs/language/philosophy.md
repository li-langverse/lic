# Li language philosophy — simplicity and readable code

**What this page is for:** How Li should *feel* when you read and write it — close to Python’s “code is read more than written,” with Li’s proof gate on top.

## One sentence

**Li does what it reads like it does** — names and layout should be obvious enough that pseudocode and real Li are almost the same, and the compiler proves the promises you wrote in plain language.

## What we take from Python (PEP 20 and practice)

Python’s [Zen of Python (PEP 20)](https://peps.python.org/pep-0020/) is not a checklist to copy; it is a **bias toward the reader**. Li adopts the same bias:

| Aphorism | Li reading |
|----------|------------|
| **Simple is better than complex** | Prefer one clear `proc` over clever metaprogramming. Sugar must desugar to a small core the prover understands. |
| **Readability counts** | If a teammate cannot skim it in one pass, rename or split it — proof obligations do not excuse opaque names. |
| **Explicit is better than implicit** | Effects (`raises IO`), contracts (`requires` / `ensures`), and types are written out — no hidden globals, no `Any`. |
| **There should be one obvious way** | One idiomatic import (`import physics.runtime`), one obvious loop shape with `decreases`, one obvious parallel form with `disjoint`. |
| **If the implementation is hard to explain, it’s a bad idea** | Applies to **language design** and **your** code: if you cannot say what a `proc` does in one English sentence, refactor. |
| **Namespaces are a great idea** | Dotted modules (`math.numerics`, `physics.fluids`) and small packages — see [import style](import-style.md). |

Python also teaches **practicality beats purity** — Li allows that *after* proof: e.g. `--release` for speed, optional `--numerically-stable` for FP — never by skipping the proof gate.

## Li’s ordering (proof does not fight simplicity)

```text
1. Correct   — types, contracts, memory, termination (lic build)
2. Clear     — reads like prose; names match the domain
3. Fast      — LLVM, SIMD, parallel — only after 1 and 2 for shipped code
```

**Correct** is stricter than Python. **Clear** should be *easier* than C++ template soup: indentation, familiar types, domain words in identifiers.

## Read like prose

Good Li reads as **short sentences**:

```li
proc advance_orbit(body: Body, dt: float) -> unit
  requires dt > 0
  ensures energy_drift(body) < max_drift
  decreases 0
=
  var force: Vec3 = gravity_from(body.position)
  body.velocity = body.velocity + force * dt
  body.position = body.position + body.velocity * dt
```

A reader should infer: *for a positive timestep, advance velocity then position, and energy drift stays bounded.*

Contracts are **promises in English-shaped logic**, not magic comments:

- `requires dt > 0` — “only call with positive dt”
- `ensures result >= 0` — “never returns negative”
- `decreases n` — “this loop gets closer to done”

## Naming (packages, types, functions, variables)

### Packages and imports

| Do | Don’t |
|----|--------|
| `import physics.relativity` | `import li_std_physics_relativity` |
| GitHub repo `li-physics-relativity` | `li-std-physics-relativity` (legacy) |

Rule: **import path = how you talk about the domain.** See [import-style.md](import-style.md) and [repo naming](../ecosystem/repo-naming.md).

### Functions (`proc`)

- **Verb phrases:** `step_world`, `load_scene`, `compute_forces`, `normalize_velocity`
- **Say what, not how:** `merge_collisions` not `do_pass_2`
- **Units in the name when it matters:** `distance_meters`, `angle_rad`

### Types and objects

- **Nouns:** `Body`, `PhysicsWorld`, `CollisionPair`
- **Fields are plain:** `position`, `mass`, `velocity` — not `p`, `m`, `v` in public APIs

### Variables

- **Short scope → short name is OK:** loop index `i`, `j`
- **Long scope → full words:** `accumulated_energy`, `time_step`
- **Booleans read as questions:** `is_visible`, `has_collision`, `can_merge`

### Casing

- **snake_case** for `proc`, variables, modules (like Python)
- **PascalCase** for `type` / `object` names when we use them for types

## Pseudocode ↔ Li

Li is designed so design docs can stay almost literal:

| Pseudocode | Li |
|------------|-----|
| `for each body in world: apply gravity` | `while i < n` + indexed loop or future `for` when specified |
| `distance = sqrt(dx*dx + dy*dy)` | `li_rt_hypot(dx, dy)` or explicit ops |
| `require dt > 0` | `requires dt > 0` on the `proc` |

If pseudocode needs a footnote to map to Li, the **surface syntax** should be improved (RFC), not the pseudocode.

## What we avoid (anti-python in the good sense)

| Pattern | Why |
|---------|-----|
| `Any`, unchecked `cast`, `unsafe` | Breaks proof and “what you read is what runs” |
| Hungarian notation (`strName`, `iCount`) | Noise; types are static |
| Abbreviation soup (`cfg`, `mgr`, `tmp` in APIs) | Saves typing, costs comprehension |
| Clever one-liners that hide effects | Effects must stay explicit |

## For agents and reviewers

When changing Li code or docs:

1. Read the `proc` names aloud — do they sound like steps in a story?
2. Prefer extending [easy imports](../../.cursor/rules/li-easy-imports.mdc) over new opaque module prefixes.
3. Do not trade readability for “fewer lines” in examples users copy.

## Related

- [Language handbook overview](overview.md)
- [Control flow and functions](control-flow-and-functions.md)
- [Language design spec](../superpowers/specs/2026-05-14-li-language-design.md) — normative pillars
- [Import style](import-style.md)
- Python: [PEP 20](https://peps.python.org/pep-0020/), [PEP 8](https://peps.python.org/pep-0008/) (style guide for names and layout)
