# Numerics in practice

How Li behaves on real projects: pick types and suffixes yourself, run `lic check` / `lic build`, read warnings and errors in the terminal. Below, **source** and **CLI output** are shown in separate windows (macOS-style) so you can see cause and effect.

**Related:** [Scalar precision](scalar-precision.md) · [Types and data](types-and-data.md) · [Examples gallery](../guide/examples-gallery.md)

---

## 1. Game timestep: `x` in `float32`

A 2D integrator keeps position **`x`** in single precision; forces stay in the same width.

**`game_step.li`**

```nim
type Vec2 = object
  public x: float32
  public y: float32

def step_x(x: float32, vx: float32, dt: float32) -> float32
  requires dt > 0.0f32
  ensures true
  decreases 0
=
  return x + vx * dt

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var pos: Vec2 = Vec2(x: 0.0f32, y: 0.0f32)
  var vx: float32 = 120.0f32
  var dt: float32 = 0.016f32
  pos.x = step_x(pos.x, vx, dt)
  return 0
```

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">Terminal — zsh</span>
</div>
<pre class="li-terminal__body"><code><span class="term-prompt">dev@macbook game %</span> <span class="term-cmd">lic check game_step.li</span>
<span class="term-ok">check ok</span> <span class="term-dim">(no diagnostics)</span>

<span class="term-prompt">dev@macbook game %</span> <span class="term-cmd">lic build game_step.li -o game_step --release</span>
<span class="term-ok">build ok → game_step</span></code></pre>
</div>

Suffixes match the type: `0.0f32`, `120.0f32`, `0.016f32`. Unsuffixed `3.14` defaults to **64-bit** float in the typechecker today.

---

## 2. Fixed-point: integer `x`, rescale to float for HUD

Simulation stores scaled position **`x`** as `int32`; only the HUD path uses `float32`.

**`hud_x.li`**

```nim
def x_to_screen(qx: int32, scale_k: int) -> float32
  requires scale_k == 16
  ensures true
  decreases 0
=
  return float32(qx) / 65536.0f32

def integrate_x(qx: int32, v_q: int32, dt_q: int32) -> int32
  requires true
  ensures true
  decreases 0
=
  return qx + (v_q * dt_q) / 65536i32

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var qx: int32 = 100000i32
  qx = integrate_x(qx, 5000i32, 256i32)
  var x_hud: float32 = x_to_screen(qx, 16)
  return int(x_hud)
```

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">Terminal — zsh</span>
</div>
<pre class="li-terminal__body"><code><span class="term-prompt">dev@macbook sim %</span> <span class="term-cmd">lic check hud_x.li</span>
<span class="term-path">hud_x.li:14:14</span>: <span class="term-warn">warning [W0501]</span>: integer multiply at 32-bit width can overflow; use a wider accumulator (e.g. int64) in fixed-point inner loops
  <span class="term-hint">hint: store products in int64, rescale with >> k or one explicit cast to float at the module boundary</span>
<span class="term-ok">check ok</span> <span class="term-dim">(exit 0 — warnings do not fail the build)</span></code></pre>
</div>

Wider product in the hot loop (recommended):

```nim
  var prod: int64 = int64(v_q) * int64(dt_q)
  return qx + int32(prod / 65536)
```

---

## 3. Width mismatch: when `x` is `float32` but the literal is not

Mixing `float64` literals into `float32` **`x`** without a suffix is rejected.

**`bad_x.li`**

```nim
def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var x: float32 = 1.0
  return 0
```

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">Terminal — zsh</span>
</div>
<pre class="li-terminal__body"><code><span class="term-prompt">dev@macbook learn %</span> <span class="term-cmd">lic check bad_x.li</span>
<span class="term-path">bad_x.li:7:18</span>: <span class="term-err">error [E0202]</span>: cannot mix float widths (64 and 32 bits) without explicit cast
<span class="term-dim">check failed (exit 1)</span></code></pre>
</div>

Fix: `var x: float32 = 1.0f32`.

---

## 4. Bytes, bits, and booleans (everyday shapes)

| You need | Li type | Example |
|----------|---------|---------|
| Flag / predicate | `bool` | `var alive: bool = true` |
| Raw byte 0–255 | `uint8` / `u8` | `var b: uint8 = 255u8` |
| UTF-8 text | `str` | `var name: str = "Li"` |
| I/O buffer (facade today) | `bytes` → typed as `str` in std | `import` from `std/bytes` |
| Quantized mask | `binary` | `var mask: binary = 0b10110000` |

**`types_smoke.li`**

```nim
def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var alive: bool = true
  var b: uint8 = 42u8
  var mask: binary = 0b11110000
  return int(b)
```

<div class="li-terminal-grid li-terminal-grid--2">

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">check</span>
</div>
<pre class="li-terminal__body"><code><span class="term-prompt">dev@macbook %</span> <span class="term-cmd">lic check types_smoke.li</span>
<span class="term-ok">check ok</span></code></pre>
</div>

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">JSON — lic check --format=json</span>
</div>
<pre class="li-terminal__body"><code><span class="term-cmd">lic check types_smoke.li --format=json</span>
{
  <span class="term-dim">"ok": true,</span>
  <span class="term-dim">"diagnostics": []</span>
}</code></pre>
</div>

</div>

`bool` is not a number: `if alive + 1` is a type error, unlike C++.

---

## 5. Literal suffixes at a glance

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">REPL-style — what the lexer infers</span>
</div>
<pre class="li-terminal__body"><code><span class="term-dim"># expression     →  type</span>
<span class="term-cmd">42</span>              →  int (i64)
<span class="term-cmd">42i32</span>           →  int32
<span class="term-cmd">255u8</span>           →  uint8
<span class="term-cmd">3.14</span>            →  float64
<span class="term-cmd">3.14f32</span>         →  float32
<span class="term-cmd">0b1011</span>          →  binary
<span class="term-cmd">true</span>            →  bool</code></pre>
</div>

Run the conformance file:

```bash
lic check li-tests/typecheck/literal_suffix_ok.li
```

---

## 6. Side-by-side: two modules, two precisions

Same formula, different **`x`** width — duplicate the module or use `type Real = float32` vs `float64` ([Precision polymorphism](precision-polymorphism.md)).

<div class="li-terminal-grid li-terminal-grid--2">

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">arcade — float32 x</span>
</div>
<pre class="li-terminal__body"><code><span class="term-cmd">type Real = float32</span>
<span class="term-cmd">var x: Real = 0.0f32</span>
<span class="term-cmd">lic check arcade.li</span>  <span class="term-ok">ok</span></code></pre>
</div>

<div class="li-terminal">
<div class="li-terminal__chrome">
<span class="li-terminal__dot li-terminal__dot--close"></span>
<span class="li-terminal__dot li-terminal__dot--min"></span>
<span class="li-terminal__dot li-terminal__dot--zoom"></span>
<span class="li-terminal__title">research — float64 x</span>
</div>
<pre class="li-terminal__body"><code><span class="term-cmd">type Real = float64</span>
<span class="term-cmd">var x: Real = 0.0</span>
<span class="term-cmd">lic check research.li</span>  <span class="term-ok">ok</span></code></pre>
</div>

</div>

Optional `li.toml` note (for humans/agents only):

```toml
[numerics]
default_float = "float32"
```

---

## Copy-paste sources in-repo

| Example | Path |
|---------|------|
| FP32 alias pattern | `li-tests/generics/precision_real_alias.li` |
| Fixed-point accum | `docs/language/examples/fixed-point-accum.li` |
| W0501 smoke | `li-tests/typecheck/fixed_point_mul_warn.li` |
| Suffixes | `li-tests/typecheck/literal_suffix_ok.li` |

---

## How to add terminal blocks in docs

Use `md_in_html` and the classes from `stylesheets/terminal.css`:

```html
<div class="li-terminal">… chrome …<pre class="li-terminal__body"><code>…</code></pre></div>
```

Spans: `term-prompt`, `term-cmd`, `term-warn`, `term-err`, `term-hint`, `term-ok`, `term-path`, `term-dim`.
