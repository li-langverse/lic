"""Concurrent SSE / WebSocket soak load for tier5_http streaming scenarios."""

from __future__ import annotations

import base64
import hashlib
import http.client
import os
import re
import socket
import threading
import time
from typing import Any
from urllib.parse import urlparse

MAGIC = b"258EAFA5-E914-47DA-95CA-C5AB0DC85B11"


def _sse_once(host: str, port: int, path: str, *, events_min: int, timeout: float) -> tuple[bool, float]:
    conn = http.client.HTTPConnection(host, port, timeout=timeout)
    try:
        t0 = time.perf_counter()
        conn.request("GET", path, headers={"Accept": "text/event-stream"})
        resp = conn.getresponse()
        if resp.status != 200:
            return False, time.perf_counter() - t0
        ticks = 0
        deadline = t0 + timeout
        while ticks < events_min and time.perf_counter() < deadline:
            try:
                chunk = resp.read(4096)
            except http.client.IncompleteRead as exc:
                chunk = exc.partial
            if not chunk:
                break
            ticks += chunk.count(b"event: tick")
        elapsed = time.perf_counter() - t0
        return ticks >= events_min, elapsed
    except (OSError, http.client.HTTPException, http.client.IncompleteRead):
        return False, time.perf_counter() - t0
    finally:
        conn.close()


def run_sse_soak(
    url: str,
    *,
    concurrent: int,
    events_min: int,
    duration_sec: int,
) -> dict[str, float]:
    parsed = urlparse(url)
    host = parsed.hostname or "127.0.0.1"
    port = parsed.port or 80
    path = parsed.path or "/stream/sse"
    deadline = time.time() + duration_sec
    ok_count = 0
    total = 0
    latencies: list[float] = []
    lock = threading.Lock()

    def worker() -> None:
        nonlocal ok_count, total
        while time.time() < deadline:
            ok, elapsed = _sse_once(host, port, path, events_min=events_min, timeout=float(duration_sec + 5))
            with lock:
                total += 1
                if ok:
                    ok_count += 1
                    latencies.append(elapsed)

    threads = [threading.Thread(target=worker, daemon=True) for _ in range(max(1, concurrent))]
    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=duration_sec + 10)
    elapsed = max(duration_sec, 1)
    eps = ok_count / elapsed
    metrics: dict[str, float] = {"rps": eps, "stream_ok_ratio": ok_count / max(total, 1)}
    if latencies:
        metrics["p99_latency_ms"] = float(max(latencies) * 1000.0)
    return metrics


def _ws_handshake(host: str, port: int, path: str, *, frames_min: int, timeout: float) -> tuple[bool, float]:
    key = base64.b64encode(os.urandom(16)).decode()
    accept_expected = base64.b64encode(hashlib.sha1(key.encode() + MAGIC).digest()).decode()
    req = (
        f"GET {path} HTTP/1.1\r\n"
        f"Host: {host}:{port}\r\n"
        "Upgrade: websocket\r\n"
        "Connection: Upgrade\r\n"
        f"Sec-WebSocket-Key: {key}\r\n"
        "Sec-WebSocket-Version: 13\r\n"
        "\r\n"
    ).encode()
    t0 = time.perf_counter()
    try:
        conn = socket.create_connection((host, port), timeout=timeout)
    except OSError:
        return False, time.perf_counter() - t0
    try:
        conn.sendall(req)
        data = b""
        while b"\r\n\r\n" not in data:
            chunk = conn.recv(4096)
            if not chunk:
                break
            data += chunk
        if b"101" not in data.split(b"\r\n", 1)[0]:
            return False, time.perf_counter() - t0
        m = re.search(br"Sec-WebSocket-Accept:\s*(\S+)", data, re.I)
        if not m or m.group(1).decode() != accept_expected:
            return False, time.perf_counter() - t0
        frames = 0
        conn.settimeout(timeout)
        while frames < frames_min:
            chunk = conn.recv(4096)
            if not chunk:
                break
            frames += chunk.count(b"tick")
        ok = frames >= frames_min
        return ok, time.perf_counter() - t0
    except OSError:
        return False, time.perf_counter() - t0
    finally:
        conn.close()


def run_ws_fanout(
    url: str,
    *,
    concurrent: int,
    messages_min: int,
    duration_sec: int,
) -> dict[str, float]:
    parsed = urlparse(url)
    host = parsed.hostname or "127.0.0.1"
    port = parsed.port or 80
    path = parsed.path or "/stream/ws"
    deadline = time.time() + duration_sec
    ok_count = 0
    total = 0
    latencies: list[float] = []
    lock = threading.Lock()

    def worker() -> None:
        nonlocal ok_count, total
        while time.time() < deadline:
            ok, elapsed = _ws_handshake(
                host, port, path, frames_min=messages_min, timeout=float(duration_sec + 5)
            )
            with lock:
                total += 1
                if ok:
                    ok_count += 1
                    latencies.append(elapsed)

    threads = [threading.Thread(target=worker, daemon=True) for _ in range(max(1, concurrent))]
    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=duration_sec + 10)
    elapsed = max(duration_sec, 1)
    metrics: dict[str, float] = {
        "rps": ok_count / elapsed,
        "stream_ok_ratio": ok_count / max(total, 1),
    }
    if latencies:
        metrics["p99_latency_ms"] = float(max(latencies) * 1000.0)
    return metrics


def run_streaming_soak_load(cfg: dict[str, Any], *, port: int) -> dict[str, float]:
    load = cfg.get("load") or {}
    kind = str(load.get("kind", "sse"))
    concurrent = int(load.get("concurrent", 16))
    duration = int(load.get("duration_sec", 8))
    verify = cfg.get("verify") or {}
    reqs = verify.get("requests") or []
    path = "/stream/sse"
    if isinstance(reqs, list) and reqs and isinstance(reqs[0], dict):
        path = str(reqs[0].get("path", path))
    url = f"http://127.0.0.1:{port}{path}"
    if kind == "ws":
        messages_min = int(load.get("messages_min", 1))
        return run_ws_fanout(url, concurrent=concurrent, messages_min=messages_min, duration_sec=duration)
    events_min = int(load.get("events_min", 20))
    return run_sse_soak(url, concurrent=concurrent, events_min=events_min, duration_sec=duration)
