"""Concrete basic-corpus catalog statements (phase-8 destub lookup tables)."""

from __future__ import annotations

import re
from typing import Callable

# Exact physics / statistics stub replacements (substring match after normalize).
PHYSICS_STUB_MAP: dict[str, str] = {
    "Ampere-Maxwell law (stub integral form).": (
        "Ampere-Maxwell law: line integral of H equals enclosed conduction "
        "current plus displacement current."
    ),
    "Lorentz force F = q (E + v x B) stub.": (
        "Lorentz force: F = q (E + v x B) on charge q in electric and magnetic fields."
    ),
    "Ohm law V = I R (linear resistor stub).": (
        "Ohm law: V = I R for an ohmic conductor at fixed temperature."
    ),
    "Poynting vector S = E x H (stub).": (
        "Poynting vector S = E x H gives electromagnetic energy flux density."
    ),
    "Wave equation from Maxwell in vacuum (stub).": (
        "Vacuum Maxwell equations imply wave equation nabla^2 E = mu0 eps0 d^2E/dt^2."
    ),
    "Joule law stub: ideal gas internal energy depends only on temperature T.": (
        "Joule law: ideal gas internal energy U depends only on temperature T."
    ),
    "Maxwell-Boltzmann speed distribution stub.": (
        "Maxwell-Boltzmann speed distribution: f(v) proportional to "
        "v^2 exp(-m v^2 / (2 k T)) in ideal gas."
    ),
    "Bernoulli equation along streamline (stub).": (
        "Bernoulli equation: p + (1/2) rho v^2 + rho g h = const along a streamline "
        "(steady, inviscid flow)."
    ),
    "Huygens principle stub for wavefront propagation.": (
        "Huygens principle: each point on a wavefront is a source of secondary "
        "spherical wavelets."
    ),
    "Drag force linear model F = -b v stub.": (
        "Linear drag model: F = -b v at low Reynolds number in a viscous fluid."
    ),
    "Stefan-Boltzmann j = sigma T^4 stub.": (
        "Stefan-Boltzmann law: blackbody radiative flux j = sigma T^4."
    ),
    "Planck blackbody spectral peak Wien law stub.": (
        "Wien displacement law: blackbody spectral peak wavelength lambda_max T = b."
    ),
}

NORMAL_PDF = (
    "Normal PDF: f(x) = (1 / (sigma sqrt(2 pi))) exp(-(x - mu)^2 / (2 sigma^2))."
)

INDUCTION: list[str] = [
    "Mathematical induction: if P(0) and forall k (P(k) implies P(k+1)) then forall n P(n).",
    "Strong induction: if P(0) and forall k ((forall j <= k P(j)) implies P(k+1)) then forall n P(n).",
    "Induction on sums: 1 + 2 + ... + n = n(n+1)/2 proved by induction on n.",
    "Induction on powers: 1 + 2 + ... + 2^n = 2^(n+1) - 1.",
    "Induction on inequalities: 2^n > n for all n >= 1.",
    "Induction on divisibility: 3 divides 4^n - 1 for all n >= 1.",
    "Induction on Fibonacci: F_n <= 2^n for all n >= 0.",
    "Induction on factorial: n! >= 2^(n-1) for n >= 3.",
    "Well-ordering equivalence: every nonempty subset of N has a least element.",
    "Structural induction on finite binary trees: |nodes| = |leaves| + |internals| for full trees.",
]

BINOMIAL: list[str] = [
    "Pascal identity: C(n,k) = C(n-1,k-1) + C(n-1,k) for 1 <= k <= n-1.",
    "Binomial symmetry: C(n,k) = C(n,n-k).",
    "Row sum identity: sum_{k=0}^n C(n,k) = 2^n.",
    "Alternating row sum: sum_{k=0}^n (-1)^k C(n,k) = 0 for n > 0.",
    "Vandermonde identity: sum_{k=0}^r C(m,k) C(n,r-k) = C(m+n,r).",
    "Hockey-stick identity: sum_{i=r}^n C(i,r) = C(n+1,r+1).",
    "Square of row sum: (sum C(n,k))^2 = sum_{k=0}^n C(n,k)^2.",
    "Binomial theorem: (x+y)^n = sum_{k=0}^n C(n,k) x^k y^(n-k).",
    "Chu-Vandermonde: sum_{k} C(m,k) C(n,l-k) = C(m+n,l).",
    "Absorption identity: k C(n,k) = n C(n-1,k-1).",
]

GCD: list[str] = [
    "Euclidean algorithm: gcd(a,b) = gcd(b, a mod b) for b != 0.",
    "Bezout identity: exists x,y with gcd(a,b) = a x + b y.",
    "gcd-lcm relation: gcd(a,b) * lcm(a,b) = |a b| for integers a,b.",
    "Common divisor: if d|a and d|b then d|gcd(a,b).",
    "Coprimality: gcd(a,b)=1 iff a and b share no prime factor.",
    "gcd with product: if gcd(a,b)=1 then gcd(a,bc)=gcd(a,c).",
    "Division property: if a|bc and gcd(a,b)=1 then a|c.",
    "Euclid lemma: if p prime and p|ab then p|a or p|b.",
    "gcd is associative: gcd(gcd(a,b),c) = gcd(a,gcd(b,c)).",
    "Relative primality: gcd(a,b)=1 implies gcd(a^n,b)=1 for n >= 1.",
]

RECURRENCE: list[str] = [
    "Fibonacci recurrence: F_n = F_{n-1} + F_{n-2} with F_0=0, F_1=1.",
    "Geometric sequence: a_n = r a_{n-1} has closed form a_n = a_0 r^n.",
    "Arithmetic sequence: a_n = a_{n-1} + d has closed form a_n = a_0 + n d.",
    "Towers of Hanoi: T(n) = 2 T(n-1) + 1 with T(1)=1, so T(n)=2^n - 1.",
    "Linear recurrence order 2: a_n = c1 a_{n-1} + c2 a_{n-2} solved via characteristic roots.",
    "Catalan numbers: C_n = sum_{i=0}^{n-1} C_i C_{n-1-i} with C_0=1.",
    "Factorial recurrence: n! = n (n-1)! with 0!=1.",
    "Derangements: D_n = (n-1)(D_{n-1} + D_{n-2}) with D_0=1, D_1=0.",
    "Lucas sequence: L_n = L_{n-1} + L_{n-2} with L_0=2, L_1=1.",
    "Divide-and-conquer recurrence T(n)=2T(n/2)+n has solution T(n)=O(n log n).",
]

LOGIC: list[str] = [
    "Excluded middle: P or not P (propositional tautology).",
    "Identity: P implies P.",
    "Modus ponens schema: (P and (P implies Q)) implies Q.",
    "Contrapositive: (P implies Q) equivalent to (not Q implies not P).",
    "De Morgan: not (P and Q) equivalent to (not P or not Q).",
    "Disjunctive syllogism: (P or Q) and (not P) implies Q.",
    "Hypothetical syllogism: (P implies Q) and (Q implies R) implies (P implies R).",
    "Material implication: (P implies Q) equivalent to (not P or Q).",
    "Double negation: not (not P) equivalent to P.",
    "Resolution schema: (P or R) and (not P or Q) implies (Q or R).",
]

HANDSHAKING: list[str] = [
    "Handshaking lemma: sum_{v in V} deg(v) = 2|E| in any finite graph.",
    "Corollary: every graph has an even number of odd-degree vertices.",
    "Average degree: 2|E|/|V| equals average vertex degree.",
    "Regular graph: if every vertex has degree d then 2|E| = d|V|.",
    "Bipartite handshaking: sum of degrees in each part equals |E|.",
    "Loop-free simple graph: sum of degrees is twice the edge count.",
    "Degree sequence necessary condition: sum of degrees is even.",
    "Minimum edges for given degree sum: |E| >= (sum deg)/2.",
    "Forest handshaking: same as general graph, 2|E| = sum deg(v).",
    "Multigraph: counting edge incidences gives sum deg(v) = 2|E|.",
]

TREE: list[str] = [
    "Tree on n vertices has exactly n-1 edges.",
    "Connected acyclic graph on n vertices has n-1 edges.",
    "Adding one edge to a tree creates exactly one cycle.",
    "Removing any edge from a tree disconnects the graph.",
    "Every tree with n >= 2 has at least two leaves.",
    "Unique simple path between any two vertices in a tree.",
    "Tree edge count: |E| = |V| - 1 for connected acyclic graphs.",
    "Forest on n vertices with c components has n-c edges.",
    "Spanning tree of connected graph has |V|-1 edges.",
    "Cayley count: there are n^(n-2) labeled trees on n vertices.",
]

CONNECTED: list[str] = [
    "Connected graph on n vertices has at least n-1 edges.",
    "If |E| > |V|-1 then a graph contains a cycle.",
    "Tree characterization: connected and |E| = |V|-1.",
    "Minimal connected spanning subgraph has |V|-1 edges.",
    "Disconnected graph on n vertices with c components has at most |V|-c edges.",
    "Adding an edge to a connected graph preserves connectivity or creates a cycle.",
    "Connected graph diameter is finite when |V| >= 1.",
    "Bridge edge: removing it increases number of components.",
    "2-edge-connected graph has no bridges.",
    "Connected cubic graph on n vertices has 3n/2 edges.",
]

CHROMATIC: list[str] = [
    "Greedy bound: chromatic number chi(G) <= Delta(G) + 1.",
    "Brooks theorem (qualitative): chi(G) <= Delta(G) except for cliques and odd cycles.",
    "Complete graph K_n has chi(K_n) = n.",
    "Bipartite graphs satisfy chi(G) = 2 when |E| > 0.",
    "Tree chi: every tree with edges has chi = 2.",
    "Cycle C_n: chi(C_n) = 2 if n even, 3 if n odd.",
    "Clique lower bound: chi(G) >= omega(G) (clique number).",
    "Edge chromatic number chi'(G) >= Delta(G) (Vizing lower bound).",
    "Planar graph chi <= 4 (four color theorem statement).",
    "Greedy coloring uses at most Delta+1 colors in some vertex order.",
]

SIMPLE_GRAPH: list[str] = [
    "Simple graph: no self-loops; adjacency matrix is symmetric with zero diagonal.",
    "Simple graph edge count at most n(n-1)/2 on n vertices.",
    "Adjacency symmetry: A[i,j] = A[j,i] for simple undirected graphs.",
    "No parallel edges: at most one edge between distinct vertices.",
    "Simple graph complement also has no loops.",
    "Degree of vertex v equals number of neighbors in simple graph.",
    "Simple graph isomorphism preserves degree sequence.",
    "Complete simple graph K_n has n(n-1)/2 edges.",
    "Empty simple graph on n vertices has 0 edges.",
    "Path graph P_n is simple with n-1 edges and max degree 2 (except endpoints).",
]

KOLMOGOROV_AXIOMS = (
    "Kolmogorov axioms on finite Omega: (K1) P(A)>=0; (K2) P(Omega)=1; "
    "(K3) P(A u B)=P(A)+P(B) for disjoint A,B."
)

KOLMOGOROV_CONSEQUENCE: list[str] = [
    "Probability consequence: P(empty)=0 and P(A^c)=1-P(A) on finite Omega.",
    "Monotonicity: if A subset B then P(A) <= P(B).",
    "Boole inequality (finite): P(A union B) <= P(A)+P(B).",
    "Union bound: P(union_i A_i) <= sum_i P(A_i) for finitely many events.",
    "Inclusion-exclusion (two events): P(A union B)=P(A)+P(B)-P(A intersect B).",
    "Complement rule: P(A^c)=1-P(A) when P(Omega)=1.",
    "Non-negativity: P(A) >= 0 for all events A.",
    "Certain event: P(Omega)=1.",
    "Disjoint additivity: P(A u B)=P(A)+P(B) when A and B disjoint.",
    "Difference rule: P(A \\ B)=P(A)-P(B) when B subset A.",
]

DISCRETE_FAMILIES: dict[str, list[str]] = {
    "induction": INDUCTION,
    "combinatorics": BINOMIAL,
    "number-theory": GCD,
    "recurrence": RECURRENCE,
    "logic": LOGIC,
}

GRAPH_FAMILIES: dict[str, list[str]] = {
    "handshaking": HANDSHAKING,
    "tree": TREE,
    "connected": CONNECTED,
    "chromatic": CHROMATIC,
    "simple-graph": SIMPLE_GRAPH,
}

# Map entry-id middle token to graph family key.
GRAPH_ID_FAMILY: dict[str, str] = {
    "HS": "handshaking",
    "TR": "tree",
    "CON": "connected",
    "COL": "chromatic",
    "GR": "simple-graph",
}

DISCRETE_ID_FAMILY: dict[str, str] = {
    "IND": "induction",
    "CMB": "combinatorics",
    "NT": "number-theory",
    "REC": "recurrence",
    "LOG": "logic",
}


def entry_index(entry_id: str) -> int:
    m = re.search(r"-(\d{3})$", entry_id)
    if not m:
        raise ValueError(f"cannot parse index from {entry_id!r}")
    return int(m.group(1))


def family_slot(entry_id: str) -> int:
    return (entry_index(entry_id) - 1) // 5


def graph_family_key(entry_id: str) -> str | None:
    m = re.search(r"-BC-([A-Z]+)-", entry_id)
    if not m:
        return None
    return GRAPH_ID_FAMILY.get(m.group(1))


def discrete_family_key(entry_id: str) -> str | None:
    m = re.search(r"-BC-([A-Z]+)-", entry_id)
    if not m:
        return None
    return DISCRETE_ID_FAMILY.get(m.group(1))


def destub_statement(entry_id: str, statement: str, domain: str | None = None) -> str | None:
    """Return replacement statement, or None if unchanged."""
    if "stub" in statement.lower():
        for old, new in PHYSICS_STUB_MAP.items():
            if old in statement or statement.strip() == old:
                return new
        if "Normal distribution density stub" in statement:
            return NORMAL_PDF

    if re.search(r"\(variant \d+\)", statement):
        slot = family_slot(entry_id)
        if "Kolmogorov probability axioms on finite space" in statement:
            if entry_index(entry_id) == 1:
                return KOLMOGOROV_AXIOMS
            return KOLMOGOROV_CONSEQUENCE[slot % len(KOLMOGOROV_CONSEQUENCE)]
        if entry_id.startswith(("D-LM-BC-", "D-AX-BC-")):
            fam = discrete_family_key(entry_id)
            if fam and fam in DISCRETE_FAMILIES:
                pool = DISCRETE_FAMILIES[fam]
                return pool[slot % len(pool)]
        if entry_id.startswith(("GT-LM-BC-", "GT-AX-BC-")):
            fam = graph_family_key(entry_id)
            if fam and fam in GRAPH_FAMILIES:
                pool = GRAPH_FAMILIES[fam]
                return pool[slot % len(pool)]
        if "Kolmogorov consequence" in statement:
            return KOLMOGOROV_CONSEQUENCE[slot % len(KOLMOGOROV_CONSEQUENCE)]

    # Generic family labels without variant number but still placeholders.
    placeholders: list[tuple[str, Callable[[], str | None]]] = [
        ("Mathematical induction principle", lambda: DISCRETE_FAMILIES["induction"][family_slot(entry_id)]),
        ("Binomial coefficient identity", lambda: DISCRETE_FAMILIES["combinatorics"][family_slot(entry_id)]),
        ("Divisibility / gcd property", lambda: DISCRETE_FAMILIES["number-theory"][family_slot(entry_id)]),
        ("Linear recurrence solution", lambda: DISCRETE_FAMILIES["recurrence"][family_slot(entry_id)]),
        ("Propositional tautology schema", lambda: DISCRETE_FAMILIES["logic"][family_slot(entry_id)]),
        ("Handshaking lemma:", lambda: GRAPH_FAMILIES["handshaking"][family_slot(entry_id)]),
        ("Tree on n vertices", lambda: GRAPH_FAMILIES["tree"][family_slot(entry_id)]),
        ("Connected graph |E|", lambda: GRAPH_FAMILIES["connected"][family_slot(entry_id)]),
        ("Chromatic number upper bound", lambda: GRAPH_FAMILIES["chromatic"][family_slot(entry_id)]),
        ("Simple graph: no loops", lambda: GRAPH_FAMILIES["simple-graph"][family_slot(entry_id)]),
    ]
    for prefix, resolver in placeholders:
        if statement.startswith(prefix) and "(variant" in statement:
            return resolver()


    cross_field: dict[str, str] = {
        "Protein folding energy landscape: native state minimizes effective free energy (modeling stub).": (
            "Protein folding energy landscape: native conformation R* minimizes effective free energy "
            "E(R) over admissible conformations R."
        ),
        "Pairwise alignment score is additive over matched columns under substitution matrix S (modeling stub).": (
            "Pairwise alignment score Score(A,B) = sum_i S(a_i, b_i) over matched columns with "
            "substitution matrix S."
        ),
        "Hartree-Fock: variational ground-state energy under single-determinant ansatz (modeling stub).": (
            "Hartree-Fock variational principle: E_HF = min_{psi in SD} <psi|H|psi> over single-determinant "
            "ansatz psi."
        ),
        "SCF energy functional E_k at iteration k is well-defined on the HF/DFT ansatz (modeling stub).": (
            "SCF energy functional E_k = <psi_k|F(psi_k)|psi_k> is well-defined at Hartree-Fock/DFT "
            "iteration k."
        ),
        "Newton II: net force equals mass times acceleration (scalar stub).": (
            "Newton II: net force F_net equals mass m times acceleration a (F_net = m a)."
        ),
    }
    if statement in cross_field:
        return cross_field[statement]

    return None
