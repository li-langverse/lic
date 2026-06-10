#!/usr/bin/env python3
"""Fail if built MkDocs HTML contains relative hrefs ending in .md (GitHub Pages 404s)."""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

SKIP_PREFIXES = ("http://", "https://", "mailto:", "#", "javascript:")


def scan_site(site_dir: Path) -> list[tuple[str, str]]:
    pairs: list[tuple[str, str]] = []
    for html in sorted(site_dir.rglob("*.html")):
        text = html.read_text(encoding="utf-8", errors="ignore")
        page = str(html.relative_to(site_dir))
        for match in re.finditer(r'href=["\']([^"\']+)["\']', text):
            href = match.group(1).strip()
            if href.startswith(SKIP_PREFIXES):
                continue
            path = href.split("#")[0].split("?")[0]
            if ".md" in path:
                pairs.append((page, href))
    return pairs


def find_docs_root(repo_root: Path) -> Path | None:
    for candidate in (
        repo_root.parent / "lic-docs",
        repo_root.parent.parent / "lic-docs",
    ):
        if (candidate / "mkdocs.yml").is_file():
            return candidate.resolve()
    env = __import__("os").environ.get("LI_DOCS_ROOT")
    if env:
        p = Path(env)
        if (p / "mkdocs.yml").is_file():
            return p.resolve()
    return None


def build_site(repo_root: Path, docs_root: Path, site_dir: Path) -> None:
    venv = docs_root / ".venv-docs"
    if not venv.is_dir():
        subprocess.run(
            [sys.executable, "-m", "venv", str(venv)],
            check=True,
        )
    pip = venv / "bin" / "pip"
    mkdocs = venv / "bin" / "mkdocs"
    subprocess.run(
        [str(pip), "install", "-q", "-r", str(docs_root / "docs" / "requirements.txt")],
        check=True,
    )
    staging = site_dir.parent / "docs-staging"
    if staging.exists():
        import shutil

        shutil.rmtree(staging)
    import shutil

    shutil.copytree(repo_root / "docs", staging)
    subprocess.run(
        [
            str(mkdocs),
            "build",
            "-f",
            str(docs_root / "mkdocs.yml"),
            "-d",
            str(site_dir),
        ],
        check=True,
        cwd=str(docs_root),
        env={**__import__("os").environ, "DOCS_DIR": str(staging)},
    )
    # mkdocs uses docs/ relative to config dir — swap via symlink
    docs_link = docs_root / "docs"
    backup = docs_root / ".docs-check-backup"
    if backup.exists():
        import shutil

        shutil.rmtree(backup)
    if docs_link.is_symlink():
        docs_link.unlink()
    elif docs_link.is_dir():
        docs_link.rename(backup)
    shutil.copytree(staging, docs_link)
    try:
        subprocess.run(
            [str(mkdocs), "build", "-f", str(docs_root / "mkdocs.yml"), "-d", str(site_dir)],
            check=True,
            cwd=str(docs_root),
        )
    finally:
        import shutil

        shutil.rmtree(docs_link)
        if backup.is_dir():
            backup.rename(docs_link)
        shutil.rmtree(staging, ignore_errors=True)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--site",
        type=Path,
        help="Use an existing site/ directory instead of building",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
    )
    args = parser.parse_args()
    repo_root = args.repo_root.resolve()

    if args.site:
        site_dir = args.site.resolve()
    else:
        docs_root = find_docs_root(repo_root)
        if docs_root is None:
            print(
                "check-docs-md-hrefs: clone lic-docs beside lic or set LI_DOCS_ROOT",
                file=sys.stderr,
            )
            return 2
        with tempfile.TemporaryDirectory(prefix="lic-docs-site-") as tmp:
            site_dir = Path(tmp) / "site"
            build_site(repo_root, docs_root, site_dir)
            pairs = scan_site(site_dir)
            if pairs:
                print(f"FAIL: {len(pairs)} relative .md href(s) in built HTML:", file=sys.stderr)
                for page, href in pairs:
                    print(f"  {page} -> {href}", file=sys.stderr)
                return 1
            print(f"OK: 0 relative .md hrefs under {site_dir}")
            return 0

    if not site_dir.is_dir():
        print(f"site directory not found: {site_dir}", file=sys.stderr)
        return 2
    pairs = scan_site(site_dir)
    if pairs:
        print(f"FAIL: {len(pairs)} relative .md href(s) in built HTML:", file=sys.stderr)
        for page, href in pairs:
            print(f"  {page} -> {href}", file=sys.stderr)
        return 1
    print(f"OK: 0 relative .md hrefs under {site_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
