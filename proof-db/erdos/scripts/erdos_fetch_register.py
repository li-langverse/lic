#!/usr/bin/env python3
"""Fetch erdosproblems.com problem pages into proof-db/erdos/register.json (WP1 bulk ingest).

Preserves existing register rows by default; only adds missing problem numbers unless --refresh.
"""
from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from html import unescape
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[3]
REGISTER = ROOT / "proof-db" / "erdos" / "register.json"
USER_AGENT = "Mozilla/5.0 (compatible; LiProofExplorer/1.0; +https://github.com/li-langverse/lic)"
BASE_URL = "https://www.erdosproblems.com"


def normalize_tag(raw: str) -> str:
    s = unicodedata.normalize("NFKD", raw.strip().lower())
    s = s.encode("ascii", "ignore").decode("ascii")
    s = re.sub(r"[^a-z0-9]+", "_", s).strip("_")
    if not s:
        s = "general"
    if not re.match(r"^[a-z]", s):
        s = f"t_{s}"
    return s


def fetch_html(number: int, timeout: float = 30.0) -> str | None:
    url = f"{BASE_URL}/{number}"
    try:
        proc = subprocess.run(
            [
                "curl",
                "-sL",
                "-A",
                USER_AGENT,
                "--fail",
                "--max-time",
                str(int(timeout)),
                url,
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    except FileNotFoundError:
        raise SystemExit("curl required for erdos_fetch_register.py")
    if proc.returncode != 0:
        return None
    return proc.stdout


def strip_html(fragment: str) -> str:
    text = re.sub(r"<script[^>]*>.*?</script>", " ", fragment, flags=re.S | re.I)
    text = re.sub(r"<style[^>]*>.*?</style>", " ", text, flags=re.S | re.I)
    text = re.sub(r"<[^>]+>", " ", text)
    text = unescape(text)
    text = text.replace("\xa0", " ")
    return re.sub(r"\s+", " ", text).strip()


def parse_row(html: str, number: int) -> dict[str, Any] | None:
    if "404 Not Found" in html[:500]:
        return None

    content_m = re.search(
        r'<div id="content"[^>]*>(.*?)</div>\s*<div id="problem_id"',
        html,
        flags=re.S | re.I,
    )
    if not content_m:
        return None
    statement = strip_html(content_m.group(1))
    if len(statement) < 8:
        return None

    box_m = re.search(r'<div class="problem-box"[^>]*>(.*?)</div>\s*<div class="problem-status', html, re.S)
    box = box_m.group(1) if box_m else html
    erdos_status = "open"
    if re.search(r'\bid="solved"\b', box) or re.search(r"\bPROVED\b", box):
        erdos_status = "proved"
    elif re.search(r'\bid="open"\b', box) or re.search(r"\bOPEN\b", box):
        erdos_status = "open"

    tags: list[str] = []
    tags_m = re.search(r'<div id="tags"[^>]*>(.*?)</div>', html, flags=re.S | re.I)
    if tags_m:
        for href, label in re.findall(r'href="(/tags/[^"]+)"[^>]*>([^<]+)</a>', tags_m.group(1)):
            tags.append(normalize_tag(label))
    if not tags:
        tags = ["general"]

    return {
        "number": number,
        "statement": statement,
        "tags": sorted(set(tags)),
        "priority_tier": "P2",
        "erdos_status": erdos_status,
        "external_url": f"{BASE_URL}/{number}",
    }


def load_register(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def save_register(path: Path, data: dict[str, Any]) -> None:
    data["problems"] = sorted(data["problems"], key=lambda r: int(r["number"]))
    path.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def fetch_one(number: int, delay: float) -> tuple[int, dict[str, Any] | None]:
    if delay > 0:
        time.sleep(delay)
    html = fetch_html(number)
    if html is None:
        return number, None
    return number, parse_row(html, number)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--register", type=Path, default=REGISTER)
    ap.add_argument("--from", dest="from_num", type=int, default=1)
    ap.add_argument("--to", dest="to_num", type=int, default=1217)
    ap.add_argument("--workers", type=int, default=4, help="parallel fetch workers")
    ap.add_argument("--delay", type=float, default=0.05, help="seconds between requests per worker")
    ap.add_argument("--skip-existing", action="store_true", help="do not overwrite existing numbers")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    data = load_register(args.register)
    by_num = {int(r["number"]): r for r in data.get("problems", [])}

    todo = [
        n
        for n in range(args.from_num, args.to_num + 1)
        if not (args.skip_existing and n in by_num)
    ]
    if not todo:
        print("nothing to fetch")
        return 0

    print(f"fetching {len(todo)} problems ({args.from_num}..{args.to_num})")
    added = 0
    failed: list[int] = []

    with ThreadPoolExecutor(max_workers=max(1, args.workers)) as pool:
        futures = {pool.submit(fetch_one, n, args.delay): n for n in todo}
        for fut in as_completed(futures):
            num, row = fut.result()
            if row is None:
                failed.append(num)
                continue
            if args.skip_existing and num in by_num:
                continue
            by_num[num] = row
            added += 1
            if added % 50 == 0:
                print(f"  ... {added} rows ingested (latest #{num})")

    data["problems"] = list(by_num.values())
    data["updated"] = time.strftime("%Y-%m-%d")
    data["source"] = (
        f"Bulk ingest from erdosproblems.com via erdos_fetch_register.py "
        f"({args.from_num}-{args.to_num}); curated rows preserved"
    )

    print(f"added/updated {added} rows; total {len(data['problems'])}; missing pages {len(failed)}")
    if args.dry_run:
        return 0

    save_register(args.register, data)
    print(f"wrote {args.register.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
