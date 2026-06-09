#!/usr/bin/env python3
"""Unit tests for scripts/httpd_toml_style.py."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))

from httpd_toml_style import (  # noqa: E402
    find_camelcase_keys,
    validate_toml_key_style,
)


class TomlStyleTests(unittest.TestCase):
    def test_snake_case_ok(self) -> None:
        cfg = {
            "limits": {"max_body": "1m", "proxy_max_response_body": "64m"},
            "server": {"listen_http": ":80"},
        }
        self.assertEqual(find_camelcase_keys(cfg), [])
        self.assertEqual(validate_toml_key_style(cfg), [])

    def test_camelcase_rejected(self) -> None:
        cfg = {"limits": {"maxBody": "1m"}}
        self.assertEqual(find_camelcase_keys(cfg), ["limits.maxBody"])
        errs = validate_toml_key_style(cfg)
        self.assertEqual(len(errs), 1)
        self.assertIn("max_body", errs[0])
        self.assertIn("camelCase", errs[0])


if __name__ == "__main__":
    unittest.main()
