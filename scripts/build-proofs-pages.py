#!/usr/bin/env python3
"""Build static proof-db status site for GitHub Pages (proofs.lilangverse.xyz)."""
from __future__ import annotations

import html
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE = ROOT / "site-proofs"
INDEX = ROOT / "proof-db" / "index.json"
BASELINE = ROOT / "proof-db" / "baseline.json"
REPORT = ROOT / "data" / "proof-db" / "latest-report.md"
GAPS = ROOT / "docs" / "verification" / "provability-gaps.md"


def esc(s: object) -> str:
    return html.escape("" if s is None else str(s))


def load_json(path: Path) -> dict:
    if not path.is_file():
        return {}
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    idx = load_json(INDEX)
    base = load_json(BASELINE)
    entries = idx.get("entries") or []
    records = {r.get("id"): r for r in base.get("records") or [] if isinstance(r, dict)}

    rows = []
    for e in entries:
        if not isinstance(e, dict):
            continue
        eid = e.get("id", "")
        rows.append(
            "<tr>"
            f"<td><code>{esc(eid)}</code></td>"
            f"<td>{esc(e.get('status'))}</td>"
            f"<td>{esc(e.get('textbook', ''))}</td>"
            f"<td>{esc(e.get('gap') or '')}</td>"
            f"<td><code>{esc(e.get('lean_theorem') or '')}</code></td>"
            "</tr>"
        )

    report_md = REPORT.read_text(encoding="utf-8") if REPORT.is_file() else "_No rebuild report in repo._"
    report_block = f"<pre>{esc(report_md)}</pre>"

    gaps_link = "https://docs.lilangverse.xyz/verification/provability-gaps/"
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")

    body = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Li proof database</title>
  <style>
    :root {{ font-family: system-ui, sans-serif; line-height: 1.5; }}
    body {{ max-width: 960px; margin: 2rem auto; padding: 0 1rem; }}
    table {{ border-collapse: collapse; width: 100%; font-size: 0.92rem; }}
    th, td {{ border: 1px solid #ccc; padding: 0.35rem 0.5rem; text-align: left; vertical-align: top; }}
    th {{ background: #f4f4f4; }}
    nav a {{ margin-right: 1rem; }}
    pre {{ white-space: pre-wrap; background: #f8f8f8; padding: 1rem; overflow-x: auto; }}
  </style>
</head>
<body>
  <nav>
    <a href="https://docs.lilangverse.xyz/">Docs</a>
    <a href="https://benchmarks.lilangverse.xyz/">Benchmarks</a>
    <a href="https://progress.lilangverse.xyz/">Progress</a>
    <a href="https://github.com/li-langverse/lic/tree/main/proof-db">proof-db (source)</a>
    <a href="{esc(gaps_link)}">Provability gaps</a>
  </nav>
  <h1>Li proof database</h1>
  <p>Snapshot from <code>proof-db/index.json</code> and baseline pin. Generated {esc(now)}.</p>
  <p>Pin: <strong>{esc(base.get('release_pin', '—'))}</strong> ·
     proved {esc(base.get('proved_count', '?'))} / {esc(base.get('total_count', '?'))} baseline records ·
     {len(entries)} catalog entries</p>
  <h2>Catalog entries</h2>
  <table>
    <thead><tr><th>ID</th><th>Status</th><th>Statement</th><th>Gap</th><th>Lean</th></tr></thead>
    <tbody>
      {''.join(rows) if rows else '<tr><td colspan="5">No entries found.</td></tr>'}
    </tbody>
  </table>
  <h2>Latest rebuild report</h2>
  {report_block}
</body>
</html>
"""

    SITE.mkdir(parents=True, exist_ok=True)
    (SITE / "index.html").write_text(body, encoding="utf-8")
    (SITE / "CNAME").write_text("proofs.lilangverse.xyz\n", encoding="utf-8")
    print(f"proofs site: wrote {SITE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
