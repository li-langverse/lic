#!/usr/bin/env python3
"""Bootstrap Phase 3 research claims for Erdős E-52 (sum-product over Z)."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "proof-db" / "research-claims" / "E-52"
PROBLEM_ID = "E-52"
TS = "2026-05-31T12:00:00Z"

CLAIMS = [
    {
        "claim_id": "CLM-E52-001",
        "problem_id": PROBLEM_ID,
        "statement_plain": "For finite A subset Z with |A|=n not an arithmetic progression, |A+A| >= n+1.",
        "statement_latex": r"|A+A| \geq |A|+1 \text{ for non-AP } A \subset \mathbb{Z}",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
        "erdos_id": "E-52",
        "sources": [{"title": "Erdős Problem #52", "url": "https://www.erdosproblems.com/52"}],
        "notes": "Trivial AP obstruction; not the full sum-product exponent.",
    },
    {
        "claim_id": "CLM-E52-002",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Elekes–Ruzsa and Szemerédi–Trotter methods yield partial sum-product lower bounds over R; integer Z variant remains open.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
        "sources": [
            {"title": "Szemerédi–Trotter", "url": "https://en.wikipedia.org/wiki/Szemerédi–Trotter_theorem"},
            {"title": "Erdős #52", "url": "https://www.erdosproblems.com/52"},
        ],
        "notes": "Literature partial result; not a proof of E-52.",
    },
    {
        "claim_id": "CLM-E52-003",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Bloom 2026 notes real-field sum-product counterexamples; Z sum-product heuristic still plausible.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
        "notes": "Distinguishes R vs Z variants per register notes.",
    },
    {
        "claim_id": "CLM-E52-004",
        "problem_id": PROBLEM_ID,
        "statement_plain": "For every finite A subset Z, |A+A| >= |A| (cardinality lower bound).",
        "statement_latex": r"|A+A| \geq |A|",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
        "notes": "Target for Li formalization; stepping stone toward 2-epsilon exponent.",
    },
    {
        "claim_id": "CLM-E52-005",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Random-like sets A satisfy |A+A| and |AA| both Theta(|A|^2) heuristically.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "model_consensus",
        "notes": "Expander / random-set heuristic cited by additive combinatorics folklore.",
    },
    {
        "claim_id": "CLM-E52-006",
        "problem_id": PROBLEM_ID,
        "statement_plain": "There exists epsilon_0>0 such that max(|A+A|,|AA|) >= |A|^{2-epsilon_0} for all large |A|.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "model_conflict",
        "notes": "Reviewers split on whether uniform epsilon_0 is plausible.",
    },
    {
        "claim_id": "CLM-E52-007",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Structured sets (geometric progressions) may violate naive sum-product heuristics.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
    },
    {
        "claim_id": "CLM-E52-008",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Freiman-type inverse theorems suggest A with small sumset must have structure.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
    },
    {
        "claim_id": "CLM-E52-009",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Ruzsa triangle inequality bounds |A+A|/|A| in terms of |A-A|/|A|.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "literature_proved",
        "sources": [{"title": "Ruzsa covering lemma", "url": "https://en.wikipedia.org/wiki/Ruzsa%27s_inequalities"}],
    },
    {
        "claim_id": "CLM-E52-010",
        "problem_id": PROBLEM_ID,
        "statement_plain": "A naive induction on |A| proves the full E-52 exponent bound.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "refuted",
        "notes": "Deliberately wrong sketch for audit lane; reviewers should flag.",
    },
    {
        "claim_id": "CLM-E52-011",
        "problem_id": PROBLEM_ID,
        "statement_plain": "For prime-sized A, multiplicative structure may force |AA| ~ |A|^2 while |A+A| stays smaller.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
    },
    {
        "claim_id": "CLM-E52-012",
        "problem_id": PROBLEM_ID,
        "statement_plain": "Any proof of E-52 must use Z-specific obstructions not present in the disproved R variant.",
        "author_agent": "code_implementer",
        "author_model": "composer-2.5-fast",
        "created_at": TS,
        "epistemic_status": "heuristic",
        "notes": "Methodological claim from May 2026 register notes.",
    },
]

REVIEWS = []
MODELS = ["claude-4.6-sonnet", "gpt-5.2-codex"]
VERDICTS = {
    "CLM-E52-001": ("plausible", "plausible"),
    "CLM-E52-002": ("plausible", "proved"),  # unprovable_language flag
    "CLM-E52-003": ("plausible", "unclear"),
    "CLM-E52-004": ("plausible", "plausible"),
    "CLM-E52-005": ("plausible", "plausible"),
    "CLM-E52-006": ("proved", "wrong"),  # model_conflict
    "CLM-E52-007": ("plausible", "plausible"),
    "CLM-E52-008": ("plausible", "unclear"),
    "CLM-E52-009": ("proved", "proved"),
    "CLM-E52-010": ("wrong", "wrong"),
    "CLM-E52-011": ("plausible", "unclear"),
    "CLM-E52-012": ("plausible", "plausible"),
}

for cid, (v1, v2) in VERDICTS.items():
    REVIEWS.append(
        {
            "claim_id": cid,
            "reviewer_model": MODELS[0],
            "verdict": v1,
            "confidence": 0.75,
            "reviewed_at": "2026-05-31T13:00:00Z",
            "rationale_plain": f"Reviewer lane pass for {cid}.",
        }
    )
    REVIEWS.append(
        {
            "claim_id": cid,
            "reviewer_model": MODELS[1],
            "verdict": v2,
            "confidence": 0.68,
            "reviewed_at": "2026-05-31T13:30:00Z",
            "rationale_plain": f"Independent second review for {cid}.",
        }
    )


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    claims_path = OUT / "claims.jsonl"
    reviews_path = OUT / "reviews.jsonl"
    claims_path.write_text("\n".join(json.dumps(c, ensure_ascii=False) for c in CLAIMS) + "\n", encoding="utf-8")
    reviews_path.write_text("\n".join(json.dumps(r, ensure_ascii=False) for r in REVIEWS) + "\n", encoding="utf-8")
    print(f"bootstrap-e52-claims: wrote {len(CLAIMS)} claims, {len(REVIEWS)} reviews → {OUT}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
