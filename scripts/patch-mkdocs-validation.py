#!/usr/bin/env python3
"""Ensure lic-docs mkdocs.yml ignores anchor drift during --strict (lic#403)."""
from __future__ import annotations

import sys
from pathlib import Path

BLOCK = """
validation:
  nav:
    omitted_files: info
  links:
    not_found: warn
    absolute_links: info
    anchors: ignore
    unrecognized_links: info

exclude_docs: |
  README.md
"""


def main() -> None:
    path = Path(sys.argv[1])
    text = path.read_text(encoding="utf-8")
    if "exclude_docs:" in text and "validation:" in text:
        print(f"patch-mkdocs-validation: already patched {path}")
        return
    if "validation:" in text and "exclude_docs:" not in text:
        text = text.replace(
            "unrecognized_links: info\n",
            "unrecognized_links: info\n\nexclude_docs: |\n  README.md\n",
            1,
        )
        path.write_text(text, encoding="utf-8")
        print(f"patch-mkdocs-validation: added exclude_docs to {path}")
        return
    if "markdown_extensions:" in text:
        text = text.replace("markdown_extensions:", BLOCK + "\nmarkdown_extensions:", 1)
    else:
        text = text.rstrip() + "\n" + BLOCK + "\n"
    path.write_text(text, encoding="utf-8")
    print(f"patch-mkdocs-validation: patched {path}")


if __name__ == "__main__":
    main()
