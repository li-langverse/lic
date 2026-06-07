#!/usr/bin/env python3
"""Generate Pure Li M1 PEM / X509 / Ed25519 key-load sources (int golden vectors)."""
from __future__ import annotations

import base64
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "packages" / "li-crypto" / "src"
SMOKE = ROOT / "packages" / "li-crypto" / "li-tests" / "smoke"

SEED = bytes(range(32))


def make_vectors() -> tuple[bytes, bytes, bytes, bytes, bytes]:
    from cryptography import x509
    from cryptography.hazmat.primitives import serialization
    from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
    from cryptography.x509.oid import NameOID

    priv = Ed25519PrivateKey.from_private_bytes(SEED)
    pkcs8_pem = priv.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    subject = issuer = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "pure-li-https-test")])
    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(issuer)
        .public_key(priv.public_key())
        .serial_number(1)
        .not_valid_before(datetime(2024, 1, 1, tzinfo=timezone.utc))
        .not_valid_after(datetime(2034, 1, 1, tzinfo=timezone.utc))
        .sign(priv, None)
    )
    cert_pem = cert.public_bytes(serialization.Encoding.PEM)
    pkcs8_der = priv.private_bytes(
        encoding=serialization.Encoding.DER,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption(),
    )
    cert_der = cert.public_bytes(serialization.Encoding.DER)
    pubkey = priv.public_key().public_bytes(
        encoding=serialization.Encoding.Raw,
        format=serialization.PublicFormat.Raw,
    )
    return pkcs8_pem, cert_pem, pkcs8_der, cert_der, pubkey


def golden_byte_fn(name: str, digest: bytes) -> str:
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


def pem_slice(pem: bytes) -> tuple[int, int, int]:
    text = pem.decode("ascii")
    m = re.search(r"-----BEGIN [A-Z ]+-----\n(.+?)\n-----END", text, re.S)
    assert m
    b64 = m.group(1).replace("\n", "")
    b64_start = text.index(m.group(1))
    b64_end = b64_start + len(m.group(1))
    return b64_start, b64_end, len(base64.b64decode(b64))


def write_pem_golden(pkcs8_pem: bytes, cert_pem: bytes, pkcs8_der: bytes, cert_der: bytes) -> None:
    p_b64_s, p_b64_e, p_der_len = pem_slice(pkcs8_pem)
    c_b64_s, c_b64_e, c_der_len = pem_slice(cert_pem)
    body = (
        "# pem_golden — PEM wire + DER golden bytes (M1b).\n\n"
        + golden_byte_fn("crypto_pem_pkcs8_wire_byte", pkcs8_pem)
        + golden_byte_fn("crypto_pem_cert_wire_byte", cert_pem)
        + golden_byte_fn("crypto_pem_pkcs8_der_golden_byte", pkcs8_der)
        + golden_byte_fn("crypto_pem_cert_der_golden_byte", cert_der)
        + f"""def crypto_pem_pkcs8_wire_len() -> int
  requires true
  ensures result == {len(pkcs8_pem)}
  decreases 0
=
  return {len(pkcs8_pem)}

def crypto_pem_cert_wire_len() -> int
  requires true
  ensures result == {len(cert_pem)}
  decreases 0
=
  return {len(cert_pem)}

def crypto_pem_pkcs8_b64_start() -> int
  requires true
  ensures result == {p_b64_s}
  decreases 0
=
  return {p_b64_s}

def crypto_pem_pkcs8_b64_end() -> int
  requires true
  ensures result == {p_b64_e}
  decreases 0
=
  return {p_b64_e}

def crypto_pem_cert_b64_start() -> int
  requires true
  ensures result == {c_b64_s}
  decreases 0
=
  return {c_b64_s}

def crypto_pem_cert_b64_end() -> int
  requires true
  ensures result == {c_b64_e}
  decreases 0
=
  return {c_b64_e}

def crypto_pem_pkcs8_der_len() -> int
  requires true
  ensures result == {p_der_len}
  decreases 0
=
  return {p_der_len}

def crypto_pem_cert_der_len() -> int
  requires true
  ensures result == {c_der_len}
  decreases 0
=
  return {c_der_len}

def crypto_pem_wire_byte(kind: int, i: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= i
  ensures 0 <= result and result <= 255
  decreases 0
=
  if kind == 0:
    return crypto_pem_pkcs8_wire_byte(i)
  return crypto_pem_cert_wire_byte(i)

def crypto_pem_wire_len(kind: int) -> int
  requires kind == 0 or kind == 1
  ensures result > 0
  decreases 0
=
  if kind == 0:
    return crypto_pem_pkcs8_wire_len()
  return crypto_pem_cert_wire_len()
"""
    )
    (OUT / "pem_golden.li").write_text(body)


def b64_decode_slice(wire: bytes, start: int, end: int) -> bytes:
    chunk = wire[start:end].replace(b"\n", b"").replace(b"\r", b"")
    return base64.b64decode(chunk)


def write_base64(pkcs8_pem: bytes, cert_pem: bytes, pkcs8_der: bytes, cert_der: bytes) -> None:
    p_b64_s, p_b64_e, _ = pem_slice(pkcs8_pem)
    c_b64_s, c_b64_e, _ = pem_slice(cert_pem)
    assert b64_decode_slice(pkcs8_pem, p_b64_s, p_b64_e) == pkcs8_der
    assert b64_decode_slice(cert_pem, c_b64_s, c_b64_e) == cert_der
    (OUT / "base64.li").write_text(
        """# base64 — RFC4648 decode over golden PEM slices (M1b).

import pem_golden

def crypto_base64_val(c: int) -> int
  requires 0 <= c and c <= 255
  ensures result >= -1
  ensures result <= 63
  decreases 0
=
  if c >= 65 and c <= 90:
    return c - 65
  if c >= 97 and c <= 122:
    return c - 71
  if c >= 48 and c <= 57:
    return c + 4
  if c == 43:
    return 62
  if c == 47:
    return 63
  if c == 61:
    return -2
  if c == 10 or c == 13 or c == 32 or c == 9:
    return -3
  return -1

def crypto_base64_skip_ws(kind: int, pos: int, end: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= pos
  requires pos <= end
  ensures 0 <= result
  ensures result <= end
  decreases end - pos
=
  if pos >= end:
    return pos
  var c: int = crypto_pem_wire_byte(kind, pos)
  if crypto_base64_val(c) == -3:
    return crypto_base64_skip_ws(kind, pos + 1, end)
  return pos

def crypto_base64_decode_quad(a: int, b: int, c: int, d: int) -> int
  requires 0 <= a and a <= 63
  requires 0 <= b and b <= 63
  requires -2 <= c and c <= 63
  requires -2 <= d and d <= 63
  ensures 0 <= result
  ensures result < 16777216
  decreases 0
=
  var n: int = a * 262144 + b * 4096
  if c >= 0:
    n = n + c * 64
  if d >= 0:
    n = n + d
  return n

def crypto_base64_emit_byte(quad: int, slot: int, pad: int) -> int
  requires 0 <= quad and quad < 16777216
  requires 0 <= slot and slot <= 2
  requires 0 <= pad and pad <= 2
  ensures 0 <= result and result <= 255
  decreases 0
=
  if slot == 0:
    return quad / 65536
  if slot == 1:
    if pad >= 2:
      return 0
    return (quad / 256) % 256
  if pad >= 1:
    return 0
  return quad % 256

def crypto_base64_decoded_byte(kind: int, idx: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= idx
  ensures 0 <= result and result <= 255
  decreases 0
=
  var start: int = 0
  var end: int = 0
  if kind == 0:
    start = crypto_pem_pkcs8_b64_start()
    end = crypto_pem_pkcs8_b64_end()
  if kind == 1:
    start = crypto_pem_cert_b64_start()
    end = crypto_pem_cert_b64_end()
  var pos: int = start
  var out_i: int = 0
  while pos < end
    pos = crypto_base64_skip_ws(kind, pos, end)
    if pos >= end:
      return 0
    var v0: int = crypto_base64_val(crypto_pem_wire_byte(kind, pos))
    if v0 < 0:
      return 0
    pos = pos + 1
    pos = crypto_base64_skip_ws(kind, pos, end)
    if pos >= end:
      return 0
    var v1: int = crypto_base64_val(crypto_pem_wire_byte(kind, pos))
    if v1 < 0:
      return 0
    pos = pos + 1
    pos = crypto_base64_skip_ws(kind, pos, end)
    var v2: int = -2
    var v3: int = -2
    if pos < end:
      v2 = crypto_base64_val(crypto_pem_wire_byte(kind, pos))
      if v2 >= 0:
        pos = pos + 1
        pos = crypto_base64_skip_ws(kind, pos, end)
        if pos < end:
          v3 = crypto_base64_val(crypto_pem_wire_byte(kind, pos))
          if v3 >= 0:
            pos = pos + 1
    var pad: int = 0
    if v2 == -2:
      pad = 2
    if v2 != -2:
      if v3 == -2:
        pad = 1
    var quad: int = crypto_base64_decode_quad(v0, v1, v2, v3)
    var slot: int = 0
    while slot < 3 - pad
      if out_i == idx:
        return crypto_base64_emit_byte(quad, slot, pad)
      out_i = out_i + 1
      slot = slot + 1
  return 0

def crypto_base64_der_check(kind: int, idx: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= idx
  ensures 0 <= result and result <= 255
  decreases 0
=
  return crypto_base64_decoded_byte(kind, idx)
"""
    )


def write_pem() -> None:
    (OUT / "pem.li").write_text(
        """# pem — BEGIN/END scanner over golden wire bytes (M1b).

import pem_golden
import base64

def crypto_pem_match_begin(kind: int, pos: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= pos
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  if pos + 11 > crypto_pem_wire_len(kind):
    return 0
  if crypto_pem_wire_byte(kind, pos) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 1) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 2) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 3) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 4) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 5) != 66:
    return 0
  if crypto_pem_wire_byte(kind, pos + 6) != 69:
    return 0
  if crypto_pem_wire_byte(kind, pos + 7) != 71:
    return 0
  if crypto_pem_wire_byte(kind, pos + 8) != 73:
    return 0
  if crypto_pem_wire_byte(kind, pos + 9) != 78:
    return 0
  if crypto_pem_wire_byte(kind, pos + 10) != 32:
    return 0
  return 1

def crypto_pem_match_end(kind: int, pos: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= pos
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  if pos + 9 > crypto_pem_wire_len(kind):
    return 0
  if crypto_pem_wire_byte(kind, pos) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 1) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 2) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 3) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 4) != 45:
    return 0
  if crypto_pem_wire_byte(kind, pos + 5) != 69:
    return 0
  if crypto_pem_wire_byte(kind, pos + 6) != 78:
    return 0
  if crypto_pem_wire_byte(kind, pos + 7) != 68:
    return 0
  if crypto_pem_wire_byte(kind, pos + 8) != 32:
    return 0
  return 1

def crypto_pem_scan_selftest(kind: int) -> int
  requires kind == 0 or kind == 1
  ensures result >= 0
  decreases 0
=
  if crypto_pem_match_begin(kind, 0) != 1:
    return 1
  var end_pos: int = 0
  if kind == 0:
    end_pos = crypto_pem_pkcs8_b64_end()
  if kind == 1:
    end_pos = crypto_pem_cert_b64_end()
  var i: int = end_pos
  while i < crypto_pem_wire_len(kind)
    if crypto_pem_match_end(kind, i) == 1:
      return 0
    i = i + 1
  return 2

def crypto_pem_b64_der_selftest(kind: int) -> int
  requires kind == 0 or kind == 1
  ensures result >= 0
  decreases 0
=
  var n: int = 0
  if kind == 0:
    n = crypto_pem_pkcs8_der_len()
  if kind == 1:
    n = crypto_pem_cert_der_len()
  var i: int = 0
  while i < n
    var got: int = crypto_base64_der_check(kind, i)
    var exp: int = 0
    if kind == 0:
      exp = crypto_pem_pkcs8_der_golden_byte(i)
    if kind == 1:
      exp = crypto_pem_cert_der_golden_byte(i)
    if got != exp:
      return i + 10
    i = i + 1
  return 0
"""
    )


def write_asn1() -> None:
    (OUT / "asn1.li").write_text(
        """# asn1 — minimal DER helpers over golden DER bytes (M1b).

import pem_golden

def crypto_asn1_der_byte(kind: int, off: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= off
  ensures 0 <= result and result <= 255
  decreases 0
=
  if kind == 0:
    return crypto_pem_pkcs8_der_golden_byte(off)
  return crypto_pem_cert_der_golden_byte(off)

def crypto_asn1_der_len(kind: int) -> int
  requires kind == 0 or kind == 1
  ensures result > 0
  decreases 0
=
  if kind == 0:
    return crypto_pem_pkcs8_der_len()
  return crypto_pem_cert_der_len()

def crypto_asn1_read_len(kind: int, off: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= off
  requires off < crypto_asn1_der_len(kind)
  ensures 0 <= result
  decreases 0
=
  var b: int = crypto_asn1_der_byte(kind, off)
  if b < 128:
    return b
  var n: int = b - 128
  if n <= 0 or n > 4:
    return 0
  var acc: int = 0
  var i: int = 0
  while i < n
    acc = acc * 256 + crypto_asn1_der_byte(kind, off + 1 + i)
    i = i + 1
  return acc

def crypto_asn1_hdr_len(kind: int, off: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= off
  requires off < crypto_asn1_der_len(kind)
  ensures result >= 1
  decreases 0
=
  var b: int = crypto_asn1_der_byte(kind, off + 1)
  if b < 128:
    return 2
  return 2 + (b - 128)

def crypto_asn1_tag(kind: int, off: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= off
  ensures 0 <= result and result <= 255
  decreases 0
=
  return crypto_asn1_der_byte(kind, off)

def crypto_asn1_len(kind: int, off: int) -> int
  requires kind == 0 or kind == 1
  requires 0 <= off
  ensures 0 <= result
  decreases 0
=
  return crypto_asn1_read_len(kind, off + 1)
"""
    )


def write_ed25519_pem(pubkey: bytes) -> None:
    body = (
        "# ed25519_pem — PKCS#8 Ed25519 key load (M1b).\n\n"
        "import asn1\n\n"
        + golden_byte_fn("crypto_ed25519_seed_golden_byte", SEED)
        + golden_byte_fn("crypto_ed25519_pubkey_golden_byte", pubkey)
        + """def crypto_ed25519_load_seed_off() -> int
  requires true
  ensures result >= -1
  decreases 0
=
  var kind: int = 0
  if crypto_asn1_tag(kind, 0) != 48:
    return -1
  var off: int = crypto_asn1_hdr_len(kind, 0)
  if crypto_asn1_tag(kind, off) != 2:
    return -1
  if crypto_asn1_len(kind, off) != 1:
    return -1
  if crypto_asn1_der_byte(kind, off + crypto_asn1_hdr_len(kind, off)) != 0:
    return -1
  off = off + crypto_asn1_hdr_len(kind, off) + 1
  if crypto_asn1_tag(kind, off) != 48:
    return -1
  off = off + crypto_asn1_hdr_len(kind, off) + crypto_asn1_len(kind, off)
  if crypto_asn1_tag(kind, off) != 4:
    return -1
  var inner_off: int = off + crypto_asn1_hdr_len(kind, off)
  if crypto_asn1_tag(kind, inner_off) != 4:
    return -1
  if crypto_asn1_len(kind, inner_off) != 32:
    return -1
  return inner_off + crypto_asn1_hdr_len(kind, inner_off)

def crypto_ed25519_seed_byte(idx: int) -> int
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result <= 255
  decreases 0
=
  var base: int = crypto_ed25519_load_seed_off()
  if base < 0:
    return 0
  return crypto_asn1_der_byte(0, base + idx)

def crypto_ed25519_pkcs8_selftest() -> int
  requires true
  ensures result >= 0
  decreases 32
=
  var i: int = 0
  while i < 32
    if crypto_ed25519_seed_byte(i) != crypto_ed25519_seed_golden_byte(i):
      return i + 1
    i = i + 1
  return 0
"""
    )
    (OUT / "ed25519_pem.li").write_text(body)


def write_x509(pubkey: bytes) -> None:
    body = (
        "# x509 — Ed25519 SPKI subset (M1b).\n\n"
        "import asn1\n\n"
        + golden_byte_fn("crypto_x509_ed25519_pubkey_golden_byte", pubkey)
        + """def crypto_x509_tbs_spki_off() -> int
  requires true
  ensures result >= -1
  decreases 0
=
  var kind: int = 1
  if crypto_asn1_tag(kind, 0) != 48:
    return -1
  var tbs_off: int = crypto_asn1_hdr_len(kind, 0)
  if crypto_asn1_tag(kind, tbs_off) != 48:
    return -1
  var pos: int = tbs_off + crypto_asn1_hdr_len(kind, tbs_off)
  var tbs_end: int = pos + crypto_asn1_len(kind, tbs_off)
  var spki_off: int = -1
  while pos < tbs_end
    if crypto_asn1_tag(kind, pos) == 48:
      spki_off = pos
    pos = pos + crypto_asn1_hdr_len(kind, pos) + crypto_asn1_len(kind, pos)
  return spki_off

def crypto_x509_spki_off() -> int
  requires true
  ensures result >= -1
  decreases 0
=
  var kind: int = 1
  var off: int = crypto_x509_tbs_spki_off()
  if off < 0:
    return -1
  var spki_body: int = off + crypto_asn1_hdr_len(kind, off)
  if crypto_asn1_tag(kind, spki_body) != 48:
    return -1
  var alg_end: int = spki_body + crypto_asn1_hdr_len(kind, spki_body) + crypto_asn1_len(kind, spki_body)
  if crypto_asn1_tag(kind, alg_end) != 3:
    return -1
  if crypto_asn1_len(kind, alg_end) != 33:
    return -1
  if crypto_asn1_der_byte(kind, alg_end + crypto_asn1_hdr_len(kind, alg_end)) != 0:
    return -1
  return alg_end + crypto_asn1_hdr_len(kind, alg_end) + 1

def crypto_x509_ed25519_pubkey_byte(idx: int) -> int
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result <= 255
  decreases 0
=
  var base: int = crypto_x509_spki_off()
  if base < 0:
    return 0
  return crypto_asn1_der_byte(1, base + idx)

def crypto_x509_ed25519_selftest() -> int
  requires true
  ensures result >= 0
  decreases 32
=
  var i: int = 0
  while i < 32
    if crypto_x509_ed25519_pubkey_byte(i) != crypto_x509_ed25519_pubkey_golden_byte(i):
      return i + 100
    i = i + 1
  return 0
"""
    )
    (OUT / "x509.li").write_text(body)


def write_lib() -> None:
    (OUT / "lib.li").write_text(
        """# li-crypto public surface (M1).

import bitops
import sha256
import sha384
import hkdf
import chacha20_poly1305
import x25519
import pem_golden
import base64
import pem
import asn1
import ed25519_pem
import x509

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

def li_crypto_m1_pem_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var r: int = crypto_pem_scan_selftest(0)
  if r != 0:
    return r
  r = crypto_pem_scan_selftest(1)
  if r != 0:
    return r + 2
  r = crypto_pem_b64_der_selftest(0)
  if r != 0:
    return r + 10
  r = crypto_pem_b64_der_selftest(1)
  if r != 0:
    return r + 20
  r = crypto_ed25519_pkcs8_selftest()
  if r != 0:
    return r + 30
  r = crypto_x509_ed25519_selftest()
  if r != 0:
    return r + 40
  return 0
"""
    )


def write_smoke() -> None:
    SMOKE.mkdir(parents=True, exist_ok=True)
    (SMOKE / "pem_ed25519.li").write_text(
        """import crypto

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return li_crypto_m1_pem_selftest()
"""
    )


def main() -> None:
    pkcs8_pem, cert_pem, pkcs8_der, cert_der, pubkey = make_vectors()
    OUT.mkdir(parents=True, exist_ok=True)
    write_pem_golden(pkcs8_pem, cert_pem, pkcs8_der, cert_der)
    write_base64(pkcs8_pem, cert_pem, pkcs8_der, cert_der)
    write_pem()
    write_asn1()
    write_ed25519_pem(pubkey)
    write_x509(pubkey)
    write_lib()
    write_smoke()
    print(f"generated PEM M1b under {OUT}")


if __name__ == "__main__":
    main()
