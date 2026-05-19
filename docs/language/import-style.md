# Import style — easy dotted modules

**Goal:** imports read like other modern languages — `physics.relativity`, not `li_std_physics_relativity`.

## Preferred (ergonomic)

```li
import physics.relativity
import physics.runtime
import math
import math.numerics
import ui
import scene
import io
import csv
```

## Also valid (stdlib tree)

```li
import std.physics.relativity
import std.math
import std.io
import std.csv
```

Maps to files under `std/` (e.g. `std/physics/relativity.li`).

## Legacy (workspace / mirrors)

```li
import li_std_physics_relativity   # still resolves via package name
import li_httpd
```

Use **only** in generated code or until facades cover your package.

## Package metadata

Official packages set in `li.toml`:

```toml
[package.metadata.li]
import_name = "physics.relativity"
```

Run `python3 scripts/apply-import-names.py` after adding a package.

## Rules for new modules

| Domain | Pattern | Example |
|--------|---------|---------|
| Physics | `physics.<area>` | `physics.fluids` |
| Math | `math` or `math.<area>` | `math.numerics` |
| UI / scene | `ui`, `scene` | `import ui` |
| IO / data | `io`, `csv` | `import csv` |
| Network | `net`, `net.httpd` | `import net.httpd` |

**Avoid:** `li-std-*` in user-facing sample code and docs.

## Compiler

`import_resolve.cpp` resolves ergonomic names → `std/*` facades → workspace `import_name` → legacy snake names.
