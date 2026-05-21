# math

Spatial math for physics and rendering: `Vec2/3/4`, `Quat`, `Mat4`, `AABB`, array `dot`/`sum` helpers.

## API highlights

- `vec3`, `vec3_dot`, `vec3_cross`, `vec3_normalize`, `vec3_lerp`
- `quat_mul`, `mat4_mul_point`
- `array_dot_f64` / `array_sum_f64` (compiler `@` / `sum`)

## Build

```bash
lic build src/lib.li -o math
```

From the monorepo root, ensure `lic` is built: `./scripts/build.sh`.

## Traceability

| ID | Link |
|----|------|
| Package | `PKG-math` |
| Org repo | https://github.com/li-langverse/math |
| Governance | [Ecosystem governance](https://li-langverse.github.io/li-language/ecosystem/governance/) |

See `PUBLISH.md` and `docs/traceability.md`.

## License

Apache-2.0 OR MIT
