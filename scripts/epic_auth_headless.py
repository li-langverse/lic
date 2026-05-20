#!/usr/bin/env python3
"""Capture Epic authorization code via headless browser (requires EPIC_EMAIL + EPIC_PASSWORD)."""
from __future__ import annotations

import os
import re
import sys
import urllib.parse

def main() -> int:
    email = os.environ.get("EPIC_EMAIL", "").strip()
    password = os.environ.get("EPIC_PASSWORD", "").strip()
    if not email or not password:
        print(
            "Set EPIC_EMAIL and EPIC_PASSWORD (Epic Games account) then re-run install-ue-linux.sh",
            file=sys.stderr,
        )
        return 2

    from legendary.api.egs import EPCAPI

    auth_url = EPCAPI().get_auth_url()
    code_holder: list[str] = []

    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("pip install playwright && playwright install chromium", file=sys.stderr)
        return 1

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        page.goto(auth_url, wait_until="networkidle", timeout=120_000)
        # Epic login form (selectors may change)
        page.fill('input[name="email"], input#email', email, timeout=60_000)
        page.fill('input[name="password"], input#password', password, timeout=60_000)
        page.click('button[type="submit"], #sign-in', timeout=30_000)
        page.wait_for_timeout(8000)
        url = page.url
        if "code=" in url:
            parsed = urllib.parse.urlparse(url)
            qs = urllib.parse.parse_qs(parsed.query)
            if "code" in qs:
                code_holder.append(qs["code"][0])
        if not code_holder:
            content = page.content()
            m = re.search(r"code=([A-Za-z0-9._-]+)", content)
            if m:
                code_holder.append(m.group(1))
        browser.close()

    if not code_holder:
        print("Login did not yield authorization code (captcha/2FA?). Use manual EPIC_AUTH_CODE.", file=sys.stderr)
        return 3

    print(code_holder[0])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
