#!/usr/bin/env python3
"""li-httpd [limits] — nginx-style byte sizes and proxy caps (TOML → runtime.conf)."""

from __future__ import annotations

import re
from typing import Any

try:
    from httpd_config import ConfigError
except ImportError:  # pragma: no cover

    class ConfigError(Exception):
        pass


BYTE_SIZE_RE = re.compile(r"^(\d+)([kmg])?$", re.IGNORECASE)

# Sensible defaults (nginx-aligned where a directive exists).
DEFAULT_MAX_BODY = "1m"  # client_max_body_size
DEFAULT_MAX_HEADER = "16k"  # large_client_header_buffers (single-block cap)
DEFAULT_PROXY_MAX_RESPONSE_BODY = "64m"  # streamed proxy egress (no nginx default)

MAX_BODY_CAP = 512 * 1024 * 1024
MAX_HEADER_CAP = 256 * 1024
MAX_PROXY_RESPONSE_CAP = 512 * 1024 * 1024


def parse_byte_size(
    raw: object,
    field: str,
    *,
    default: str | None = None,
    cap: int | None = None,
) -> int:
    """Parse nginx-style sizes: 4096, 8k, 1m, 2g (case-insensitive suffix)."""
    if raw is None:
        if default is None:
            raise ConfigError(f"{field} is required")
        raw = default
    s = str(raw).strip().lower().replace(" ", "")
    if not s:
        raise ConfigError(f"{field} must not be empty")
    m = BYTE_SIZE_RE.match(s)
    if not m:
        raise ConfigError(
            f"{field} must be a byte size like 1m, 64k, or 4096 (got {raw!r})"
        )
    n = int(m.group(1))
    suffix = (m.group(2) or "").lower()
    if suffix == "k":
        n *= 1024
    elif suffix == "m":
        n *= 1024 * 1024
    elif suffix == "g":
        n *= 1024 * 1024 * 1024
    if n < 1:
        raise ConfigError(f"{field} must be positive")
    if cap is not None and n > cap:
        raise ConfigError(f"{field} must be <= {cap} bytes (got {n})")
    return n


def limits_from_toml(data: dict[str, Any]) -> dict[str, int]:
    limits = data.get("limits") or {}
    if not isinstance(limits, dict):
        raise ConfigError("[limits] must be a table")
    return {
        "max_request_body_bytes": parse_byte_size(
            limits.get("max_body"),
            "limits.max_body",
            default=DEFAULT_MAX_BODY,
            cap=MAX_BODY_CAP,
        ),
        "max_header_bytes": parse_byte_size(
            limits.get("max_header"),
            "limits.max_header",
            default=DEFAULT_MAX_HEADER,
            cap=MAX_HEADER_CAP,
        ),
        "max_proxy_response_body_bytes": parse_byte_size(
            limits.get("proxy_max_response_body"),
            "limits.proxy_max_response_body",
            default=DEFAULT_PROXY_MAX_RESPONSE_BODY,
            cap=MAX_PROXY_RESPONSE_CAP,
        ),
    }


def limits_flatten_lines(data: dict[str, Any]) -> list[str]:
    """Emit runtime.conf limit keys; missing [limits] uses defaults."""
    parsed = limits_from_toml(data)
    return [f"{key}={value}" for key, value in parsed.items()]


def validate_limits(data: dict[str, Any]) -> None:
    """Validate [limits] when present; always resolves defaults for flatten."""
    limits_from_toml(data)
