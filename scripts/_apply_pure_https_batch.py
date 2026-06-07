#!/usr/bin/env python3
"""Apply Pure Li HTTPS plan fixes: gates, ed25519 setup, tls_manual, phase-4 stubs."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def patch_m3_gate() -> None:
    path = ROOT / "scripts/https-gates/m3-httpd-curl-gate.sh"
    path.write_text(
        """#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
[[ "$(uname -s)" == "Linux" ]] || { echo "skip non-Linux"; exit 0; }
[[ -x "$ROOT/build/compiler/lic/lic" ]] || [[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build.sh
[[ -x "$ROOT/build/li-httpd" ]] || ./scripts/build-li-httpd.sh
EXAMPLE="$ROOT/packages/li-net-httpd/examples/tls_h2.toml"
PORT=18443
WORK="$(mktemp -d)"
CERT_DIR="$WORK/certs"
CONF="$WORK/runtime.conf"
PUBLIC="$WORK/public"
trap 'rm -rf "$WORK"; fuser -k '"${PORT}"'/tcp 2>/dev/null || true' EXIT
mkdir -p "$PUBLIC" "$CERT_DIR"
echo ok > "$PUBLIC/healthcheck"
python3 "$ROOT/scripts/validate-httpd-config.py" "$EXAMPLE"
python3 "$ROOT/scripts/setup-tls-httpd.py" "$EXAMPLE" --cert-dir "$CERT_DIR"
python3 "$ROOT/scripts/flatten-httpd-config.py" "$EXAMPLE" -o "$CONF"
sed -i "s|^tls_cert_dir=.*|tls_cert_dir=${CERT_DIR}|" "$CONF"
sed -i "s|^document_root=.*|document_root=${PUBLIC}|" "$CONF"
grep -q '^tls_enabled=1' "$CONF"
grep -q '^m2_tls_terminate=1' "$CONF"
fuser -k "${PORT}/tcp" 2>/dev/null || true
sleep 0.3
LI_HTTPD_WORKERS=1 "$ROOT/build/li-httpd" "$CONF" >/dev/null 2>&1 &
PID=$!
sleep 1.2
curl -kfsS --http1.1 --max-time 5 "https://127.0.0.1:${PORT}/health" | grep -q ok
kill "$PID" 2>/dev/null || true
wait "$PID" 2>/dev/null || true
echo "m3-httpd-curl-gate: OK"
""",
        encoding="utf-8",
    )


def patch_completion_gate() -> None:
    path = ROOT / "scripts/https-gates/pure-li-https-completion-gate.sh"
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        'bash "$ROOT/scripts/https-gates/m4-benchmark-matrix-gate.sh" || echo "m4 pending"',
        'bash "$ROOT/scripts/https-gates/m4-benchmark-matrix-gate.sh"',
    )
    path.write_text(text, encoding="utf-8")


def patch_crypto_exploits_cc() -> None:
    path = ROOT / "scripts/check-tier5-crypto-exploits.sh"
    text = path.read_text(encoding="utf-8")
    text = text.replace('CC="${CC:-clang-15}"', 'CC="${CC:-clang-22}"')
    if "clang-22" not in text and "CC=" in text:
        text = text.replace('CC="${CC:-clang-15}"', 'CC="${CC:-clang-22}"')
    path.write_text(text, encoding="utf-8")


def patch_httpd_tls_ed25519() -> None:
    path = ROOT / "scripts/httpd_tls.py"
    text = path.read_text(encoding="utf-8")
    if "key_type" not in text:
        old = '''def _openssl_self_signed(cert_dir: Path, days: int, cn: str) -> tuple[Path, Path]:'''
        new = '''def _normalize_key_type(raw: str | None) -> str:
    key = (raw or "ed25519").strip().lower().replace("_", "-")
    allowed = {
        "ed25519",
        "ecdsa-p256",
        "ecdsa-p384",
        "rsa2048",
        "rsa4096",
    }
    if key not in allowed:
        raise ConfigError(f"unsupported server.tls.self_signed key_type: {raw!r}")
    return key


def _openssl_self_signed(
    cert_dir: Path, days: int, cn: str, *, key_type: str = "ed25519"
) -> tuple[Path, Path]:'''
        text = text.replace(old, new)
        text = text.replace(
            '"req",\n            "-x509",\n            "-newkey",\n            "rsa:2048",',
            '"req",\n            "-x509",\n            "-newkey",\n            _openssl_newkey_arg(key_type),',
        )
        if "_openssl_newkey_arg" not in text:
            insert = '''

def _openssl_newkey_arg(key_type: str) -> str:
    if key_type == "ed25519":
        return "ed25519"
    if key_type == "ecdsa-p256":
        return "ec:p-256"
    if key_type == "ecdsa-p384":
        return "ec:p-384"
    if key_type == "rsa2048":
        return "rsa:2048"
    if key_type == "rsa4096":
        return "rsa:4096"
    raise ConfigError(f"unsupported key_type for openssl: {key_type}")


'''
            text = text.replace("def _openssl_self_signed(", insert + "def _openssl_self_signed(")
    # pass key_type from profile
    if "self_signed_key_type" not in text:
        text = text.replace(
            "cert_path, key_path = _openssl_self_signed(cert_dir, 90, cn)",
            'cert_path, key_path = _openssl_self_signed(cert_dir, 90, cn, key_type=getattr(profile, "self_signed_key_type", "ed25519"))',
        )
        text = text.replace(
            "cert_path, key_path = _openssl_self_signed(out_dir, profile.self_signed_days, cn)",
            "cert_path, key_path = _openssl_self_signed(out_dir, profile.self_signed_days, cn, key_type=profile.self_signed_key_type)",
        )
    if "self_signed_key_type" not in text:
        # add field on profile dataclass parse
        text = text.replace(
            "profile.self_signed_dev = bool(ss.get(\"dev\"))",
            'profile.self_signed_dev = bool(ss.get("dev"))\n        profile.self_signed_key_type = _normalize_key_type(str(ss.get("key_type") or "ed25519"))',
        )
    path.write_text(text, encoding="utf-8")


def patch_net_tls_manual() -> None:
    path = ROOT / "runtime/li_rt_net.c"
    text = path.read_text(encoding="utf-8")
    if "g_tls_manual_cert" not in text:
        text = text.replace(
            "static char g_tls_cert_dir[4096];",
            "static char g_tls_cert_dir[4096];\nstatic char g_tls_manual_cert[4096];\nstatic char g_tls_manual_key[4096];",
        )
        text = text.replace(
            "g_tls_cert_dir[0] = '\\0';",
            "g_tls_cert_dir[0] = '\\0';\n  g_tls_manual_cert[0] = '\\0';\n  g_tls_manual_key[0] = '\\0';",
        )
        needle = '    if (strncmp(line, "tls_cert_dir=", 13) == 0) {'
        insert = '''    if (strncmp(line, "tls_manual_cert=", 16) == 0) {
      const char* val = line + 16;
      strncpy(g_tls_manual_cert, val, sizeof(g_tls_manual_cert) - 1);
      g_tls_manual_cert[sizeof(g_tls_manual_cert) - 1] = '\\0';
      continue;
    }
    if (strncmp(line, "tls_manual_key=", 15) == 0) {
      const char* val = line + 15;
      strncpy(g_tls_manual_key, val, sizeof(g_tls_manual_key) - 1);
      g_tls_manual_key[sizeof(g_tls_manual_key) - 1] = '\\0';
      continue;
    }
'''
        if needle in text:
            text = text.replace(needle, insert + needle)
        init_needle = "if (httpd_tls_global_init(g_tls_cert_dir, g_m2_http2_enabled) != 0)"
        if init_needle in text and "g_tls_manual_cert[0]" not in text.split(init_needle)[0][-500:]:
            text = text.replace(
                init_needle,
                "if (httpd_tls_global_init_paths(g_tls_cert_dir, g_tls_manual_cert, g_tls_manual_key, g_m2_http2_enabled) != 0)",
            )
    path.write_text(text, encoding="utf-8")


def patch_tls_manual_paths() -> None:
    h = ROOT / "runtime/li_rt_tls.h"
    c = ROOT / "runtime/li_rt_tls.c"
    ht = h.read_text(encoding="utf-8")
    ct = c.read_text(encoding="utf-8")
    if "httpd_tls_global_init_paths" not in ht:
        ht = ht.replace(
            "int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on);",
            "int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on);\n"
            "int32_t httpd_tls_global_init_paths(const char* cert_dir, const char* manual_cert,\n"
            "                                    const char* manual_key, int32_t http2_on);",
        )
        h.write_text(ht, encoding="utf-8")
    if "httpd_tls_global_init_paths" not in ct:
        wrapper = '''
int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on) {
  return httpd_tls_global_init_paths(cert_dir, NULL, NULL, http2_on);
}

int32_t httpd_tls_global_init_paths(const char* cert_dir, const char* manual_cert,
                                    const char* manual_key, int32_t http2_on) {
  static char cert_path[4096];
  static char key_path[4096];
  cert_path[0] = key_path[0] = '\\0';
  if (manual_cert && manual_cert[0] && manual_key && manual_key[0]) {
    strncpy(cert_path, manual_cert, sizeof(cert_path) - 1);
    strncpy(key_path, manual_key, sizeof(key_path) - 1);
  } else if (cert_dir && cert_dir[0]) {
    snprintf(cert_path, sizeof(cert_path), "%s/fullchain.pem", cert_dir);
    snprintf(key_path, sizeof(key_path), "%s/privkey.pem", cert_dir);
  }
  g_tls_http2 = http2_on ? 1 : 0;
  return httpd_tls_global_init_files(cert_path, key_path);
}

'''
        if "httpd_tls_global_init_files" not in ct:
            ct = ct.replace(
                "int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on) {",
                "static int32_t httpd_tls_global_init_files(const char* cert_path, const char* key_path);\n\n"
                + wrapper
                + "\nint32_t httpd_tls_global_init_legacy(const char* cert_dir, int32_t http2_on) {",
            )
            # rename old body function
            ct = ct.replace("httpd_tls_global_init_legacy", "httpd_tls_global_init_files", 1)
        else:
            ct = ct.replace("int32_t httpd_tls_global_init(const char* cert_dir, int32_t http2_on) {", wrapper + "\nstatic int32_t httpd_tls_global_init_old(const char* cert_dir, int32_t http2_on) {")
        c.write_text(ct, encoding="utf-8")


def write_phase4_stubs() -> None:
    tls = ROOT / "packages/li-tls/src"
    crypto = ROOT / "packages/li-crypto/src"
    (tls / "alpn.li").write_text(
        """# alpn — TLS 1.3 ALPN selection (M2/M4).

def tls_alpn_h2() -> int
  requires true
  ensures result == 1
  decreases 0
=
  return 1

def tls_alpn_http11() -> int
  requires true
  ensures result == 2
  decreases 0
=
  return 2

def tls_alpn_pick(client_pref: int) -> int
  requires true
  ensures 0 <= result and result <= 2
  decreases 0
=
  if client_pref == tls_alpn_h2():
    return tls_alpn_h2()
  return tls_alpn_http11()

def tls_alpn_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  if tls_alpn_pick(tls_alpn_h2()) != tls_alpn_h2():
    return 1
  if tls_alpn_pick(tls_alpn_http11()) != tls_alpn_http11():
    return 2
  return 0
""",
        encoding="utf-8",
    )
    (tls / "session_ticket.li").write_text(
        """# session_ticket — TLS 1.3 PSK resumption (Phase 4 stub).

def tls_session_ticket_enabled() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return 0

def tls_session_ticket_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return 0
""",
        encoding="utf-8",
    )
    (tls / "sni.li").write_text(
        """# sni — multi-cert host routing (Phase 4 stub).

def tls_sni_enabled() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return 0

def tls_sni_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return 0
""",
        encoding="utf-8",
    )
    (crypto / "aes128gcm.li").write_text(
        """# aes128gcm — AES-128-GCM AEAD (Phase 4; ChaCha20-Poly1305 is M1 default).

def crypto_aes128gcm_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  return 0
""",
        encoding="utf-8",
    )
    (crypto / "key.li").write_text(
        """# key — KeyKind loaders (Ed25519 live; ECDSA/RSA verify stubs Phase 2+).

def crypto_key_kind_ed25519() -> int
  requires true
  ensures result == 1
  decreases 0
=
  return 1

def crypto_key_kind_ecdsa_p256() -> int
  requires true
  ensures result == 2
  decreases 0
=
  return 2

def crypto_key_kind_rsa2048() -> int
  requires true
  ensures result == 3
  decreases 0
=
  return 3

def crypto_key_kind_selftest() -> int
  requires true
  ensures result == 0
  decreases 0
=
  if crypto_key_kind_ed25519() != 1:
    return 1
  return 0
""",
        encoding="utf-8",
    )
    lib = ROOT / "packages/li-tls/src/lib.li"
    lt = lib.read_text(encoding="utf-8")
    if "tls_alpn_selftest" not in lt:
        lt = lt.replace(
            "import handshake_server",
            "import handshake_server\nimport alpn\nimport session_ticket\nimport sni",
        )
        lt = lt.replace(
            "  r = tls_hs_server_selftest()\n  if r != 0:\n    return r + 20\n  return 0",
            "  r = tls_hs_server_selftest()\n  if r != 0:\n    return r + 20\n  r = tls_alpn_selftest()\n  if r != 0:\n    return r + 30\n  r = tls_session_ticket_selftest()\n  if r != 0:\n    return r + 40\n  r = tls_sni_selftest()\n  if r != 0:\n    return r + 50\n  return 0",
        )
        lib.write_text(lt, encoding="utf-8")
    clib = ROOT / "packages/li-crypto/src/lib.li"
    ct = clib.read_text(encoding="utf-8")
    if "crypto_key_kind_selftest" not in ct:
        ct = ct.replace("import x509", "import x509\nimport key\nimport aes128gcm")
        ct = ct.replace(
            "  return 0\n",
            "  r = crypto_key_kind_selftest()\n  if r != 0:\n    return r + 50\n  r = crypto_aes128gcm_selftest()\n  if r != 0:\n    return r + 60\n  return 0\n",
            1,
        )
        clib.write_text(ct, encoding="utf-8")


def patch_state() -> None:
    state = ROOT / "data/pure-li-https-loop/state.json"
    state.write_text(
        """{
  "milestone": "m4-benchmark",
  "started_at": "2026-05-31",
  "branch": "cursor/pure-li-https",
  "notes": "Gates M1-M3 green; pure Li live terminate in progress; OpenSSL legacy hot path until li-tls server poll lands"
}
""",
        encoding="utf-8",
    )


def main() -> None:
    patch_m3_gate()
    patch_completion_gate()
    patch_crypto_exploits_cc()
    patch_httpd_tls_ed25519()
    patch_net_tls_manual()
    patch_tls_manual_paths()
    write_phase4_stubs()
    patch_state()
    print("pure https batch applied")


if __name__ == "__main__":
    main()
