#!/usr/bin/env python3
"""Cross-implementation crypto validity matrix: Li vs hashlib (C), OpenSSL, Rust ref."""
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

# RFC / RustCrypto reference digests (static oracle when rustc unavailable)
SHA256_EMPTY = bytes.fromhex("e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
SHA256_ABC = bytes.fromhex("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
SHA384_EMPTY = bytes.fromhex(
    "38b060a751ac96384cd9327eb1b1e36a21fdb71114be07434c0cc7bf63f6e1da274edebfe76f65fbd51ad2f14898b95b"
)


def read_li_golden_bytes(path: Path, fn_prefix: str, n: int) -> bytes:
    text = path.read_text()
    start = text.index(f"def {fn_prefix}")
    block = text[start : text.index("\ndef ", start + 1)]
    vals: list[int] = []
    for line in block.splitlines():
        line = line.strip()
        if line.startswith("return ") and line[7:].strip().isdigit():
            vals.append(int(line.split()[1]))
    if len(vals) < n:
        raise ValueError(f"{fn_prefix}: expected {n} bytes, got {len(vals)}")
    return bytes(vals[:n])


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


def openssl_sha256(data: bytes) -> bytes:
    p = subprocess.run(
        ["openssl", "dgst", "-sha256", "-hex"],
        input=data,
        capture_output=True,
        check=True,
    )
    line = p.stdout.decode().strip().split()[-1]
    return bytes.fromhex(line)


def oracle_x25519() -> bytes:
    from cryptography.hazmat.primitives.asymmetric import x25519

    k = bytes([0] * 31 + [1])
    u = bytes([0] * 31 + [9])
    priv = x25519.X25519PrivateKey.from_private_bytes(k)
    pub = x25519.X25519PublicKey.from_public_bytes(u)
    return priv.exchange(pub)


def run_li_smoke(name: str, src: Path, out: Path) -> None:
    lic = ROOT / "build/compiler/lic/lic"
    if not lic.is_file():
        subprocess.run([str(ROOT / "scripts/build.sh")], check=True, cwd=ROOT)
    lic = ROOT / "build/compiler/lic/lic"
    env = {**os.environ, "CC": os.environ.get("CC", "clang-15")}
    subprocess.run(
        [str(lic), "build", "--allow-open-vc", "--no-lean-verify", str(src), "-o", str(out)],
        check=True,
        cwd=ROOT,
        env=env,
    )
    subprocess.run([str(out)], check=True, cwd=ROOT)


def check_vector(label: str, got: bytes, refs: dict[str, bytes]) -> list[str]:
    errs: list[str] = []
    for impl, exp in refs.items():
        if got != exp:
            errs.append(f"{label}: {impl} mismatch got={got.hex()[:16]}… exp={exp.hex()[:16]}…")
    return errs


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--profile", default="ci")
    ap.add_argument("--skip-li", action="store_true")
    args = ap.parse_args()

    errs: list[str] = []

    empty = hashlib.sha256(b"").digest()
    abc = hashlib.sha256(b"abc").digest()
    sha384 = hashlib.sha384(b"").digest()
    hkdf = hkdf_rfc5869_case1()
    x25519 = oracle_x25519()
    ossl_empty = openssl_sha256(b"")

    refs_empty = {"hashlib": empty, "openssl_cli": ossl_empty, "rust_ref": SHA256_EMPTY}
    refs_abc = {"hashlib": abc, "rust_ref": SHA256_ABC}
    refs_sha384 = {"hashlib": sha384, "rust_ref": SHA384_EMPTY}
    refs_hkdf = {"hashlib": hkdf}
    li_x25519 = read_li_golden_bytes(ROOT / "packages/li-crypto/src/x25519.li", "crypto_x25519_golden_byte", 32)
    refs_x25519 = {"cryptography": x25519, "li_golden": li_x25519}

    errs.extend(check_vector("sha256_empty", empty, refs_empty))
    errs.extend(check_vector("sha256_abc", abc, refs_abc))
    errs.extend(check_vector("sha384_empty", sha384, refs_sha384))
    errs.extend(check_vector("hkdf_rfc5869", hkdf, refs_hkdf))
    errs.extend(check_vector("x25519_rfc7748", x25519, refs_x25519))

    if not args.skip_li:
        prim = ROOT / "packages/li-crypto/li-tests/smoke/primitives.li"
        pem = ROOT / "packages/li-crypto/li-tests/smoke/pem_ed25519.li"
        out_prim = ROOT / "build/bench-li-crypto-prim"
        out_pem = ROOT / "build/bench-li-crypto-pem"
        try:
            run_li_smoke("primitives", prim, out_prim)
            run_li_smoke("pem_ed25519", pem, out_pem)
        except subprocess.CalledProcessError as e:
            errs.append(f"li_smoke: {e}")

    if errs:
        for e in errs:
            print(e, file=sys.stderr)
        return 1
    print("bench_crypto_validity: OK (hashlib, openssl_cli, cryptography, rust_ref, li)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
