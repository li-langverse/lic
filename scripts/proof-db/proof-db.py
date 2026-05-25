#!/usr/bin/env python3
"""Proof database CLI — list, add-entry, verify-slice."""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from pathlib import Path
from typing import Any, Iterator

try:
    import tomllib
except ImportError:  # pragma: no cover
    import tomli as tomllib  # type: ignore

ROOT = Path(__file__).resolve().parents[2]
SCHEMA_PATH = ROOT / "docs/verification/proof-database/schema.toml"
PROOF_STATUS = frozenset({"proved", "open", "discrepancy", "axiomatic"})
KINDS = frozenset({"axiom", "lemma"})


def _load_schema() -> dict[str, Any]:
    return tomllib.loads(SCHEMA_PATH.read_text(encoding="utf-8"))


def _schema_paths(schema: dict[str, Any]) -> list[Path]:
    s = schema.get("schema", {})
    return [ROOT / s[k] for k in ("entries_root", "corpus_root") if s.get(k)]


def _iter_toml_files(roots: list[Path]) -> Iterator[Path]:
    for root in roots:
        if root.is_dir():
            yield from sorted(root.rglob("*.toml"))


def _parse_rows(path: Path) -> list[dict[str, Any]]:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    if "entry" in data:
        return [e for e in data["entry"] if isinstance(e, dict)]
    if data.get("id") and data.get("kind"):
        return [data]
    return []


def _all_entries(schema: dict[str, Any]) -> list[tuple[Path, dict[str, Any]]]:
    out: list[tuple[Path, dict[str, Any]]] = []
    for path in _iter_toml_files(_schema_paths(schema)):
        if path.name == "schema.toml":
            continue
        for row in _parse_rows(path):
            out.append((path, row))
    return out


def _git_head() -> str:
    try:
        r = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=True,
        )
        return r.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return "unknown"


def _required(schema: dict[str, Any], kind: str) -> list[str]:
    return list(schema.get("entry_types", {}).get(kind, {}).get("required", []))


def validate_entries(schema: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    for path, row in _all_entries(schema):
        kind = row.get("kind")
        eid = row.get("id", "?")
        label = f"{path.relative_to(ROOT)}[{eid}]"
        if kind not in KINDS:
            errors.append(f"{label}: invalid kind {kind!r}")
            continue
        for key in _required(schema, kind):
            if key not in row or row[key] in (None, ""):
                errors.append(f"{label}: missing {key}")
        if row.get("proof_status") not in PROOF_STATUS:
            errors.append(f"{label}: bad proof_status")
        if not re.match(r"^[A-Za-z0-9][A-Za-z0-9._-]*$", str(eid)):
            errors.append(f"{label}: bad id")
    return errors


def cmd_list(args: argparse.Namespace) -> int:
    schema = _load_schema()
    rows = [
        (p, r)
        for p, r in _all_entries(schema)
        if (not args.gap or r.get("gap_id") == args.gap)
        and (not args.status or r.get("proof_status") == args.status)
        and (not args.field or r.get("field") == args.field)
        and (not args.kind or r.get("kind") == args.kind)
    ]
    if not rows:
        print("proof-db: no entries match filters")
        return 0
    for p, r in rows:
        print(
            f"{r.get('id','?'):36} {r.get('proof_status','?'):12} "
            f"{r.get('field','?'):10} {r.get('gap_id','-'):10} {p.relative_to(ROOT)}"
        )
    print(f"\n{len(rows)} entries")
    return 0


def cmd_add_entry(args: argparse.Namespace) -> int:
    schema = _load_schema()
    dest = _schema_paths(schema)[0] / (
        "axioms" if args.kind == "axiom" else "lemmas"
    ) / f"{args.id}.toml"
    if dest.exists() and not args.force:
        print(f"error: {dest} exists", file=sys.stderr)
        return 1
    dest.parent.mkdir(parents=True, exist_ok=True)
    commit = args.last_verified or _git_head()
    lines = [
        f'id = "{args.id}"',
        f'kind = "{args.kind}"',
        f'field = "{args.field}"',
        f'proof_status = "{args.status}"',
        f'statement = """{args.statement}"""',
        f'lean_module = "{args.lean_module}"',
        f'last_verified_lic_commit = "{commit}"',
    ]
    for k, v in [
        ("gap_id", args.gap_id),
        ("backlog_id", args.backlog_id),
        ("li_specimen", args.li_specimen),
        ("lean_thm", args.lean_thm),
    ]:
        if v:
            lines.append(f'{k} = "{v}"')
    if args.evidence:
        lines.append("evidence = [" + ", ".join(f'"{e}"' for e in args.evidence) + "]")
    dest.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"wrote {dest.relative_to(ROOT)}")
    return 0


def cmd_verify_slice(args: argparse.Namespace) -> int:
    schema = _load_schema()
    errors = validate_entries(schema)
    if errors:
        for e in errors:
            print(f"FAIL {e}")
        return 1
    rows = _all_entries(schema)
    by_st: dict[str, int] = {}
    for _, r in rows:
        st = str(r.get("proof_status", "?"))
        by_st[st] = by_st.get(st, 0) + 1
    print("proof-db verify-slice: schema OK")
    print(f"  entries: {len(rows)}")
    print(f"  by proof_status: {dict(sorted(by_st.items()))}")
    print(f"  HEAD: {_git_head()}")
    print("  evidence: stub (use --run-evidence when wired)")
    return 0


def main() -> int:
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="command", required=True)
    pl = sub.add_parser("list")
    pl.add_argument("--gap")
    pl.add_argument("--status")
    pl.add_argument("--field")
    pl.add_argument("--kind", choices=sorted(KINDS))
    pl.set_defaults(func=cmd_list)
    pa = sub.add_parser("add-entry")
    pa.add_argument("--kind", required=True, choices=sorted(KINDS))
    pa.add_argument("--id", required=True)
    pa.add_argument("--field", required=True)
    pa.add_argument("--status", required=True, dest="status")
    pa.add_argument("--statement", required=True)
    pa.add_argument("--lean-module", required=True, dest="lean_module")
    pa.add_argument("--li-specimen", default="")
    pa.add_argument("--lean-thm", default="")
    pa.add_argument("--gap-id", default="")
    pa.add_argument("--backlog-id", default="")
    pa.add_argument("--evidence", action="append", default=[])
    pa.add_argument("--last-verified", default="")
    pa.add_argument("--force", action="store_true")
    pa.set_defaults(func=cmd_add_entry)
    pv = sub.add_parser("verify-slice")
    pv.add_argument("--run-evidence", action="store_true")
    pv.set_defaults(func=cmd_verify_slice)
    args = p.parse_args()
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
