# Examples gallery

Copy these into a `.li` file and run `lic build file.li -o out`.

## Hello

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  echo "Hello from Li"
  return 0
```

## Float arithmetic

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var x: float = 1.5
  var y: float = 2.25
  var z: float = x + y
  return 0
```

## Fixed-size array

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var data: array[4, int]
  var i: int = 0
  while i < 4
    data[i] = i
    i = i + 1
  return 0
```

## SIMD micro-loop

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var x: float = 0.001
  var acc: float = 0.0
  var i: int = 0
  while i < 100000
    var v: simd[f64, 4] = __li_simd_splat_f64(x)
    var p: simd[f64, 4] = __li_simd_mul_f64(v, v)
    acc = acc + __li_horiz_sum_f64(p)
    x = x + 0.000001
    i = i + 1
  return 0
```

## Parallel zeroing

```nim
proc main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var buf: array[8, float]
  var i: int = 0
  while i < 8
    buf[i] = 1.0
    i = i + 1
  parallel for j in 0..<8
    requires disjoint_elem(j, buf)
    decreases 8 - j
  =
    buf[j] = 0.0
  return 0
```

## Repository paths

| Example | Path |
|---------|------|
| Hello | `examples/hello.li` |
| Arrays | `examples/arrays.li` |
| Tetris (game) | `examples/tetris/main.li` |
| SIMD benchmark | `benchmarks/tier1_micro/simd_dot/li/main.li` |
| MD + parallel | `benchmarks/tier2_physics/md_lennard_jones/li/main.li` |
