#!/usr/bin/env python3
"""li-httpd TOML key style — snake_case only (no camelCase)."""

from __future__ import annotations

import re
from typing import Any

CAMEL_CASE_KEY_RE = re.compile(r"^[a-z]+[A-Z]")
STYLE_DOC = "docs/toml-style.md"


def _walk_keys(obj: Any, prefix: str = "") -> list[tuple[str, str]]:
    paths: list[tuple[str, str]] = []
    if isinstance(obj, dict):
        for key, val in obj.items():
            path = f"{prefix}.{key}" if prefix else str(key)
            paths.append((path, str(key)))
            paths.extend(_walk_keys(val, path))
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            paths.extend(_walk_keys(item, f"{prefix}[{i}]"))
    return paths


def find_camelcase_keys(cfg: dict[str, Any]) -> list[str]:
    """Return dotted paths of keys that violate snake_case."""
    bad: list[str] = []
    for path, key in _walk_keys(cfg):
        if CAMEL_CASE_KEY_RE.match(key):
            bad.append(path)
    return sorted(bad)


def _camel_to_snake(name: str) -> str:
    out: list[str] = []
    for i, ch in enumerate(name):
        if ch.isupper() and i > 0:
            out.append("_")
        out.append(ch.lower())
    return "".join(out)


def validate_toml_key_style(cfg: dict[str, Any]) -> list[str]:
    """Human-readable errors for camelCase TOML keys."""
    errs: list[str] = []
    for path in find_camelcase_keys(cfg):
        leaf = path.rsplit(".", 1)[-1]
        snake_hint = _camel_to_snake(leaf)
        errs.append(
            f"TOML key {path!r} uses camelCase; use snake_case (e.g. {snake_hint!r}). "
            f"See {STYLE_DOC}"
        )
    return errs
