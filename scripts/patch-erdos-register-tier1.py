#!/usr/bin/env python3
"""One-shot patch: fix mis-keyed Erdős rows and append Tier-1 open problems."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTER = ROOT / "proof-db/erdos/register.json"

# Canonical fixes keyed by Erdős problem number (erdosproblems.com, 2026-05-31).
FIXES: dict[int, dict] = {
    4: {
        "statement": (
            "For any C>0, are there infinitely many n with "
            "p_{n+1}-p_n > C (log log n log log log log n / (log log log n)^2) log n?"
        ),
        "tags": ["number_theory", "primes", "prime_gaps"],
        "priority_tier": "P1",
        "erdos_status": "proved",
        "external_url": "https://www.erdosproblems.com/4",
        "notes": "Proved by Maynard (2016) and Ford–Green–Konyagin–Tao (2016).",
    },
    16: {
        "statement": (
            "Is the set of odd integers not of the form 2^k+p the union of an infinite "
            "arithmetic progression and a set of density 0?"
        ),
        "tags": ["number_theory", "additive_combinatorics"],
        "priority_tier": "P2",
        "erdos_status": "proved",
        "external_url": "https://www.erdosproblems.com/16",
        "notes": "Disproved by Chen (2023).",
    },
    18: {
        "statement": (
            "We call m practical if every integer 1<=n<=m is a sum of distinct divisors of m. "
            "Does the density of practical numbers tend to 0?"
        ),
        "tags": ["number_theory", "divisors"],
        "priority_tier": "P2",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/18",
    },
    61: {
        "statement": (
            "For any graph H, is there c=c(H)>0 such that every n-vertex H-free graph "
            "contains a clique or independent set on at least n^c vertices (Erdős–Hajnal)?"
        ),
        "tags": ["graph_theory", "extremal"],
        "priority_tier": "P0",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/61",
    },
    90: {
        "statement": (
            "Does every set of n distinct points in R^2 contain at most n^{1+O(1/log log n)} "
            "pairs at unit distance (unit distance problem)?"
        ),
        "tags": ["discrete_geometry", "combinatorics"],
        "priority_tier": "P0",
        "erdos_status": "proved",
        "external_url": "https://www.erdosproblems.com/90",
        "notes": (
            "Upper-bound conjecture disproved (OpenAI counterexample, May 2026); "
            "record as settled negative result."
        ),
    },
}

NEW_ROWS: list[dict] = [
    {
        "number": 3,
        "statement": (
            "If A subset N has sum_{n in A} 1/n = infinity, must A contain arbitrarily "
            "long arithmetic progressions?"
        ),
        "tags": ["number_theory", "additive_combinatorics", "arithmetic_progressions"],
        "priority_tier": "P0",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/3",
        "notes": "Bloom Top 10; $5000 prize.",
    },
    {
        "number": 10,
        "statement": (
            "Does there exist a set A of positive integers with sum_{n in A} 1/n = infinity "
            "such that A contains no three-term arithmetic progression?"
        ),
        "tags": ["number_theory", "additive_combinatorics", "arithmetic_progressions"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/10",
    },
    {
        "number": 11,
        "statement": "Is every large odd integer n the sum of a squarefree number and a power of 2?",
        "tags": ["number_theory", "additive_combinatorics"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/11",
    },
    {
        "number": 20,
        "statement": (
            "Let f(n,k) be minimal such that every family of n-uniform sets of size >= f(n,k) "
            "contains a k-sunflower. Is f(n,k) < c_k^n for some constant c_k>0?"
        ),
        "tags": ["combinatorics", "sunflower"],
        "priority_tier": "P0",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/20",
        "notes": "Bloom Top 10; $1000 prize for k=3.",
    },
    {
        "number": 28,
        "statement": (
            "If A subset N is such that A+A contains all but finitely many integers, "
            "does limsup 1_A * 1_A(n) = infinity (Erdős–Turán additive bases)?"
        ),
        "tags": ["number_theory", "additive_combinatorics"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/28",
        "notes": "Bloom Top 10.",
    },
    {
        "number": 52,
        "statement": (
            "For finite A subset Z and every epsilon>0, is "
            "max(|A+A|,|AA|) >>_epsilon |A|^{2-epsilon} (integer sum-product)?"
        ),
        "tags": ["number_theory", "additive_combinatorics", "sum_product"],
        "priority_tier": "P0",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/52",
        "notes": "Bloom Top 10; real-number variant disproved May 2026; Z variant open.",
    },
    {
        "number": 77,
        "statement": (
            "If R(k) is the Ramsey number for K_k, what is the value of lim_{k->infty} R(k)^{1/k}?"
        ),
        "tags": ["combinatorics", "ramsey_theory", "graph_theory"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/77",
        "notes": "Bloom Top 10.",
    },
    {
        "number": 571,
        "statement": (
            "For any rational alpha in [1,2), does there exist a bipartite graph G with "
            "ex(n;G) asymptotic to n^alpha (Turán exponent)?"
        ),
        "tags": ["graph_theory", "extremal", "turán"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/571",
        "notes": "Bloom Top 10.",
    },
    {
        "number": 681,
        "statement": (
            "For all large n, does there exist k such that n+k is composite and "
            "p(n+k) > k^2, where p(m) is the least prime factor of m?"
        ),
        "tags": ["number_theory", "primes"],
        "priority_tier": "P2",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/681",
    },
    {
        "number": 713,
        "statement": (
            "For every bipartite graph G, does there exist alpha in [1,2) and c>0 with "
            "ex(n;G) ~ c n^alpha? Must alpha be rational?"
        ),
        "tags": ["graph_theory", "extremal", "turán"],
        "priority_tier": "P1",
        "erdos_status": "open",
        "external_url": "https://www.erdosproblems.com/713",
        "notes": "Bloom Top 10; $500 prize.",
    },
]


def main() -> None:
    data = json.loads(REGISTER.read_text(encoding="utf-8"))
    by_num = {int(row["number"]): row for row in data["problems"]}

    # Remove abc from slot 61 (not an Erdős-numbered problem); moved to math-conjectures.toml.
    if 61 in by_num and "abc conjecture" in by_num[61].get("statement", "").lower():
        pass  # overwritten by FIXES[61]

    for num, patch in FIXES.items():
        row = by_num.get(num, {"number": num})
        row.update(patch)
        by_num[num] = row

    for row in NEW_ROWS:
        num = int(row["number"])
        if num not in by_num:
            by_num[num] = row

    data["problems"] = sorted(by_num.values(), key=lambda r: int(r["number"]))
    data["updated"] = "2026-05-31"
    data["source"] = (
        "Curated from erdosproblems.com; Tier-1 patch 2026-05-31 "
        "(fixes E-4/16/18/61/90 + Bloom Top-10 adds)"
    )

    REGISTER.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {len(data['problems'])} problems to {REGISTER.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
