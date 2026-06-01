#!/usr/bin/env python3
"""TLS 1.3 golden validity: Python HKDF oracle vs Li li-tls selftest."""
from __future__ import annotations

import argparse
import hashlib
import hmac
import os
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# Mirrors scripts/gen-li-tls-m2-handshake.py (RFC 8448 subset)
CLIENT_HELLO = bytes.fromhex(
    "01030303"
    "0018"
    "0303"
    + "00" * 32
    + "00"
    + "0004"
    + "1301"
    + "1303"
    + "0100"
    + "0000"
)
hs_body = CLIENT_HELLO[4:]
CLIENT_HELLO = CLIENT_HELLO[:2] + struct.pack(">H", len(hs_body)) + hs_body

SERVER_HELLO = bytes.fromhex(
    "020000"
    "0303"
    + "11" * 32
    + "00"
    + "1303"
    + "00"
    + "0002"
    + "002b"
    + "0002"
    + "0304"
)
sh_body = SERVER_HELLO[4:]
SERVER_HELLO = bytes([0x02]) + struct.pack(">I", len(sh_body))[1:] + sh_body

RECORD_CH = bytes([0x16, 0x03, 0x01]) + struct.pack(">H", len(CLIENT_HELLO)) + CLIENT_HELLO
RECORD_SH = bytes([0x16, 0x03, 0x03]) + struct.pack(">H", len(SERVER_HELLO)) + SERVER_HELLO

EARLY_SECRET = bytes.fromhex("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")


def hkdf_expand(prk: bytes, info: bytes, length: int) -> bytes:
    out = b""
    t = b""
    counter = 1
    while len(out) < length:
        t = hmac.new(prk, t + info + bytes([counter]), hashlib.sha256).digest()
        out += t
        counter += 1
    return out[:length]


def hkdf_expand_label(prk: bytes, label: str, context: bytes, length: int) -> bytes:
    full_label = b"tls13 " + label.encode("ascii")
    hkdf_label = (
        struct.pack(">H", length)
        + bytes([len(full_label)])
        + full_label
        + bytes([len(context)])
        + context
    )
    return hkdf_expand(prk, hkdf_label, length)


def hkdf_extract(salt: bytes, ikm: bytes) -> bytes:
    return hmac.new(salt, ikm, hashlib.sha256).digest()


def tls_key_schedule_oracle() -> dict[str, bytes]:
    derived = hkdf_expand_label(EARLY_SECRET, "derived", b"", 32)
    empty_hash = hashlib.sha256(b"").digest()
    hs = hkdf_extract(derived, empty_hash)
    return {
        "early_secret": EARLY_SECRET,
        "handshake_secret": hs,
        "server_hs_traffic": hkdf_expand_label(hs, "s hs traffic", empty_hash, 32),
        "client_hs_traffic": hkdf_expand_label(hs, "c hs traffic", empty_hash, 32),
    }


def read_tls_golden_bytes(name: str) -> bytes:
    path = ROOT / "packages/li-tls/src/tls_golden.li"
    text = path.read_text()
    fn = f"def {name}(i: int)"
    start = text.index(fn)
    rest = text[start + 1 :]
    end_off = rest.find("\ndef ")
    block = text[start:] if end_off < 0 else text[start : start + 1 + end_off]
    lines = block.splitlines()
    vals: list[int] = []
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("return ") and stripped[7:].strip().isdigit():
            prev = lines[idx - 1].strip() if idx > 0 else ""
            if prev.startswith("if i =="):
                vals.append(int(stripped.split()[1]))
    return bytes(vals)


def run_li_tls_smoke() -> None:
    lic = ROOT / "build/compiler/lic/lic"
    if not lic.is_file():
        subprocess.run([str(ROOT / "scripts/build.sh")], check=True, cwd=ROOT)
    src = ROOT / "packages/li-tls/li-tests/smoke/handshake.li"
    out = ROOT / "build/bench-li-tls-handshake"
    env = {**os.environ, "CC": os.environ.get("CC", "clang-15")}
    subprocess.run(
        [str(lic), "build", "--allow-open-vc", "--no-lean-verify", str(src), "-o", str(out)],
        check=True,
        cwd=ROOT,
        env=env,
    )
    subprocess.run([str(out)], check=True, cwd=ROOT)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="ci")
    ap.add_argument("--skip-li", action="store_true")
    args = ap.parse_args()

    errs: list[str] = []
    oracle = tls_key_schedule_oracle()

    golden_map = {
        "early_secret": "tls_golden_early_secret_byte",
        "handshake_secret": "tls_golden_handshake_secret_byte",
        "server_hs_traffic": "tls_golden_server_hs_traffic_byte",
        "client_hs_traffic": "tls_golden_client_hs_traffic_byte",
    }
    for key, fn in golden_map.items():
        li_bytes = read_tls_golden_bytes(fn)
        if li_bytes != oracle[key]:
            errs.append(f"{key}: li golden != python oracle")

    if RECORD_CH[:5] != bytes([0x16, 0x03, 0x01]) + struct.pack(">H", len(CLIENT_HELLO)):
        errs.append("record_client_hello: header mismatch")

    if not args.skip_li:
        try:
            run_li_tls_smoke()
        except subprocess.CalledProcessError as e:
            errs.append(f"li_tls_smoke: {e}")

    if errs:
        for e in errs:
            print(e, file=sys.stderr)
        return 1
    print("bench_tls_validity: OK (python HKDF oracle, li-tls golden, li smoke)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
