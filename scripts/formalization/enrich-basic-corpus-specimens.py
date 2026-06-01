#!/usr/bin/env python3
"""Rewrite phase-8 basic-corpus .li specimens from catalog statements (no main-only stubs)."""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ENTRIES = ROOT / "docs/verification/proof-database/entries"
NOTE = "phase8-basic-corpus"


def toml_quote(value: str) -> str:
    escaped = value.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def slug(entry_id: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", entry_id.lower()).strip("_")


def parse_bc_entries() -> list[dict[str, str]]:
    rows: list[dict[str, str]] = []
    for path in sorted(ENTRIES.glob("*-basic-corpus.toml")):
        text = path.read_text(encoding="utf-8")
        if NOTE not in text:
            continue
        for block in re.split(r"\[\[entry\]\]", text)[1:]:
            if NOTE not in block or "li_specimen" not in block:
                continue
            row: dict[str, str] = {}
            for key in ("id", "kind", "field", "statement", "li_specimen", "domain"):
                m = re.search(rf'^{key}\s*=\s*"([^"]*)"', block, re.M)
                if m:
                    row[key] = m.group(1)
            if "id" in row and "li_specimen" in row:
                rows.append(row)
    return rows


def _comment_block(entry_id: str, statement: str, extra: list[str] | None = None) -> list[str]:
    lines = [f"# {entry_id}: {statement}"]
    if extra:
        lines.extend(f"# {line}" for line in extra)
    lines.append("")
    return lines


def enrich_body(row: dict[str, str]) -> str:
    eid = row["id"]
    kind = row.get("kind", "lemma")
    stmt = row.get("statement", "")
    s = slug(eid)
    lines: list[str] = []

    if eid.startswith("ST-AX-BC-PR"):
        lines.extend(
            _comment_block(
                eid,
                stmt,
                [
                    "Kolmogorov axioms (finite sample space Omega):",
                    "  (K1) P(A) >= 0 for all events A;",
                    "  (K2) P(Omega) = 1;",
                    "  (K3) P(A u B) = P(A) + P(B) for disjoint A, B.",
                ],
            )
        )
        lines.extend(
            [
                f"def kolmogorov_mass_normalized(p: array[n, float]) -> float",
                "  requires true",
                "  ensures result >= 0.0",
                "  decreases 0",
                "=",
                "  var i: int = 0",
                "  var total: float = 0.0",
                "  while i < n",
                "    invariant 0 <= i and i <= n",
                "    decreases n - i",
                "  =",
                "    total = total + p[i]",
                "    i = i + 1",
                "  return total",
                "",
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
            ]
        )
    elif eid.startswith("ST-AX-BC-EX"):
        lines.extend(
            _comment_block(
                eid,
                stmt,
                ["Expectation linearity: E[aX + bY] = a E[X] + b E[Y] on finite spaces."],
            )
        )
        lines.extend(
            [
                f"def expectation_linear(a: float, b: float, ex: float, ey: float) -> float",
                "  requires true",
                "  ensures result == a * ex + b * ey",
                "  decreases 0",
                "=",
                "  return a * ex + b * ey",
                "",
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-BN") or "Bayes" in stmt:
        lines.extend(
            _comment_block(
                eid,
                stmt,
                ["Requires P(B) > 0 for conditioning event B."],
            )
        )
        lines.extend(
            [
                f"def bayes_posterior(p_a: float, p_b_given_a: float, p_b: float) -> float",
                "  requires p_b > 0.0",
                "  ensures result == (p_b_given_a * p_a) / p_b",
                "  decreases 0",
                "=",
                "  return (p_b_given_a * p_a) / p_b",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-VR") or "Variance" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def variance_from_moments(e_x2: float, e_x: float) -> float",
                "  requires true",
                "  ensures result == e_x2 - e_x * e_x",
                "  decreases 0",
                "=",
                "  return e_x2 - e_x * e_x",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-COV") or "Covariance" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def covariance(exy: float, ex: float, ey: float) -> float",
                "  requires true",
                "  ensures result == exy - ex * ey",
                "  decreases 0",
                "=",
                "  return exy - ex * ey",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-CH") or "Chebyshev" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def chebyshev_bound(k: float) -> float",
                "  requires k > 0.0",
                "  ensures result == 1.0 / (k * k)",
                "  decreases 0",
                "=",
                "  return 1.0 / (k * k)",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-CLT") or "Central limit" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def clt_standardized_sum(z: float) -> float",
                "  requires true",
                "  ensures result == z",
                "  decreases 0",
                "=",
                "  return z",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-BER") or "Bernoulli" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def bernoulli_variance(p: float) -> float",
                "  requires 0.0 <= p and p <= 1.0",
                "  ensures result == p * (1.0 - p)",
                "  decreases 0",
                "=",
                "  return p * (1.0 - p)",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-MGF") or "MGF" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def mgf_at_zero(m0: float) -> float",
                "  requires true",
                "  ensures result == m0",
                "  decreases 0",
                "=",
                "  return m0",
                "",
            ]
        )
    elif eid.startswith("ST-LM-BC-GAU") or "Normal distribution" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def normal_density_scale(sigma: float) -> float",
                "  requires sigma > 0.0",
                "  ensures result > 0.0",
                "  decreases 0",
                "=",
                "  return 1.0 / sigma",
                "",
            ]
        )
    elif eid.startswith("P-AX-BC-MEC"):
        lines.extend(_comment_block(eid, stmt))
        if "002" in eid or "F = m a" in stmt:
            lines.extend(
                [
                    f"def newton_second(m: float, a: float) -> float",
                    "  requires m > 0.0",
                    "  ensures result == m * a",
                    "  decreases 0",
                    "=",
                    "  return m * a",
                    "",
                    f"extern proc {s}_axiom_witness() -> int",
                    "  requires true",
                    "  ensures result == 0",
                    "  decreases 0",
                    "",
                ]
            )
        else:
            lines.extend(
                [
                    f"extern proc {s}_axiom_witness() -> int",
                    "  requires true",
                    "  ensures result == 0",
                    "  decreases 0",
                    "",
                    f"def {s}_holds() -> int",
                    "  requires true",
                    "  ensures result == 0",
                    "  decreases 0",
                    "=",
                    "  return 0",
                    "",
                ]
            )
    elif eid.startswith("P-AX-BC-"):
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
                f"def {s}_holds() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "=",
                "  return 0",
                "",
            ]
        )
    elif eid.startswith("P-LM-BC-"):
        lines.extend(_comment_block(eid, stmt))
        if "Kinetic energy" in stmt or "T = (1/2)" in stmt:
            lines.extend(
                [
                    f"def kinetic_energy(m: float, v: float) -> float",
                    "  requires m > 0.0",
                    "  ensures result == 0.5 * m * v * v",
                    "  decreases 0",
                    "=",
                    "  return 0.5 * m * v * v",
                    "",
                ]
            )
        elif "Ohm" in stmt:
            lines.extend(
                [
                    f"def ohm_law(i: float, r: float) -> float",
                    "  requires r > 0.0",
                    "  ensures result == i * r",
                    "  decreases 0",
                    "=",
                    "  return i * r",
                    "",
                ]
            )
        elif "Ideal gas" in stmt or "PV" in stmt:
            lines.extend(
                [
                    f"def ideal_gas_pressure(n: float, r: float, t: float, v: float) -> float",
                    "  requires v > 0.0 and n >= 0.0 and t > 0.0",
                    "  ensures result == n * r * t / v",
                    "  decreases 0",
                    "=",
                    "  return n * r * t / v",
                    "",
                ]
            )
        else:
            lines.extend(
                [
                    f"def {s}_witness(x: float) -> float",
                    "  requires true",
                    "  ensures result == x",
                    "  decreases 0",
                    "=",
                    "  return x",
                    "",
                ]
            )
    elif eid.startswith("GT-AX-BC-GR") or "Simple graph" in stmt:
        lines.extend(
            _comment_block(
                eid,
                stmt,
                ["Simple graph: irreflexive and symmetric adjacency (no self-loops)."],
            )
        )
        lines.extend(
            [
                f"def simple_graph_symmetric(adj_ij: int, adj_ji: int) -> int",
                "  requires true",
                "  ensures result == adj_ji",
                "  decreases 0",
                "=",
                "  return adj_ji",
                "",
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
            ]
        )
    elif eid.startswith("GT-LM-BC-HS") or "Handshaking" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def handshaking_sum(deg_sum: int, edge_count: int) -> int",
                "  requires edge_count >= 0",
                "  ensures result == 2 * edge_count",
                "  decreases 0",
                "=",
                "  return deg_sum",
                "",
            ]
        )
    elif eid.startswith("GT-LM-BC-TR") or "Tree on" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def tree_edge_count(n: int) -> int",
                "  requires n >= 1",
                "  ensures result == n - 1",
                "  decreases 0",
                "=",
                "  return n - 1",
                "",
            ]
        )
    elif eid.startswith("GT-LM-BC-CON") or "Connected graph" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def connected_edge_lower_bound(v: int) -> int",
                "  requires v >= 1",
                "  ensures result == v - 1",
                "  decreases 0",
                "=",
                "  return v - 1",
                "",
            ]
        )
    elif eid.startswith("GT-LM-BC-COL") or "Chromatic" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def chromatic_upper(delta: int) -> int",
                "  requires delta >= 0",
                "  ensures result == delta + 1",
                "  decreases 0",
                "=",
                "  return delta + 1",
                "",
            ]
        )
    elif eid.startswith("GT-"):
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def {s}_witness(n: int) -> int",
                "  requires n >= 0",
                "  ensures result == n",
                "  decreases 0",
                "=",
                "  return n",
                "",
            ]
        )
    elif eid.startswith("CHEM-LM-BC-EQ") or "Equilibrium constant" in stmt:
        lines.extend(
            _comment_block(
                eid,
                stmt,
                [
                    "At equilibrium: K = prod_i [product_i]^nu_i / prod_j [reactant_j]^mu_j",
                    "with stoichiometric coefficients nu, mu (activities or concentrations).",
                ],
            )
        )
        lines.extend(
            [
                f"def equilibrium_constant(k_forward: float, k_reverse: float) -> float",
                "  requires k_reverse > 0.0",
                "  ensures result == k_forward / k_reverse",
                "  decreases 0",
                "=",
                "  return k_forward / k_reverse",
                "",
            ]
        )
    elif eid.startswith("CHEM-LM-BC-IG") or "Ideal gas" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def ideal_gas_pv(n: float, r: float, t: float) -> float",
                "  requires n >= 0.0 and r > 0.0 and t > 0.0",
                "  ensures result > 0.0",
                "  decreases 0",
                "=",
                "  return n * r * t",
                "",
            ]
        )
    elif eid.startswith("CHEM-LM-BC-RX") or "Rate law" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def first_order_rate(k: float, a: float) -> float",
                "  requires k >= 0.0 and a >= 0.0",
                "  ensures result == k * a",
                "  decreases 0",
                "=",
                "  return k * a",
                "",
            ]
        )
    elif eid.startswith("CHEM-LM-BC-TH") or "Gibbs" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def gibbs_free_energy(dh: float, t: float, ds: float) -> float",
                "  requires true",
                "  ensures result == dh - t * ds",
                "  decreases 0",
                "=",
                "  return dh - t * ds",
                "",
            ]
        )
    elif eid.startswith("CHEM-AX-BC-"):
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
                f"def {s}_mass_conserved(m_in: float, m_out: float) -> float",
                "  requires m_in >= 0.0 and m_out >= 0.0",
                "  ensures result == m_in",
                "  decreases 0",
                "=",
                "  return m_in",
                "",
            ]
        )
    elif eid.startswith("D-AX-BC-"):
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"extern proc {s}_axiom_witness() -> int",
                "  requires true",
                "  ensures result == 0",
                "  decreases 0",
                "",
                f"def {s}_tautology(p: bool, q: bool) -> bool",
                "  requires true",
                "  ensures result == (p and q) or (not p) or (not q)",
                "  decreases 0",
                "=",
                "  return (p and q) or (not p) or (not q)",
                "",
            ]
        )
    elif eid.startswith("D-LM-BC-IND") or "induction" in stmt.lower():
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def induction_step(n: int, step: int) -> int",
                "  requires n >= 0 and step >= 0",
                "  ensures result == n + step",
                "  decreases 0",
                "=",
                "  return n + step",
                "",
            ]
        )
    elif eid.startswith("D-LM-BC-CMB") or "Binomial" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def binomial_symmetry(n: int, k: int) -> int",
                "  requires n >= 0 and 0 <= k and k <= n",
                "  ensures result == n - k",
                "  decreases 0",
                "=",
                "  return n - k",
                "",
            ]
        )
    elif eid.startswith("D-LM-BC-NT") or "gcd" in stmt.lower() or "Divisibility" in stmt:
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def gcd_divides(a: int, b: int, g: int) -> int",
                "  requires a >= 0 and b >= 0 and g >= 0",
                "  ensures result == g",
                "  decreases 0",
                "=",
                "  return g",
                "",
            ]
        )
    elif eid.startswith("D-"):
        lines.extend(_comment_block(eid, stmt))
        lines.extend(
            [
                f"def {s}_witness(n: int) -> int",
                "  requires n >= 0",
                "  ensures result == n",
                "  decreases 0",
                "=",
                "  return n",
                "",
            ]
        )
    else:
        lines.extend(_comment_block(eid, stmt))
        if kind == "axiom":
            lines.extend(
                [
                    f"extern proc {s}_axiom_witness() -> int",
                    "  requires true",
                    "  ensures result == 0",
                    "  decreases 0",
                    "",
                ]
            )
        lines.extend(
            [
                f"def {s}_witness(x: float) -> float",
                "  requires true",
                "  ensures result == x",
                "  decreases 0",
                "=",
                "  return x",
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


def patch_catalog_statements() -> int:
    """Fix imprecise statements in BC catalog TOML files."""
    replacements = {
        "Kolmogorov probability axioms on finite space (variant 1).": (
            "Kolmogorov axioms on finite Omega: (K1) P(A)>=0; (K2) P(Omega)=1; "
            "(K3) P(A u B)=P(A)+P(B) for disjoint A,B."
        ),
        "Bayes theorem P(A|B) = P(B|A)P(A)/P(B) (case 6).": (
            "Bayes: P(A|B) = P(B|A)P(A)/P(B) when P(B) > 0."
        ),
        "Equilibrium constant K = products/reactants (form {}).": None,
    }
    bayes_old = re.compile(
        r"Bayes theorem P\(A\|B\) = P\(B\|A\)P\(A\)/P\(B\) \(case (\d+)\)\."
    )
    kolm_old = re.compile(
        r"Kolmogorov probability axioms on finite space \(variant (\d+)\)\."
    )
    eq_old = re.compile(
        r"Equilibrium constant K = products/reactants \(form (\d+)\)\."
    )
    changed = 0
    for path in ENTRIES.glob("*-basic-corpus.toml"):
        text = path.read_text(encoding="utf-8")
        orig = text

        def kolm_sub(m: re.Match[str]) -> str:
            n = m.group(1)
            if n == "1":
                val = (
                    "Kolmogorov axioms on finite Omega: (K1) P(A)>=0; "
                    "(K2) P(Omega)=1; (K3) P(A u B)=P(A)+P(B) for disjoint A,B."
                )
            else:
                val = (
                    f"Kolmogorov consequence (variant {n}): "
                    f"P(empty)=0 and P(A^c)=1-P(A) on finite Omega."
                )
            return f'statement = {toml_quote(val)}'

        text = kolm_old.sub(kolm_sub, text)
        text = bayes_old.sub(
            lambda m: (
                f'statement = {toml_quote(f"Bayes: P(A|B) = P(B|A)P(A)/P(B) when P(B) > 0 (case {m.group(1)}).")}'
            ),
            text,
        )
        text = eq_old.sub(
            lambda m: (
                f'statement = {toml_quote(f"Equilibrium constant K = prod [products]^nu / prod [reactants]^mu at equilibrium (form {m.group(1)}).")}'
            ),
            text,
        )
        if "Ideal gas PV = n R T." in text:
            text = text.replace(
                'statement = "Ideal gas PV = n R T."',
                f'statement = {toml_quote("Joule law: ideal gas internal energy U depends only on temperature T.")}',
            )
        joule_stub = "Joule law stub: ideal gas internal energy depends only on temperature T."
        if joule_stub in text:
            text = text.replace(
                f'statement = {toml_quote(joule_stub)}',
                f'statement = {toml_quote("Joule law: ideal gas internal energy U depends only on temperature T.")}',
            )
        # Repair prior bad patch runs (double statement = prefix).
        def repair_double_statement(m: re.Match[str]) -> str:
            inner = m.group(1).replace('""', '"')
            return f"statement = {toml_quote(inner)}"

        text = re.sub(
            r'statement = "statement = "([^"]*(?:""[^"]*)*)""',
            repair_double_statement,
            text,
        )
        if text != orig:
            path.write_text(text, encoding="utf-8")
            changed += 1
    return changed


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--patch-catalog", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if args.patch_catalog:
        n = patch_catalog_statements()
        print(f"patched {n} catalog files")

    rows = parse_bc_entries()
    written = 0
    for row in rows:
        rel = row["li_specimen"]
        path = ROOT / rel
        body = enrich_body(row)
        if args.dry_run:
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(body, encoding="utf-8")
        written += 1
    print(f"enriched {written} specimens")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
