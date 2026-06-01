#!/usr/bin/env python3
"""Smoke: li-httpd serves cleartext HTTP and HTTPS on separate ports simultaneously."""
from __future__ import annotations

import os
import socket
import ssl
import subprocess
import sys
import tempfile
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HARNESS = ROOT.parent / "benchmarks" / "vendor" / "lis-tier5" / "benchmarks" / "tier5_http" / "harness"
sys.path.insert(0, str(HARNESS))


def pick_port() -> int:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("127.0.0.1", 0))
    p = s.getsockname()[1]
    s.close()
    return p


def main() -> int:
    li_bin = Path(os.environ.get("LI_HTTPD_BIN", ROOT / "build" / "li-httpd"))
    if not li_bin.is_file():
        print("dual_listen_smoke: missing li-httpd", file=sys.stderr)
        return 2

    https_port = pick_port()
    http_port = pick_port()
    while http_port == https_port:
        http_port = pick_port()

    doc_root = HARNESS.parent / "fixtures" / "static"
    if not doc_root.is_dir():
        doc_root = ROOT

    with tempfile.TemporaryDirectory(prefix="lis-dual-") as td:
        td_path = Path(td)
        cert = td_path / "server.crt"
        key = td_path / "server.key"
        subprocess.run(
            [
                "openssl",
                "req",
                "-x509",
                "-newkey",
                "rsa:2048",
                "-nodes",
                "-keyout",
                str(key),
                "-out",
                str(cert),
                "-days",
                "1",
                "-subj",
                "/CN=localhost",
            ],
            check=True,
            capture_output=True,
        )
        from http_oracles import write_li_tls_runtime_conf  # type: ignore

        conf = td_path / "runtime.conf"
        write_li_tls_runtime_conf(conf, port=https_port, doc_root=doc_root, cert=cert, key=key)
        conf_text = conf.read_text(encoding="utf-8")
        conf.write_text(conf_text + f"listen_port_http={http_port}\n", encoding="utf-8")

        env = {
            **os.environ,
            "LI_HTTPD_TLS_LEGACY_OPENSSL": "1",
            "LI_HTTPD_M2_HTTP2": "0",
            "LI_HTTPD_WORKERS": "1",
        }
        proc = subprocess.Popen(
            [str(li_bin), str(conf.resolve())],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            env=env,
        )
        try:
            deadline = time.time() + 12
            http_ok = False
            https_ok = False
            ctx = ssl.create_default_context()
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE
            while time.time() < deadline and (not http_ok or not https_ok):
                if not http_ok:
                    try:
                        with urllib.request.urlopen(
                            f"http://127.0.0.1:{http_port}/", timeout=1
                        ) as r:
                            http_ok = r.status == 200
                    except OSError:
                        pass
                if not https_ok:
                    try:
                        with socket.create_connection(("127.0.0.1", https_port), timeout=1) as raw:
                            with ctx.wrap_socket(raw, server_hostname="localhost") as ss:
                                ss.sendall(
                                    b"GET / HTTP/1.1\r\nHost: localhost\r\nConnection: close\r\n\r\n"
                                )
                                ss.recv(64)
                                https_ok = True
                    except OSError:
                        pass
                time.sleep(0.05)
            if proc.poll() is not None:
                print("dual_listen_smoke: li-httpd exited early", file=sys.stderr)
                return 1
            if not http_ok or not https_ok:
                print(
                    f"dual_listen_smoke: http={http_ok} https={https_ok} "
                    f"(ports {http_port}/{https_port})",
                    file=sys.stderr,
                )
                return 1
            print(f"dual_listen_smoke: OK (http :{http_port}, https :{https_port})")
            return 0
        finally:
            if proc.poll() is None:
                proc.terminate()
                try:
                    proc.wait(timeout=3)
                except subprocess.TimeoutExpired:
                    proc.kill()


if __name__ == "__main__":
    raise SystemExit(main())
