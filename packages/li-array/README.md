# li-array

Typed ndarray descriptors for PH-ML: shape, strides, dtype, flat/nested storage — with **mathematically valid broadcasting only** (no silent 2-vs-4 promotion).

See [li-array-rfc.md](../../docs/game-dev/specs/li-array-rfc.md).

```li
import liarray
import ml  # transitive via li-ml dependency

var a: ArrayDesc = li_array_desc_2d(4, 4, 8)
var af: array[64, float]
# ...
li_array_matmul_f32(a, af, b, bf, c)
```

Smoke tests: `li-tests/smoke/`.
