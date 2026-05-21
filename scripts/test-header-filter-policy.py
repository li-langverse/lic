#!/usr/bin/env python3
"""Unit test for x-internal-* response header stripping policy (mirrors C filter)."""
from __future__ import annotations

import sys


def filter_resp_headers(block: str) -> str:
    out: list[str] = []
    i = 0
    n = len(block)
    while i < n:
        start = i
        while i < n and block[i] != "\n":
            i += 1
        line = block[start:i]
        eff = line.rstrip("\r")
        drop = False
        if eff and not eff.upper().startswith("HTTP/"):
            low = eff.lower()
            if low.startswith("x-internal-"):
                drop = True
        if not drop:
            out.append(line + "\r\n")
        if i < n and block[i] == "\n":
            i += 1
    return "".join(out)


def main() -> int:
    sample = (
        "HTTP/1.1 200 OK\r\n"
        "Content-Type: text/plain\r\n"
        "X-Internal-Secret: leak\r\n"
        "X-Request-Id: ok\r\n"
        "\r\n"
    )
    filtered = filter_resp_headers(sample)
    if "x-internal" in filtered.lower():
        print("FAIL: x-internal present after filter", file=sys.stderr)
        return 1
    if "x-request-id" not in filtered.lower():
        print("FAIL: expected passthrough header", file=sys.stderr)
        return 1
    if "200 OK" not in filtered:
        print("FAIL: status line missing", file=sys.stderr)
        return 1
    print("test-header-filter-policy: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
