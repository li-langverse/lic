"""Planned phase-8 basic corpus entries (~50 per field)."""

from __future__ import annotations

# Each tuple: (id, kind, field, statement, proof_status, tranche, domain?, latex?)


def _physics() -> list[dict]:
    items: list[tuple[str, str, str, str]] = [
        ("P-AX-BC-MEC-001", "axiom", "mechanics", "Newton I: zero net force implies constant velocity."),
        ("P-AX-BC-MEC-002", "axiom", "mechanics", "Newton II: F = m a for point mass in inertial frame."),
        ("P-AX-BC-MEC-003", "axiom", "mechanics", "Newton III: pairwise interaction forces sum to zero."),
        ("P-LM-BC-MEC-004", "lemma", "mechanics", "Impulse equals change of linear momentum."),
        ("P-LM-BC-MEC-005", "lemma", "mechanics", "Work-energy: W = integral F dot dx."),
        ("P-LM-BC-MEC-006", "lemma", "mechanics", "Kinetic energy T = (1/2) m v^2 for point mass."),
        ("P-AX-BC-MEC-007", "axiom", "mechanics", "Angular momentum L = r x p definition."),
        ("P-LM-BC-MEC-008", "lemma", "mechanics", "Torque equals time derivative of angular momentum."),
        ("P-LM-BC-MEC-009", "lemma", "mechanics", "Center of mass moves as if all mass were concentrated there."),
        ("P-LM-BC-MEC-010", "lemma", "mechanics", "Reduced mass for two-body central force problem."),
        ("P-AX-BC-EM-011", "axiom", "electromagnetism", "Coulomb law: F proportional to q1 q2 / r^2."),
        ("P-AX-BC-EM-012", "axiom", "electromagnetism", "Gauss law (integral form) for electric flux."),
        ("P-AX-BC-EM-013", "axiom", "electromagnetism", "Faraday law: induced EMF equals -dPhi/dt."),
        ("P-AX-BC-EM-014", "axiom", "electromagnetism", "Ampere-Maxwell law (stub integral form)."),
        ("P-LM-BC-EM-015", "lemma", "electromagnetism", "Electrostatic potential energy U = q V."),
        ("P-LM-BC-EM-016", "lemma", "electromagnetism", "Capacitor energy stored U = (1/2) C V^2."),
        ("P-LM-BC-EM-017", "lemma", "electromagnetism", "Ohm law V = I R (linear resistor stub)."),
        ("P-LM-BC-EM-018", "lemma", "electromagnetism", "Poynting vector S = E x H (stub)."),
        ("P-AX-BC-EM-019", "axiom", "electromagnetism", "Lorentz force F = q (E + v x B) stub."),
        ("P-LM-BC-EM-020", "lemma", "electromagnetism", "Wave equation from Maxwell in vacuum (stub)."),
        ("P-AX-BC-TH-021", "axiom", "thermodynamics", "Zeroth law: thermal equilibrium is transitive."),
        ("P-AX-BC-TH-022", "axiom", "thermodynamics", "First law: dU = delta Q - delta W."),
        ("P-AX-BC-TH-023", "axiom", "thermodynamics", "Second law: entropy of isolated system non-decreasing."),
        ("P-AX-BC-TH-024", "axiom", "thermodynamics", "Joule law stub: ideal gas internal energy depends only on temperature T."),
        ("P-LM-BC-TH-025", "lemma", "thermodynamics", "Carnot efficiency upper bound 1 - T_c/T_h."),
        ("P-LM-BC-TH-026", "lemma", "thermodynamics", "Equipartition: average energy (1/2) kT per quadratic dof."),
        ("P-LM-BC-TH-027", "lemma", "thermodynamics", "Heat capacity at constant volume definition C_V."),
        ("P-LM-BC-TH-028", "lemma", "thermodynamics", "Adiabatic ideal gas PV^gamma = const."),
        ("P-LM-BC-TH-029", "lemma", "thermodynamics", "Maxwell-Boltzmann speed distribution stub."),
        ("P-AX-BC-TH-030", "axiom", "thermodynamics", "Third law: entropy approaches constant as T -> 0."),
        ("P-LM-BC-WV-031", "lemma", "waves-fluids", "Harmonic oscillator omega = sqrt(k/m)."),
        ("P-LM-BC-WV-032", "lemma", "waves-fluids", "Doppler shift f' = f (1 +/- v/c) non-relativistic."),
        ("P-LM-BC-WV-033", "lemma", "waves-fluids", "Snell law n1 sin theta1 = n2 sin theta2."),
        ("P-LM-BC-WV-034", "lemma", "waves-fluids", "Bernoulli equation along streamline (stub)."),
        ("P-LM-BC-WV-035", "lemma", "waves-fluids", "Continuity equation div v = 0 incompressible."),
        ("P-LM-BC-WV-036", "lemma", "waves-fluids", "Sound speed c = sqrt(gamma R T / M) ideal gas."),
        ("P-LM-BC-WV-037", "lemma", "waves-fluids", "SHM period T = 2 pi / omega."),
        ("P-LM-BC-WV-038", "lemma", "waves-fluids", "Standing wave boundary conditions on string."),
        ("P-LM-BC-WV-039", "lemma", "waves-fluids", "Huygens principle stub for wavefront propagation."),
        ("P-LM-BC-WV-040", "lemma", "waves-fluids", "Reynolds number Re = rho v L / mu scaling."),
        ("P-LM-BC-EX-041", "lemma", "mechanics", "Kepler third law T^2 proportional to a^3."),
        ("P-LM-BC-EX-042", "lemma", "mechanics", "Escape velocity v_e = sqrt(2 G M / r)."),
        ("P-LM-BC-EX-043", "lemma", "mechanics", "Rocket equation delta v = v_e ln(m0/m)."),
        ("P-LM-BC-EX-044", "lemma", "mechanics", "Parallel axis theorem I = I_cm + M d^2."),
        ("P-LM-BC-EX-045", "lemma", "mechanics", "Small angle sin theta approx theta radians."),
        ("P-LM-BC-EX-046", "lemma", "mechanics", "Drag force linear model F = -b v stub."),
        ("P-LM-BC-EX-047", "lemma", "mechanics", "Simple pendulum period T = 2 pi sqrt(L/g) small angle."),
        ("P-LM-BC-EX-048", "lemma", "mechanics", "Buoyant force equals weight of displaced fluid."),
        ("P-LM-BC-EX-049", "lemma", "mechanics", "Stefan-Boltzmann j = sigma T^4 stub."),
        ("P-LM-BC-EX-050", "lemma", "mechanics", "Planck blackbody spectral peak Wien law stub."),
    ]
    rows: list[dict] = []
    for i, (eid, kind, domain, stmt) in enumerate(items):
        rows.append(
            {
                "id": eid,
                "kind": kind,
                "field": "physics",
                "statement": stmt,
                "proof_status": "axiomatic" if kind == "axiom" else "open",
                "tranche": 1 if i < 10 else (2 if i < 20 else 3),
                "domain": domain,
                "latex": None,
            }
        )
    return rows


def _stats_stmt(n: int, tpl_idx: int) -> tuple[str, str, str]:
    """Return (eid_prefix_pattern, kind, statement) for stats entry n (1..50)."""
    templates = [
        ("ST-AX-BC-PR-{:03d}", "axiom"),
        ("ST-AX-BC-EX-{:03d}", "axiom"),
        ("ST-LM-BC-VR-{:03d}", "lemma"),
        ("ST-LM-BC-CH-{:03d}", "lemma"),
        ("ST-LM-BC-CLT-{:03d}", "lemma"),
        ("ST-LM-BC-BN-{:03d}", "lemma"),
        ("ST-LM-BC-COV-{:03d}", "lemma"),
        ("ST-LM-BC-MGF-{:03d}", "lemma"),
        ("ST-LM-BC-BER-{:03d}", "lemma"),
        ("ST-LM-BC-GAU-{:03d}", "lemma"),
    ]
    eid_tpl, kind = templates[tpl_idx]
    eid = eid_tpl.format(n)
    if tpl_idx == 0:
        if n == 1:
            stmt = (
                "Kolmogorov axioms on finite Omega: (K1) P(A)>=0; (K2) P(Omega)=1; "
                "(K3) P(A u B)=P(A)+P(B) for disjoint A,B."
            )
        else:
            stmt = f"Kolmogorov consequence (variant {n}): P(empty)=0 and P(A^c)=1-P(A) on finite Omega."
    elif tpl_idx == 1:
        stmt = f"Expectation linearity E[aX+bY] = aE[X]+bE[Y] on finite spaces (case {n})."
    elif tpl_idx == 5:
        stmt = f"Bayes: P(A|B) = P(B|A)P(A)/P(B) when P(B) > 0 (case {n})."
    elif tpl_idx == 2:
        stmt = f"Variance Var(X) = E[X^2] - E[X]^2 (case {n})."
    elif tpl_idx == 3:
        stmt = f"Chebyshev inequality P(|X-mu|>=k sigma) <= 1/k^2 (case {n})."
    elif tpl_idx == 4:
        stmt = f"Central limit theorem statement (normalized sum, case {n})."
    elif tpl_idx == 6:
        stmt = f"Covariance Cov(X,Y) = E[XY]-E[X]E[Y] (case {n})."
    elif tpl_idx == 7:
        stmt = f"MGF moment generating function definition (case {n})."
    elif tpl_idx == 8:
        stmt = f"Bernoulli distribution mean p variance p(1-p) (case {n})."
    else:
        stmt = f"Normal distribution density stub (case {n})."
    return eid, kind, stmt


def _stats() -> list[dict]:
    rows: list[dict] = []
    for n in range(1, 51):
        tpl_idx = (n - 1) % 10
        eid, kind, stmt = _stats_stmt(n, tpl_idx)
        rows.append(
            {
                "id": eid,
                "kind": kind,
                "field": "statistics",
                "statement": stmt,
                "proof_status": "axiomatic" if kind == "axiom" else ("target" if "CLT" in eid else "open"),
                "tranche": 1 if n <= 10 else (2 if n <= 20 else 3),
                "domain": "probability",
                "latex": None,
            }
        )
    return rows


def _discrete() -> list[dict]:
    topics = [
        ("induction", "D-LM-BC-IND", "Mathematical induction principle (variant {})."),
        ("combinatorics", "D-LM-BC-CMB", "Binomial coefficient identity (variant {})."),
        ("number-theory", "D-LM-BC-NT", "Divisibility / gcd property (variant {})."),
        ("recurrence", "D-LM-BC-REC", "Linear recurrence solution stub (variant {})."),
        ("logic", "D-AX-BC-LOG", "Propositional tautology schema (variant {})."),
    ]
    rows: list[dict] = []
    for n in range(1, 51):
        topic = topics[(n - 1) % len(topics)]
        kind = "axiom" if topic[0] == "logic" and n % 5 == 0 else "lemma"
        prefix = topic[1] if kind == "lemma" else topic[1].replace("LM", "AX")
        eid = f"{prefix}-{n:03d}"
        rows.append(
            {
                "id": eid,
                "kind": kind,
                "field": "discrete",
                "statement": topic[2].format(n),
                "proof_status": "axiomatic" if kind == "axiom" else "open",
                "tranche": 1 if n <= 10 else (2 if n <= 20 else 3),
                "domain": topic[0],
                "latex": None,
            }
        )
    return rows


def _graph() -> list[dict]:
    topics = [
        ("GT-LM-BC-HS", "lemma", "Handshaking lemma: sum deg(v) = 2|E| (variant {})."),
        ("GT-LM-BC-TR", "lemma", "Tree on n vertices has n-1 edges (variant {})."),
        ("GT-LM-BC-CON", "lemma", "Connected graph |E| >= |V|-1 (variant {})."),
        ("GT-LM-BC-COL", "lemma", "Chromatic number upper bound Delta+1 (variant {})."),
        ("GT-AX-BC-GR", "axiom", "Simple graph: no loops, symmetric adjacency (variant {})."),
    ]
    rows: list[dict] = []
    for n in range(1, 51):
        tpl = topics[(n - 1) % len(topics)]
        eid = f"{tpl[0]}-{n:03d}"
        rows.append(
            {
                "id": eid,
                "kind": tpl[1],
                "field": "graph",
                "statement": tpl[2].format(n),
                "proof_status": "axiomatic" if tpl[1] == "axiom" else "open",
                "tranche": 1 if n <= 10 else (2 if n <= 20 else 3),
                "domain": "combinatorics",
                "latex": None,
            }
        )
    return rows


def _chemistry() -> list[dict]:
    topics = [
        ("CHEM-LM-BC-IG", "lemma", "Ideal gas law PV=nRT (form {})."),
        ("CHEM-LM-BC-RX", "lemma", "Rate law first order -dA/dt = k A (form {})."),
        ("CHEM-LM-BC-EQ", "lemma", "Equilibrium constant K = prod [products]^nu / prod [reactants]^mu at equilibrium (form {})."),
        ("CHEM-LM-BC-TH", "lemma", "Gibbs free energy Delta G = Delta H - T Delta S (form {})."),
        ("CHEM-AX-BC-AX", "axiom", "Conservation of mass in closed reaction (form {})."),
    ]
    rows: list[dict] = []
    for n in range(1, 51):
        tpl = topics[(n - 1) % len(topics)]
        eid = f"{tpl[0]}-{n:03d}"
        rows.append(
            {
                "id": eid,
                "kind": tpl[1],
                "field": "chemistry",
                "statement": tpl[2].format(n),
                "proof_status": "axiomatic" if tpl[1] == "axiom" else "open",
                "tranche": 1 if n <= 10 else (2 if n <= 20 else 3),
                "domain": "physical-chemistry",
                "latex": None,
            }
        )
    return rows


def _apply_destub(plan: list[dict]) -> list[dict]:
    import importlib.util
    from pathlib import Path

    lookup_path = (
        Path(__file__).resolve().parents[2]
        / "docs/verification/basic-corpus/destub_statements.py"
    )
    spec = importlib.util.spec_from_file_location("destub_statements", lookup_path)
    if spec is None or spec.loader is None:
        return plan
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    for row in plan:
        repl = mod.destub_statement(row["id"], row["statement"], row.get("domain"))
        if repl:
            row["statement"] = repl
    return plan


def build_plan() -> list[dict]:
    plan: list[dict] = []
    plan.extend(_physics())
    plan.extend(_stats())
    plan.extend(_discrete())
    plan.extend(_graph())
    plan.extend(_chemistry())
    return _apply_destub(plan)


PLAN: list[dict] = build_plan()
