#!/usr/bin/env python3
"""Orchestrate header-strip integration test (proxy + backend)."""
from __future__ import annotations

import socket
import subprocess
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HTTPD = ROOT / "build" / "li-httpd"
PUBLIC = ROOT / "packages/li-httpd/examples/public"


class Backend(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", "2")
        self.send_header("X-Internal-Secret", "must-not-leak")
        self.end_headers()
        self.wfile.write(b"ok")


def pick_port() -> int:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("127.0.0.1", 0))
    port = s.getsockname()[1]
    s.close()
    return int(port)


def wait_listen(port: int, timeout: float = 8.0) -> bool:
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            s = socket.create_connection(("127.0.0.1", port), timeout=0.2)
            s.close()
            return True
        except OSError:
            time.sleep(0.05)
    return False


def write_runtime_conf(path: Path, front: int, be: int) -> None:
    dr = PUBLIC.resolve()
    path.write_text(
        "\n".join(
            [
                f"listen_port={front}",
                f"document_root={dr}",
                "strip_internal_headers=1",
                "route=GET|/|prefix|proxy",
                f"upstream_peer={be}",
                "",
            ]
        ),
        encoding="utf-8",
    )


def main() -> int:
    if not HTTPD.is_file():
        print("test-strip-internal-headers: build li-httpd first", file=sys.stderr)
        return 1
    be = pick_port()
    front = pick_port()
    conf = Path(f"/tmp/hstrip-{front}.conf")
    write_runtime_conf(conf, front, be)

    threading.Thread(
        target=lambda: ThreadingHTTPServer(("127.0.0.1", be), Backend).serve_forever(),
        daemon=True,
    ).start()
    if not wait_listen(be, 4.0):
        print("test-strip-internal-headers: backend not listening", file=sys.stderr)
        return 1

    proc = subprocess.Popen([str(HTTPD), str(conf)], cwd=ROOT)
    if not wait_listen(front, 6.0):
        rc = proc.poll()
        proc.terminate()
        proc.wait(timeout=3)
        print(f"test-strip-internal-headers: front not listening (httpd poll={rc})", file=sys.stderr)
        return 1

    try:
        out = subprocess.check_output(
            ["curl", "-s", "-m", "5", "-D", "-", f"http://127.0.0.1:{front}/", "-o", "/dev/null"],
            text=True,
        )
    finally:
        proc.terminate()
        proc.wait(timeout=5)
        conf.unlink(missing_ok=True)

    low = out.lower()
    if "x-internal" in low:
        print("test-strip-internal-headers: FAIL x-internal-* leaked", file=sys.stderr)
        print(out, file=sys.stderr)
        return 1
    if "200" not in out:
        print("test-strip-internal-headers: FAIL no HTTP 200", repr(out), file=sys.stderr)
        return 1
    print("test-strip-internal-headers: ok (no x-internal-* in response)", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
