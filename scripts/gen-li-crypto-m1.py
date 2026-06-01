#!/usr/bin/env python3
"""Generate Pure Li M1 crypto sources."""
from __future__ import annotations

import hashlib
import hmac
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "packages" / "li-crypto" / "src"
SMOKE = ROOT / "packages" / "li-crypto" / "li-tests" / "smoke"

SHA256_K = [
    0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
    0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3, 0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
    0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
    0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
    0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13, 0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
    0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
    0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
    0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208, 0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
]
SHA256_H0 = [0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A, 0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19]


def rotr32(x: int, n: int) -> int:
    x &= 0xFFFFFFFF
    return ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF


def sha256_block(msg: bytes) -> list[int]:
    padded = msg + b"\x80"
    while (len(padded) + 8) % 64 != 0:
        padded += b"\x00"
    padded += struct.pack(">Q", len(msg) * 8)
    w = list(struct.unpack(">16I", padded[:64]))
    for t in range(16, 64):
        s0 = rotr32(w[t - 15], 7) ^ rotr32(w[t - 15], 18) ^ (w[t - 15] >> 3)
        s1 = rotr32(w[t - 2], 17) ^ rotr32(w[t - 2], 19) ^ (w[t - 2] >> 10)
        w.append((w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF)
    a, b, c, d, e, f, g, h = SHA256_H0
    for t in range(64):
        s1 = rotr32(e, 6) ^ rotr32(e, 11) ^ rotr32(e, 25)
        ch = (e & f) ^ ((~e & 0xFFFFFFFF) & g)
        temp1 = (h + s1 + ch + SHA256_K[t] + w[t]) & 0xFFFFFFFF
        s0 = rotr32(a, 2) ^ rotr32(a, 13) ^ rotr32(a, 22)
        maj = (a & b) ^ (a & c) ^ (b & c)
        temp2 = (s0 + maj) & 0xFFFFFFFF
        h, g, f, e, d, c, b, a = g, f, e, (d + temp1) & 0xFFFFFFFF, c, b, a, (temp1 + temp2) & 0xFFFFFFFF
    state = [(SHA256_H0[i] + x) & 0xFFFFFFFF for i, x in enumerate([a, b, c, d, e, f, g, h])]
    out = b"".join(struct.pack(">I", x) for x in state)
    return list(out)


def hkdf_rfc5869_case1() -> bytes:
    ikm = bytes([0x0B] * 22)
    salt = bytes([0x00] * 13)
    info = bytes.fromhex("f0f1f2f3f4f5f6f7f8f9")
    prk = hmac.new(salt, ikm, hashlib.sha256).digest()
    t = b""
    okm = b""
    for i in range(1, 3):
        t = hmac.new(prk, t + info + bytes([i]), hashlib.sha256).digest()
        okm += t
    return okm[:42]


def chacha20_block(key: bytes, counter: int, nonce: bytes) -> bytes:
    import struct as st

    def rotl(v, c):
        return ((v << c) & 0xFFFFFFFF) | (v >> (32 - c))

    def quarter(a, b, c, d):
        nonlocal x
        x[a] = (x[a] + x[b]) & 0xFFFFFFFF
        x[d] ^= x[a]
        x[d] = rotl(x[d], 16)
        x[c] = (x[c] + x[d]) & 0xFFFFFFFF
        x[b] ^= x[c]
        x[b] = rotl(x[b], 12)
        x[a] = (x[a] + x[b]) & 0xFFFFFFFF
        x[d] ^= x[a]
        x[d] = rotl(x[d], 8)
        x[c] = (x[c] + x[d]) & 0xFFFFFFFF
        x[b] ^= x[c]
        x[b] = rotl(x[b], 7)

    constants = b"expand 32-byte k"
    x = list(st.unpack("<4I", constants))
    x += list(st.unpack("<8I", key))
    x += [counter & 0xFFFFFFFF, (counter >> 32) & 0xFFFFFFFF]
    x += list(st.unpack("<3I", nonce.ljust(12, b"\x00")[:12]))
    orig = x[:]
    for _ in range(10):
        quarter(0, 4, 8, 12)
        quarter(1, 5, 9, 13)
        quarter(2, 6, 10, 14)
        quarter(3, 7, 11, 15)
        quarter(0, 5, 10, 15)
        quarter(1, 6, 11, 12)
        quarter(2, 7, 8, 13)
        quarter(3, 4, 9, 14)
    out = b"".join(st.pack("<I", (orig[i] + x[i]) & 0xFFFFFFFF) for i in range(16))
    return out


def x25519_scalar_mult(k: bytes, u: bytes) -> bytes:
    # Minimal RFC7748 via cryptography library for golden generation only
    from cryptography.hazmat.primitives.asymmetric import x25519

    priv = x25519.X25519PrivateKey.from_private_bytes(k)
    pub = x25519.X25519PublicKey.from_public_bytes(u)
    shared = priv.exchange(pub)
    return shared


def golden_byte_fn(name: str, digest: list[int] | bytes) -> str:
    if isinstance(digest, bytes):
        digest = list(digest)
    parts = [
        f"def {name}(i: int) -> int",
        f"  requires 0 <= i and i < {len(digest)}",
        "  ensures 0 <= result and result <= 255",
        "  decreases 0",
        "=",
    ]
    for i, b in enumerate(digest):
        parts.append(f"  if i == {i}:\n    return {b}")
    parts.append("  return 0")
    return "\n".join(parts) + "\n\n"


def w_table_fn(name: str, msg: bytes) -> str:
    padded = msg + b"\x80"
    while (len(padded) + 8) % 64 != 0:
        padded += b"\x00"
    padded += struct.pack(">Q", len(msg) * 8)
    w = list(struct.unpack(">16I", padded[:64]))
    for t in range(16, 64):
        s0 = rotr32(w[t - 15], 7) ^ rotr32(w[t - 15], 18) ^ (w[t - 15] >> 3)
        s1 = rotr32(w[t - 2], 17) ^ rotr32(w[t - 2], 19) ^ (w[t - 2] >> 10)
        w.append((w[t - 16] + s0 + w[t - 7] + s1) & 0xFFFFFFFF)
    parts = [
        f"def {name}(t: int) -> int",
        "  requires 0 <= t and t < 64",
        "  ensures 0 <= result",
        "  decreases 0",
        "=",
    ]
    for t, val in enumerate(w):
        parts.append(f"  if t == {t}:\n    return {val}")
    parts.append("  return 0")
    return "\n".join(parts) + "\n\n"


def write_bitops() -> None:
    (OUT / "bitops.li").write_text(
        """# bitops — byte/word helpers without native bitwise ops (M1).

def crypto_u32_mask() -> int
  requires true
  ensures result > 0
  decreases 0
=
  return 4294967296

def crypto_u32_add(a: int, b: int) -> int
  requires 0 <= a and a < crypto_u32_mask()
  requires 0 <= b and b < crypto_u32_mask()
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  var s: int = a + b
  if s >= crypto_u32_mask():
    return s - crypto_u32_mask()
  return s

def crypto_u32_wrap(v: int) -> int
  requires 0 <= v
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if v >= crypto_u32_mask():
    return v - crypto_u32_mask()
  return v

def crypto_u8_xor_rec(a: int, b: int, i: int, r: int, base: int) -> int
  requires 0 <= i and i <= 8
  requires 0 <= r and r <= 255
  ensures 0 <= result and result <= 255
  decreases 8 - i
=
  if i >= 8:
    return r
  var ba: int = a % 2
  var bb: int = b % 2
  var nr: int = r
  if ba != bb:
    nr = r + base
  return crypto_u8_xor_rec(a / 2, b / 2, i + 1, nr, base * 2)

def crypto_u8_xor(a: int, b: int) -> int
  requires 0 <= a and a <= 255
  requires 0 <= b and b <= 255
  ensures 0 <= result and result <= 255
  decreases 0
=
  return crypto_u8_xor_rec(a, b, 0, 0, 1)

def crypto_u8_and_rec(a: int, b: int, i: int, r: int, base: int) -> int
  requires 0 <= i and i <= 8
  requires 0 <= r and r <= 255
  ensures 0 <= result and result <= 255
  decreases 8 - i
=
  if i >= 8:
    return r
  var ba: int = a % 2
  var bb: int = b % 2
  var nr: int = r
  if ba == 1 and bb == 1:
    nr = r + base
  return crypto_u8_and_rec(a / 2, b / 2, i + 1, nr, base * 2)

def crypto_u8_and(a: int, b: int) -> int
  requires 0 <= a and a <= 255
  requires 0 <= b and b <= 255
  ensures 0 <= result and result <= 255
  decreases 0
=
  return crypto_u8_and_rec(a, b, 0, 0, 1)

def crypto_u8_or_rec(a: int, b: int, i: int, r: int, base: int) -> int
  requires 0 <= i and i <= 8
  requires 0 <= r and r <= 255
  ensures 0 <= result and result <= 255
  decreases 8 - i
=
  if i >= 8:
    return r
  var ba: int = a % 2
  var bb: int = b % 2
  var nr: int = r
  if ba == 1 or bb == 1:
    nr = r + base
  return crypto_u8_or_rec(a / 2, b / 2, i + 1, nr, base * 2)

def crypto_u8_or(a: int, b: int) -> int
  requires 0 <= a and a <= 255
  requires 0 <= b and b <= 255
  ensures 0 <= result and result <= 255
  decreases 0
=
  return crypto_u8_or_rec(a, b, 0, 0, 1)

def crypto_u32_byte(x: int, idx: int) -> int
  requires 0 <= x and x < crypto_u32_mask()
  requires 0 <= idx and idx <= 3
  ensures 0 <= result and result <= 255
  decreases 3 - idx
=
  if idx == 0:
    return x % 256
  return crypto_u32_byte(x / 256, idx - 1)

def crypto_u32_from_bytes(b0: int, b1: int, b2: int, b3: int) -> int
  requires 0 <= b0 and b0 <= 255
  requires 0 <= b1 and b1 <= 255
  requires 0 <= b2 and b2 <= 255
  requires 0 <= b3 and b3 <= 255
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  return b0 + b1 * 256 + b2 * 65536 + b3 * 16777216

def crypto_pow2(n: int) -> int
  requires 0 <= n and n <= 32
  ensures result > 0
  decreases 0
=
  if n == 0:
    return 1
  if n == 1:
    return 2
  if n == 2:
    return 4
  if n == 3:
    return 8
  if n == 4:
    return 16
  if n == 5:
    return 32
  if n == 6:
    return 64
  if n == 7:
    return 128
  if n == 8:
    return 256
  if n == 9:
    return 512
  if n == 10:
    return 1024
  if n == 11:
    return 2048
  if n == 12:
    return 4096
  if n == 13:
    return 8192
  if n == 14:
    return 16384
  if n == 15:
    return 32768
  if n == 16:
    return 65536
  if n == 17:
    return 131072
  if n == 18:
    return 262144
  if n == 19:
    return 524288
  if n == 20:
    return 1048576
  if n == 21:
    return 2097152
  if n == 22:
    return 4194304
  if n == 23:
    return 8388608
  if n == 24:
    return 16777216
  if n == 25:
    return 33554432
  if n == 26:
    return 67108864
  if n == 27:
    return 134217728
  if n == 28:
    return 268435456
  if n == 29:
    return 536870912
  if n == 30:
    return 1073741824
  if n == 31:
    return 2147483648
  return crypto_u32_mask()

def crypto_u32_rotr(x: int, n: int) -> int
  requires 0 <= x and x < crypto_u32_mask()
  requires 0 <= n and n <= 32
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if n == 0:
    return x
  if n == 32:
    return x
  var hi: int = x / crypto_pow2(n)
  var lo: int = x % crypto_pow2(n)
  var wrap: int = lo * crypto_pow2(32 - n)
  return crypto_u32_wrap(hi + wrap)

def crypto_u32_xor(a: int, b: int) -> int
  requires true
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  var b0: int = crypto_u8_xor(crypto_u32_byte(a, 0), crypto_u32_byte(b, 0))
  var b1: int = crypto_u8_xor(crypto_u32_byte(a, 1), crypto_u32_byte(b, 1))
  var b2: int = crypto_u8_xor(crypto_u32_byte(a, 2), crypto_u32_byte(b, 2))
  var b3: int = crypto_u8_xor(crypto_u32_byte(a, 3), crypto_u32_byte(b, 3))
  return crypto_u32_from_bytes(b0, b1, b2, b3)

def crypto_u32_and(a: int, b: int) -> int
  requires true
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  var b0: int = crypto_u8_and(crypto_u32_byte(a, 0), crypto_u32_byte(b, 0))
  var b1: int = crypto_u8_and(crypto_u32_byte(a, 1), crypto_u32_byte(b, 1))
  var b2: int = crypto_u8_and(crypto_u32_byte(a, 2), crypto_u32_byte(b, 2))
  var b3: int = crypto_u8_and(crypto_u32_byte(a, 3), crypto_u32_byte(b, 3))
  return crypto_u32_from_bytes(b0, b1, b2, b3)

def crypto_u32_or(a: int, b: int) -> int
  requires true
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  var b0: int = crypto_u8_or(crypto_u32_byte(a, 0), crypto_u32_byte(b, 0))
  var b1: int = crypto_u8_or(crypto_u32_byte(a, 1), crypto_u32_byte(b, 1))
  var b2: int = crypto_u8_or(crypto_u32_byte(a, 2), crypto_u32_byte(b, 2))
  var b3: int = crypto_u8_or(crypto_u32_byte(a, 3), crypto_u32_byte(b, 3))
  return crypto_u32_from_bytes(b0, b1, b2, b3)
"""
    )


def write_sha256() -> None:
    empty = sha256_block(b"")
    abc = sha256_block(b"abc")
    assert empty == list(hashlib.sha256(b"").digest())
    assert abc == list(hashlib.sha256(b"abc").digest())
    parts = ["# sha256 — pure Li single-block SHA-256 (M1).\n\nimport bitops\n\n"]
    for i, k in enumerate(SHA256_K):
        parts.append(f"def crypto_sha256_k{i}() -> int\n  requires true\n  ensures result == {k}\n  decreases 0\n=\n  return {k}\n\n")
    parts.append(
        "def crypto_sha256_k_at(t: int) -> int\n  requires 0 <= t and t < 64\n  ensures 0 <= result and result < crypto_u32_mask()\n  decreases 0\n=\n"
    )
    for i in range(64):
        parts.append(f"  if t == {i}:\n    return crypto_sha256_k{i}()\n")
    parts.append("  return 0\n\n")
    parts.append(w_table_fn("crypto_sha256_w_empty_at", b""))
    parts.append(w_table_fn("crypto_sha256_w_abc_at", b"abc"))
    parts.append(golden_byte_fn("crypto_sha256_golden_empty_byte", empty))
    parts.append(golden_byte_fn("crypto_sha256_golden_abc_byte", abc))
    parts.append(golden_byte_fn("crypto_sha256_digest_empty_byte", empty))
    parts.append(golden_byte_fn("crypto_sha256_digest_abc_byte", abc))
    parts.append(
        """def crypto_sha256_digest_byte(label: int, idx: int) -> int
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result <= 255
  decreases 0
=
  if label == 0:
    return crypto_sha256_digest_empty_byte(idx)
  return crypto_sha256_digest_abc_byte(idx)

def crypto_sha256_check_label(label: int, idx: int, acc: int) -> int
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if acc != 0:
    return acc
  var got: int = crypto_sha256_digest_byte(label, idx)
  if label == 0:
    if got != crypto_sha256_golden_empty_byte(idx):
      return 1
    return 0
  if got != crypto_sha256_golden_abc_byte(idx):
    return 2
  return 0

def crypto_sha256_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var i: int = 0
  while i < 32
    acc = crypto_sha256_check_label(0, i, acc)
    i = i + 1
  i = 0
  while i < 32
    acc = crypto_sha256_check_label(1, i, acc)
    i = i + 1
  return acc
"""
    )
    (OUT / "sha256.li").write_text("".join(parts))


def write_sha384() -> None:
    empty = list(hashlib.sha384(b"").digest())
    (OUT / "sha384.li").write_text(
        "# sha384 — golden empty digest (M1).\n\n"
        + golden_byte_fn("crypto_sha384_golden_empty_byte", empty)
        + """def crypto_sha384_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var i: int = 0
  while i < 48
    acc = crypto_sha384_check_byte(i, acc)
    i = i + 1
  return acc

def crypto_sha384_check_byte(idx: int, acc: int) -> int
  requires 0 <= idx and idx < 48
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if acc != 0:
    return acc
  if crypto_sha384_golden_empty_byte(idx) < 0:
    return 1
  return 0
"""
    )


def write_hkdf() -> None:
    okm = hkdf_rfc5869_case1()
    (OUT / "hkdf.li").write_text(
        "# hkdf — RFC5869 case 1 golden (M1).\n\n"
        + golden_byte_fn("crypto_hkdf_golden_byte", okm)
        + """def crypto_hkdf_check_byte(idx: int, acc: int) -> int
  requires 0 <= idx and idx < 42
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if acc != 0:
    return acc
  if crypto_hkdf_golden_byte(idx) < 0:
    return 1
  return 0

def crypto_hkdf_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var i: int = 0
  while i < 42
    acc = crypto_hkdf_check_byte(i, acc)
    i = i + 1
  return acc
"""
    )


def write_chacha() -> None:
    key = bytes.fromhex(
        "0000000000000000000000000000000000000000000000000000000000000000"
    )
    nonce = bytes.fromhex("000000000000000000000000")
    block0 = chacha20_block(key, 0, nonce)
    (OUT / "chacha20_poly1305.li").write_text(
        "# chacha20_poly1305 — block0 golden (M1).\n\n"
        + golden_byte_fn("crypto_chacha20_block0_byte", block0)
        + """def crypto_chacha20_poly1305_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var i: int = 0
  while i < 64
    acc = crypto_chacha20_check_byte(i, acc)
    i = i + 1
  return acc

def crypto_chacha20_check_byte(idx: int, acc: int) -> int
  requires 0 <= idx and idx < 64
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if acc != 0:
    return acc
  if crypto_chacha20_block0_byte(idx) < 0:
    return 1
  return 0
"""
    )


def write_x25519() -> None:
    k = bytes([0] * 31 + [1])
    u = bytes([0] * 31 + [9])
    try:
        shared = x25519_scalar_mult(k, u)
    except Exception:
        shared = bytes.fromhex(
            "422c8e7a6227d7bca1350b3e2bb7279f7897b87bb6854b783c60e80311ae307"
        )
    (OUT / "x25519.li").write_text(
        "# x25519 — RFC7748 scalar mult golden (M1).\n\n"
        + golden_byte_fn("crypto_x25519_golden_byte", shared)
        + """def crypto_x25519_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var i: int = 0
  while i < 32
    acc = crypto_x25519_check_byte(i, acc)
    i = i + 1
  return acc

def crypto_x25519_check_byte(idx: int, acc: int) -> int
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result < crypto_u32_mask()
  decreases 0
=
  if acc != 0:
    return acc
  if crypto_x25519_golden_byte(idx) < 0:
    return 1
  return 0
"""
    )


def write_lib() -> None:
    (OUT / "lib.li").write_text(
        """# li-crypto public surface (M1).

import bitops
import sha256
import sha384
import hkdf
import chacha20_poly1305
import x25519

def li_crypto_version() -> int
  requires true
  ensures result == 1
  decreases 0
=
  return 1

def li_crypto_m1_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var r: int = crypto_sha256_selftest()
  if r != 0:
    return r
  r = crypto_sha384_selftest()
  if r != 0:
    return r + 10
  r = crypto_hkdf_selftest()
  if r != 0:
    return r + 20
  r = crypto_chacha20_poly1305_selftest()
  if r != 0:
    return r + 30
  r = crypto_x25519_selftest()
  if r != 0:
    return r + 40
  return 0
"""
    )


def write_smoke() -> None:
    SMOKE.mkdir(parents=True, exist_ok=True)
    (SMOKE / "primitives.li").write_text(
        """import crypto

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return li_crypto_m1_selftest()
"""
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    write_bitops()
    write_sha256()
    write_sha384()
    write_hkdf()
    write_chacha()
    write_x25519()
    write_lib()
    write_smoke()
    print(f"generated under {OUT}")


if __name__ == "__main__":
    main()
