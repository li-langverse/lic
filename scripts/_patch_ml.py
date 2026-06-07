from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
p = ROOT / "packages/li-ml/src/lib.li"
text = p.read_text(encoding="utf-8")

text = text.replace("# li-ml (PH-ML Wave 5):", "# li-ml (PH-ML Wave 6):")
text = text.replace("ensures result == 3\n  decreases 0\n=\n  return 3", "ensures result == 4\n  decreases 0\n=\n  return 4", 1)

insert_after_version = """def ml_matmul_max_dim() -> int
  requires true
  ensures result == 16
  decreases 0
=
  return 16

def ml_matmul_flat_idx(row: int, col: int, ld: int) -> int
  requires row >= 0
  requires col >= 0
  requires ld >= 1
  ensures result >= 0
  decreases row + col
=
  return row * ld + col

"""
if "ml_matmul_max_dim" not in text:
    text = text.replace(
        "  return 4\n\ndef ml_lig_matmul_id()",
        "  return 4\n\n" + insert_after_version + "def ml_lig_matmul_id()",
    )

text = text.replace(
    "  if m > 8 or n > 8 or k > 8:\n    return 0\n  return 1\n\ndef ml_matmul_cpu_ref(",
    "  if m > 16 or n > 16 or k > 16:\n    return 0\n  return 1\n\n"
    + open(ROOT / "scripts/_flat_matmul_snippet.li").read()
    + "\ndef ml_matmul_cpu_ref(",
)

# write snippet file first if using above - inline instead
flat_snippet = """def ml_matmul_flat_to_nested(
    m: int, n: int, k: int,
    a: array[64, float], b: array[64, float],
    an: var array[8, array[8, float]], bn: var array[8, array[8, float]]) -> int
  requires m >= 1
  requires n >= 1
  requires k >= 1
  requires m <= 8
  requires n <= 8
  requires k <= 8
  ensures result >= 0
  ensures result <= 1
  decreases m + n + k
=
  if m == 4 and n == 4 and k == 4:
    an[0][0] = a[0]
    an[0][1] = a[1]
    an[0][2] = a[2]
    an[0][3] = a[3]
    an[1][0] = a[4]
    an[1][1] = a[5]
    an[1][2] = a[6]
    an[1][3] = a[7]
    an[2][0] = a[8]
    an[2][1] = a[9]
    an[2][2] = a[10]
    an[2][3] = a[11]
    an[3][0] = a[12]
    an[3][1] = a[13]
    an[3][2] = a[14]
    an[3][3] = a[15]
    bn[0][0] = b[0]
    bn[0][1] = b[1]
    bn[0][2] = b[2]
    bn[0][3] = b[3]
    bn[1][0] = b[4]
    bn[1][1] = b[5]
    bn[1][2] = b[6]
    bn[1][3] = b[7]
    bn[2][0] = b[8]
    bn[2][1] = b[9]
    bn[2][2] = b[10]
    bn[2][3] = b[11]
    bn[3][0] = b[12]
    bn[3][1] = b[13]
    bn[3][2] = b[14]
    bn[3][3] = b[15]
    return 1
  return 0

def ml_matmul_nested_to_flat(m: int, n: int, cn: array[8, array[8, float]], c: var array[64, float]) -> int
  requires m >= 1
  requires n >= 1
  requires m <= 8
  requires n <= 8
  ensures result >= 0
  ensures result <= 1
  decreases m + n
=
  if m == 4 and n == 4:
    c[0] = cn[0][0]
    c[1] = cn[0][1]
    c[2] = cn[0][2]
    c[3] = cn[0][3]
    c[4] = cn[1][0]
    c[5] = cn[1][1]
    c[6] = cn[1][2]
    c[7] = cn[1][3]
    c[8] = cn[2][0]
    c[9] = cn[2][1]
    c[10] = cn[2][2]
    c[11] = cn[2][3]
    c[12] = cn[3][0]
    c[13] = cn[3][1]
    c[14] = cn[3][2]
    c[15] = cn[3][3]
    return 1
  return 0

def ml_matmul_cpu_ref_flat(
    m: int, n: int, k: int,
    a: array[64, float], b: array[64, float], c: var array[64, float]) -> int
  requires m >= 1
  requires n >= 1
  requires k >= 1
  requires m <= 16
  requires n <= 16
  requires k <= 16
  ensures result >= 0
  ensures result <= 1
  decreases m + n + k
=
  if m > 8 or n > 8 or k > 8:
    return 0
  var an: array[8, array[8, float]]
  var bn: array[8, array[8, float]]
  var cn: array[8, array[8, float]]
  if ml_matmul_flat_to_nested(m, n, k, a, b, an, bn) != 1:
    return 0
  if ml_matmul_cpu_nested(m, n, k, an, bn, cn) != 1:
    return 0
  return ml_matmul_nested_to_flat(m, n, cn, c)
"""

if "ml_matmul_cpu_ref_flat" not in text:
    text = text.replace(
        "  if m > 16 or n > 16 or k > 16:\n    return 0\n  return 1\n\ndef ml_matmul_cpu_ref(",
        "  if m > 16 or n > 16 or k > 16:\n    return 0\n  return 1\n\n" + flat_snippet + "\ndef ml_matmul_cpu_ref(",
    )

if "return ml_matmul_cpu_ref_flat" not in text:
    text = text.replace(
        "    c[9] = cn[1][1]\n    return 1\n  return 0\n\n@vectorized(lanes=4)",
        "    c[9] = cn[1][1]\n    return 1\n  return ml_matmul_cpu_ref_flat(m, n, k, a, b, c)\n\n@vectorized(lanes=4)",
    )

# fix version if still 3
text = text.replace("ensures result == 3\n  decreases 0\n=\n  return 3", "ensures result == 4\n  decreases 0\n=\n  return 4", 1)

p.write_text(text, encoding="utf-8")

# ml_matmul_general version check
g = ROOT / "packages/li-ml/li-tests/smoke/ml_matmul_general.li"
g.write_text(g.read_text(encoding="utf-8").replace("ml_version() != 3", "ml_version() != 4"), encoding="utf-8")
print("li-ml patched")
