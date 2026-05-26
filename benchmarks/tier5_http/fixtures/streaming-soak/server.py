#!/usr/bin/env python3
"""Long-lived SSE + WebSocket fanout backend for tier5_http streaming soak scenarios."""

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import sys
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse

MAGIC = b"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
DEFAULT_WS_FRAMES = 3


def _sse_events(count: int, interval_sec: float) -> bytes:
    chunks: list[bytes] = []
    for i in range(count):
        payload = json.dumps({"n": i + 1}).encode()
        chunks.append(b"event: tick\n")
        chunks.append(b"data: " + payload + b"\n\n")
        if interval_sec > 0 and i + 1 < count:
            time.sleep(interval_sec)
    return b"".join(chunks)


class StreamingSoakHandler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    ws_frames_default = DEFAULT_WS_FRAMES

    def log_message(self, format: str, *args: object) -> None:
        return

    def _handle_ws_upgrade(self, frames: int) -> None:
        key = self.headers.get("Sec-WebSocket-Key", "")
        if not key:
            self.send_error(400)
            return
        accept = base64.b64encode(hashlib.sha1(key.encode() + MAGIC).digest()).decode()
        self.send_response(101, "Switching Protocols")
        self.send_header("Upgrade", "websocket")
        self.send_header("Connection", "Upgrade")
        self.send_header("Sec-WebSocket-Accept", accept)
        self.end_headers()
        conn = self.connection
        for i in range(max(1, frames)):
            payload = f"tick{i}".encode()
            frame = bytes([0x81, len(payload)]) + payload
            conn.sendall(frame)
            time.sleep(0.01)
        conn.close()

    def do_GET(self) -> None:
        parsed = urlparse(self.path)
        path = parsed.path
        qs = parse_qs(parsed.query)
        if path == "/stream/ws":
            if self.headers.get("Upgrade", "").lower() == "websocket":
                frames = int((qs.get("frames") or [str(self.ws_frames_default)])[0])
                self._handle_ws_upgrade(max(1, min(frames, 32)))
                return
            self.send_response(426, "Upgrade Required")
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"upgrade required\n")
            return
        if path == "/stream/sse":
            count = int((qs.get("count") or ["40"])[0])
            interval_ms = int((qs.get("interval_ms") or ["25"])[0])
            interval_sec = max(0, interval_ms) / 1000.0
            count = max(1, min(count, 500))
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream; charset=utf-8")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "close")
            self.end_headers()
            for i in range(count):
                payload = json.dumps({"n": i + 1}).encode()
                self.wfile.write(b"event: tick\n")
                self.wfile.write(b"data: " + payload + b"\n\n")
                self.wfile.flush()
                if interval_sec > 0 and i + 1 < count:
                    time.sleep(interval_sec)
            return
        self.send_error(404)

    def do_POST(self) -> None:
        self.do_GET()


def main() -> int:
    parser = argparse.ArgumentParser(description="tier5 streaming-soak backend")
    parser.add_argument("port", type=int, help="HTTP listen port")
    parser.add_argument("--ws-frames", type=int, default=DEFAULT_WS_FRAMES, help="WS text frames per connection")
    args = parser.parse_args()
    StreamingSoakHandler.ws_frames_default = max(1, args.ws_frames)
    if args.port < 1024 or args.port > 65000:
        print("streaming-soak: invalid port", file=sys.stderr)
        return 2
    httpd = ThreadingHTTPServer(("127.0.0.1", args.port), StreamingSoakHandler)
    sys.stdout.write(f"streaming-soak listening on 127.0.0.1:{args.port}\n")
    sys.stdout.flush()
    httpd.serve_forever()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
