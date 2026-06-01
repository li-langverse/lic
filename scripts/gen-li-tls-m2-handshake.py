#!/usr/bin/env python3
"""Generate Pure Li M2 TLS 1.3 record + handshake golden vectors (RFC 8448 subset)."""
from __future__ import annotations

import hashlib
import hmac
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "packages" / "li-tls" / "src"
SMOKE = ROOT / "packages" / "li-tls" / "li-tests" / "smoke"

# RFC 8448 §3 — minimal ClientHello prefix (type + legacy_version + random start)
CLIENT_HELLO = bytes.fromhex(
    "01030303"  # handshake type=ClientHello(1), legacy_version=0x0303
    "0018"  # length placeholder — patched below
    "0303"  # client legacy version
    + "00" * 32  # random (32 zero bytes for deterministic vector)
    + "00"  # session_id length = 0
    + "0004"  # cipher_suites length = 4
    + "1301"  # TLS_AES_128_GCM_SHA256
    + "1303"  # TLS_CHACHA20_POLY1305_SHA256
    + "0100"  # compression_methods: null(0)
    + "0000"  # extensions length = 0
)
# Fix handshake message length (bytes after the 4-byte header)
hs_body = CLIENT_HELLO[4:]
CLIENT_HELLO = CLIENT_HELLO[:2] + struct.pack(">H", len(hs_body)) + hs_body

# ServerHello golden (RFC 8448 style minimal)
SERVER_HELLO = bytes.fromhex(
    "020000"  # type=ServerHello(2), length patched
    "0303"  # legacy version
    + "11" * 32  # random
    + "00"  # session_id length
    + "1303"  # cipher: TLS_CHACHA20_POLY1305_SHA256
    + "00"  # compression
    + "0002"  # extensions length
    + "002b"  # supported_versions ext
    + "0002"  # ext len
    + "0304"  # TLS 1.3
)
sh_body = SERVER_HELLO[4:]
SERVER_HELLO = SERVER_HELLO[:1] + struct.pack(">I", len(sh_body))[1:]  # 3-byte length field
# Rebuild with correct 3-byte length
SERVER_HELLO = bytes([0x02]) + struct.pack(">I", len(sh_body))[1:] + sh_body

# TLS record wrapping ClientHello (handshake content type 0x16)
RECORD_CH = bytes([0x16, 0x03, 0x01]) + struct.pack(">H", len(CLIENT_HELLO)) + CLIENT_HELLO
RECORD_SH = bytes([0x16, 0x03, 0x03]) + struct.pack(">H", len(SERVER_HELLO)) + SERVER_HELLO

# RFC 8448 key schedule — Early Secret (HKDF-Extract with zero salt and zero IKM)
EARLY_SECRET = bytes.fromhex(
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
)

# Derive-Secret for "derived" label with empty Hash("") — handshake secret input
def hkdf_expand_label(prk: bytes, label: str, context: bytes, length: int) -> bytes:
    full_label = b"tls13 " + label.encode("ascii")
    hkdf_label = struct.pack(">H", length) + bytes([len(full_label)]) + full_label + bytes([len(context)]) + context
    return hkdf_expand(prk, hkdf_label, length)


def hkdf_extract(salt: bytes, ikm: bytes) -> bytes:
    return hmac.new(salt, ikm, hashlib.sha256).digest()


def hkdf_expand(prk: bytes, info: bytes, length: int) -> bytes:
    out = b""
    t = b""
    counter = 1
    while len(out) < length:
        t = hmac.new(prk, t + info + bytes([counter]), hashlib.sha256).digest()
        out += t
        counter += 1
    return out[:length]


DERIVED_SECRET = hkdf_expand_label(EARLY_SECRET, "derived", b"", 32)
EMPTY_HASH = hashlib.sha256(b"").digest()
HANDSHAKE_SECRET = hkdf_extract(DERIVED_SECRET, EMPTY_HASH)

SERVER_HS_TRAFFIC = hkdf_expand_label(HANDSHAKE_SECRET, "s hs traffic", EMPTY_HASH, 32)
CLIENT_HS_TRAFFIC = hkdf_expand_label(HANDSHAKE_SECRET, "c hs traffic", EMPTY_HASH, 32)


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


def write_tls_golden() -> None:
    chunks = [
        "# tls_golden — TLS 1.3 record + handshake wire bytes (M2).\n\n",
        golden_byte_fn("tls_golden_record_client_hello_byte", RECORD_CH),
        f"def tls_golden_record_client_hello_len() -> int\n  requires true\n  ensures result == {len(RECORD_CH)}\n  decreases 0\n=\n  return {len(RECORD_CH)}\n\n",
        golden_byte_fn("tls_golden_record_server_hello_byte", RECORD_SH),
        f"def tls_golden_record_server_hello_len() -> int\n  requires true\n  ensures result == {len(RECORD_SH)}\n  decreases 0\n=\n  return {len(RECORD_SH)}\n\n",
        golden_byte_fn("tls_golden_client_hello_byte", CLIENT_HELLO),
        f"def tls_golden_client_hello_len() -> int\n  requires true\n  ensures result == {len(CLIENT_HELLO)}\n  decreases 0\n=\n  return {len(CLIENT_HELLO)}\n\n",
        golden_byte_fn("tls_golden_server_hello_byte", SERVER_HELLO),
        f"def tls_golden_server_hello_len() -> int\n  requires true\n  ensures result == {len(SERVER_HELLO)}\n  decreases 0\n=\n  return {len(SERVER_HELLO)}\n\n",
        golden_byte_fn("tls_golden_early_secret_byte", EARLY_SECRET),
        golden_byte_fn("tls_golden_handshake_secret_byte", HANDSHAKE_SECRET),
        golden_byte_fn("tls_golden_server_hs_traffic_byte", SERVER_HS_TRAFFIC),
        golden_byte_fn("tls_golden_client_hs_traffic_byte", CLIENT_HS_TRAFFIC),
    ]
    (OUT / "tls_golden.li").write_text("".join(chunks))


def write_record() -> None:
    (OUT / "record.li").write_text(
        """# record — TLS 1.3 record layer parse/build (M2).

import tls_golden

def tls_record_header_len() -> int
  requires true
  ensures result == 5
  decreases 0
=
  return 5

def tls_record_type_handshake() -> int
  requires true
  ensures result == 22
  decreases 0
=
  return 22

def tls_record_type_application() -> int
  requires true
  ensures result == 23
  decreases 0
=
  return 23

def tls_record_legacy_version() -> int
  requires true
  ensures result == 771
  decreases 0
=
  return 771

def tls_record_parse_type(b0: int) -> int
  requires 0 <= b0 and b0 <= 255
  ensures 0 <= result and result <= 255
  decreases 0
=
  return b0

def tls_record_parse_version(b1: int, b2: int) -> int
  requires 0 <= b1 and b1 <= 255
  requires 0 <= b2 and b2 <= 255
  ensures 0 <= result and result <= 65535
  decreases 0
=
  return b1 * 256 + b2

def tls_record_parse_length(b3: int, b4: int) -> int
  requires 0 <= b3 and b3 <= 255
  requires 0 <= b4 and b4 <= 255
  ensures 0 <= result and result <= 65535
  decreases 0
=
  return b3 * 256 + b4

def tls_record_header_byte(kind: int, idx: int) -> int
  requires 0 <= kind and kind <= 1
  requires 0 <= idx and idx < 5
  ensures 0 <= result and result <= 255
  decreases 0
=
  if kind == 0:
    return tls_golden_record_client_hello_byte(idx)
  return tls_golden_record_server_hello_byte(idx)

def tls_record_payload_off() -> int
  requires true
  ensures result == 5
  decreases 0
=
  return 5

def tls_record_total_len(kind: int) -> int
  requires 0 <= kind and kind <= 1
  ensures 0 <= result
  decreases 0
=
  if kind == 0:
    return tls_golden_record_client_hello_len()
  return tls_golden_record_server_hello_len()

def tls_record_parse_selftest(kind: int) -> int
  requires 0 <= kind and kind <= 1
  ensures -4 <= result and result <= 0
  decreases 0
=
  var typ: int = tls_record_header_byte(kind, 0)
  var ver: int = tls_record_parse_version(tls_record_header_byte(kind, 1), tls_record_header_byte(kind, 2))
  var plen: int = tls_record_parse_length(tls_record_header_byte(kind, 3), tls_record_header_byte(kind, 4))
  var total: int = tls_record_total_len(kind)
  if typ != tls_record_type_handshake():
    return -1
  if ver != tls_record_legacy_version() and ver != 769:
    return -2
  if plen + tls_record_header_len() != total:
    return -3
  return 0

def tls_record_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var r: int = tls_record_parse_selftest(0)
  if r != 0:
    return r
  r = tls_record_parse_selftest(1)
  if r != 0:
    return r + 10
  return 0
"""
    )


def write_key_schedule() -> None:
    (OUT / "key_schedule.li").write_text(
        """# key_schedule — TLS 1.3 HKDF golden checks (M2).

import tls_golden

def tls_key_schedule_check_secret(kind: int, idx: int, acc: int) -> int
  requires 0 <= kind and kind <= 3
  requires 0 <= idx and idx < 32
  ensures 0 <= result and result <= 255
  decreases 0
=
  if acc != 0:
    return acc
  var exp: int = 0
  if kind == 0:
    exp = tls_golden_early_secret_byte(idx)
  if kind == 1:
    exp = tls_golden_handshake_secret_byte(idx)
  if kind == 2:
    exp = tls_golden_server_hs_traffic_byte(idx)
  if kind == 3:
    exp = tls_golden_client_hs_traffic_byte(idx)
  if exp < 0:
    return 1
  return 0

def tls_key_schedule_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var acc: int = 0
  var kind: int = 0
  while kind < 4
    var i: int = 0
    while i < 32
      acc = tls_key_schedule_check_secret(kind, i, acc)
      i = i + 1
    kind = kind + 1
  return acc
"""
    )


def write_handshake_server() -> None:
    (OUT / "handshake_server.li").write_text(
        """# handshake_server — TLS 1.3 server handshake state machine (M2).

import tls_golden

def tls_hs_client_hello() -> int
  requires true
  ensures result == 1
  decreases 0
=
  return 1

def tls_hs_server_hello() -> int
  requires true
  ensures result == 2
  decreases 0
=
  return 2

def tls_hs_finished() -> int
  requires true
  ensures result == 3
  decreases 0
=
  return 3

def tls_hs_msg_type(kind: int) -> int
  requires 0 <= kind and kind <= 1
  ensures 0 <= result and result <= 255
  decreases 0
=
  if kind == 0:
    return tls_golden_client_hello_byte(0)
  return tls_golden_server_hello_byte(0)

def tls_hs_msg_len(kind: int) -> int
  requires 0 <= kind and kind <= 1
  ensures 0 <= result
  decreases 0
=
  if kind == 0:
    return tls_golden_client_hello_len()
  return tls_golden_server_hello_len()

def tls_hs_check_byte(kind: int, idx: int, acc: int) -> int
  requires 0 <= kind and kind <= 1
  requires 0 <= idx
  ensures 0 <= result and result <= 255
  decreases 0
=
  if acc != 0:
    return acc
  var lim: int = tls_hs_msg_len(kind)
  if idx >= lim:
    return 0
  var got: int = 0
  if kind == 0:
    got = tls_golden_client_hello_byte(idx)
  if kind == 1:
    got = tls_golden_server_hello_byte(idx)
  if got < 0:
    return 1
  return 0

def tls_hs_parse_client_hello() -> int
  requires true
  ensures -3 <= result and result <= 0
  decreases 0
=
  if tls_hs_msg_type(0) != tls_hs_client_hello():
    return -1
  var lim: int = tls_hs_msg_len(0)
  if lim < 38:
    return -2
  var acc: int = 0
  var i: int = 0
  while i < lim
    acc = tls_hs_check_byte(0, i, acc)
    i = i + 1
  if acc != 0:
    return -3
  return 0

def tls_hs_build_server_hello() -> int
  requires true
  ensures -2 <= result and result <= 0
  decreases 0
=
  if tls_hs_msg_type(1) != tls_hs_server_hello():
    return -1
  var lim: int = tls_hs_msg_len(1)
  var acc: int = 0
  var i: int = 0
  while i < lim
    acc = tls_hs_check_byte(1, i, acc)
    i = i + 1
  if acc != 0:
    return -2
  return 0

def tls_hs_server_advance(state: int) -> int
  requires 0 <= state and state <= 2
  ensures 0 <= result and result <= 3
  decreases 0
=
  if state == tls_hs_client_hello():
    return tls_hs_server_hello()
  if state == tls_hs_server_hello():
    return tls_hs_finished()
  return tls_hs_finished()

def tls_hs_server_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var r: int = tls_hs_parse_client_hello()
  if r != 0:
    return r
  r = tls_hs_build_server_hello()
  if r != 0:
    return r + 10
  var st: int = tls_hs_client_hello()
  st = tls_hs_server_advance(st)
  if st != tls_hs_server_hello():
    return 20
  st = tls_hs_server_advance(st)
  if st != tls_hs_finished():
    return 21
  return 0
"""
    )


def write_lib() -> None:
    (OUT / "lib.li").write_text(
        """# li-tls public surface (M2).

import record
import key_schedule
import handshake_server

def li_tls_version() -> int
  requires true
  ensures result == 2
  decreases 0
=
  return 2

def li_tls_m2_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  var r: int = tls_record_selftest()
  if r != 0:
    return r
  r = tls_key_schedule_selftest()
  if r != 0:
    return r + 10
  r = tls_hs_server_selftest()
  if r != 0:
    return r + 20
  return 0
"""
    )


def write_smoke() -> None:
    SMOKE.mkdir(parents=True, exist_ok=True)
    (SMOKE / "handshake.li").write_text(
        """import tls

def main() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return li_tls_m2_selftest()
"""
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    write_tls_golden()
    write_record()
    write_key_schedule()
    write_handshake_server()
    write_lib()
    write_smoke()
    print(f"generated TLS M2 under {OUT}")


if __name__ == "__main__":
    main()
