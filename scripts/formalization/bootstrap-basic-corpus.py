#!/usr/bin/env python3
"""Bootstrap phase-8 basic corpus: manifests, catalog rows, and .li specimen stubs."""
from __future__ import annotations

import argparse
import re
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST_ROOT = ROOT / "docs/verification/basic-corpus"
ENTRIES_ROOT = ROOT / "docs/verification/proof-database/entries"
PHASE8_NOTE = "phase8-basic-corpus"

FIELD_CONFIG = {
    "physics": {
        "catalog_file": "physics-basic-corpus.toml",
        "specimen_dir": "proof-db/physics/basic-corpus",
        "lean_module": "docs/semantics/Discharge.lean",
        "gap_id": "G-physics",
    },
    "statistics": {
        "catalog_file": "statistics-basic-corpus.toml",
        "specimen_dir": "proof-db/statistics/basic-corpus",
        "lean_module": "proof-db/statistics/StatsAxioms.lean",
        "gap_id": "G-stats",
    },
    "discrete": {
        "catalog_file": "discrete-basic-corpus.toml",
        "specimen_dir": "proof-db/discrete/basic-corpus",
        "lean_module": "proof-db/discrete/axioms/DiscreteAxioms.lean",
        "gap_id": "G-discrete",
    },
    "graph": {
        "catalog_file": "graph-basic-corpus.toml",
        "specimen_dir": "proof-db/graph/basic-corpus",
        "lean_module": "proof-db/graph/GraphAxioms.lean",
        "gap_id": "G-graph",
    },
    "chemistry": {
        "catalog_file": "chemistry-basic-corpus.toml",
        "specimen_dir": "proof-db/chemistry/basic-corpus",
        "lean_module": "proof-db/chemistry/ChemAxioms.lean",
        "gap_id": "G-chemistry",
    },
}


@dataclass(frozen=True)
class PlannedEntry:
    id: str
    kind: str
    field: str
    statement: str
    proof_status: str
    tranche: int
    latex: str | None = None
    domain: str | None = None


def slug_from_id(entry_id: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", entry_id.lower()).strip("_")


def specimen_body(entry: PlannedEntry) -> str:
    lines = [
        f"# {entry.id}: {entry.statement}",
        "",
    ]
    if entry.kind == "axiom":
        safe = slug_from_id(entry.id)
        lines.extend(
            [
                f"def proof_db_{safe}() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "=",
                "  return 0",
                "",
            ]
        )
    lines.extend(
        [
            "def main() -> int",
            "  requires true",
            "  ensures result == 0",
            "  decreases 0",
            "=",
            "  return 0",
            "",
        ]
    )
    return "\n".join(lines)


def load_plan() -> list[PlannedEntry]:
    """Return full ~250-entry plan (imported from generated tables)."""
    plan_dir = Path(__file__).resolve().parent
    if str(plan_dir) not in sys.path:
        sys.path.insert(0, str(plan_dir))
    from bootstrap_basic_corpus_plan import PLAN  # noqa: PLC0415

    return [PlannedEntry(**row) for row in PLAN]


def write_field_manifest(field: str, rows: list[PlannedEntry], commit: str) -> Path:
    MANIFEST_ROOT.mkdir(parents=True, exist_ok=True)
    fname = "stats-basic.toml" if field == "statistics" else f"{field}-basic.toml"
    out = MANIFEST_ROOT / fname
    chunks: list[str] = [
        f'# Phase-8 basic corpus plan — field "{field}"',
        f"version = 1",
        f"field = {toml_quote(field)}",
        f"target_count = {len(rows)}",
        f"last_verified_lic_commit = {toml_quote(commit)}",
        "",
    ]
    for row in rows:
        chunks.append("[[planned]]")
        chunks.append(f"id = {toml_quote(row.id)}")
        chunks.append(f"kind = {toml_quote(row.kind)}")
        chunks.append(f"tranche = {row.tranche}")
        chunks.append(f"proof_status = {toml_quote(row.proof_status)}")
        if row.domain:
            chunks.append(f"domain = {toml_quote(row.domain)}")
        chunks.append(f"statement = {toml_quote(row.statement)}")
        if row.latex:
            chunks.append(f"latex = {toml_quote(row.latex)}")
        chunks.append("")
    out.write_text("\n".join(chunks), encoding="utf-8")
    return out


def toml_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def format_catalog_entry(row: PlannedEntry, cfg: dict[str, str], commit: str, specimen_rel: str) -> str:
    lines = [
        "[[entry]]",
        f"id = {toml_quote(row.id)}",
        f"kind = {toml_quote(row.kind)}",
        f'field = {toml_quote(row.field)}',
    ]
    if row.domain:
        lines.append(f"domain = {toml_quote(row.domain)}")
    lines.append(f"statement = {toml_quote(row.statement)}")
    if row.latex:
        lines.append(f"latex = {toml_quote(row.latex)}")
    lines.append(f"proof_status = {toml_quote(row.proof_status)}")
    lines.append('gap_kind = "axiom_layer"')
    lines.append(f'gap_id = {toml_quote(cfg["gap_id"])}')
    lines.append(f"lean_module = {toml_quote(cfg['lean_module'])}")
    lines.append(f"li_specimen = {toml_quote(specimen_rel)}")
    lines.append('content_tier = "raw"')
    lines.append(f"notes = {toml_quote(f'{PHASE8_NOTE} tranche={row.tranche}')}")
    lines.append(f"last_verified_lic_commit = {toml_quote(commit)}")
    lines.append("")
    return "\n".join(lines)


def existing_catalog_ids() -> set[str]:
    ids: set[str] = set()
    for path in ENTRIES_ROOT.glob("*.toml"):
        text = path.read_text(encoding="utf-8")
        for m in re.finditer(r'^id\s*=\s*"([^"]+)"', text, re.M):
            ids.add(m.group(1))
    return ids


def cmd_write_manifests(commit: str) -> None:
    by_field: dict[str, list[PlannedEntry]] = {}
    for row in load_plan():
        by_field.setdefault(row.field, []).append(row)
    for field, rows in sorted(by_field.items()):
        path = write_field_manifest(field, rows, commit)
        print(f"wrote {path.relative_to(ROOT)} ({len(rows)} planned)")


def cmd_bootstrap(tranche: int | None, limit: int | None, commit: str, dry_run: bool) -> int:
    known = existing_catalog_ids()
    created = 0
    per_field: dict[str, int] = {}

    pending_all = [
        r
        for r in load_plan()
        if r.id not in known and (tranche is None or r.tranche <= tranche)
    ]
    pending_all.sort(key=lambda r: (r.field, r.tranche, r.id))

    for row in pending_all:
        if limit is not None and created >= limit:
            break
        cfg = FIELD_CONFIG[row.field]
        catalog_path = ENTRIES_ROOT / cfg["catalog_file"]
        specimen_rel = f"{cfg['specimen_dir']}/{slug_from_id(row.id)}.li"
        specimen_path = ROOT / specimen_rel
        if not dry_run:
            specimen_path.parent.mkdir(parents=True, exist_ok=True)
            if not specimen_path.is_file():
                specimen_path.write_text(specimen_body(row), encoding="utf-8")
            block = format_catalog_entry(row, cfg, commit, specimen_rel)
            if not catalog_path.is_file():
                catalog_path.write_text("version = 1\n\n" + block, encoding="utf-8")
            else:
                with catalog_path.open("a", encoding="utf-8") as fh:
                    fh.write(block)
        known.add(row.id)
        created += 1
        per_field[row.field] = per_field.get(row.field, 0) + 1

    print(f"bootstrap: created {created} entries")
    for field, n in sorted(per_field.items()):
        print(f"  {field}: {n}")
    return created


def patch_manifest_toml() -> None:
    manifest = ROOT / "proof-db/manifest.toml"
    text = manifest.read_text(encoding="utf-8")
    additions = [
        ('physics', "physics-basic-corpus.toml"),
        ("statistics", "statistics-basic-corpus.toml"),
        ("discrete", "discrete-basic-corpus.toml"),
        ("graph", "graph-basic-corpus.toml"),
        ("chemistry", "chemistry-basic-corpus.toml"),
    ]
    for field, entry_file in additions:
        needle = f'field = "{field}"'
        if entry_file in text:
            continue
        idx = text.find(needle)
        if idx < 0:
            block = (
                f'\n[[catalog_slices]]\nfield = "{field}"\n'
                f'entries = ["{entry_file}"]\n'
            )
            text += block
            continue
        # append to existing entries = [...] list
        slice_start = text.rfind("[[catalog_slices]]", 0, idx)
        slice_end = text.find("[[catalog_slices]]", idx + 1)
        if slice_end < 0:
            slice_end = len(text)
        segment = text[slice_start:slice_end]
        if entry_file in segment:
            continue
        segment_new = re.sub(
            r'(entries\s*=\s*\[)([^\]]*)(\])',
            lambda m: f'{m.group(1)}{m.group(2)}, "{entry_file}"{m.group(3)}'
            if m.group(2).strip()
            else f'{m.group(1)}"{entry_file}"{m.group(3)}',
            segment,
            count=1,
        )
        text = text[:slice_start] + segment_new + text[slice_end:]
    manifest.write_text(text, encoding="utf-8")
    print(f"patched {manifest.relative_to(ROOT)}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "command",
        choices=["write-manifests", "bootstrap", "patch-manifest", "all"],
    )
    parser.add_argument("--tranche", type=int, default=1)
    parser.add_argument("--limit", type=int, default=50)
    parser.add_argument("--commit", default="")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    commit = args.commit.strip()
    if not commit:
        import subprocess

        commit = (
            subprocess.check_output(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, text=True)
            .strip()
        )

    if args.command in ("write-manifests", "all"):
        cmd_write_manifests(commit)
    if args.command in ("bootstrap", "all"):
        n = cmd_bootstrap(args.tranche, args.limit, commit, args.dry_run)
        if n == 0:
            print("bootstrap: nothing to add", file=sys.stderr)
    if args.command in ("patch-manifest", "all") and not args.dry_run:
        patch_manifest_toml()


if __name__ == "__main__":
    main()
