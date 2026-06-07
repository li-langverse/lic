import Mathlib

namespace Li.ProofDb.Graph

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Mathlib simple-graph carrier (GT-AX-SIMPLE-GRAPH). -/
abbrev LiSimpleGraph (V : Type*) := SimpleGraph V

/-- GT-AX-SIMPLE-GRAPH: adjacency is irreflexive and symmetric. -/
axiom simple_graph_axiom (G : SimpleGraph V) :
    (∀ v, ¬ G.Adj v v) ∧ Symmetric G.Adj

/-- GT-LM-HANDSHAKING (target): sum of vertex degrees equals twice the edge count. -/
axiom gt_lm_handshaking (G : SimpleGraph V) :
    ∑ v : V, G.degree v = 2 * G.edgeFinset.card

/-- GT-LM-TREE-EDGES (open): a tree on `n` vertices has exactly `n - 1` edges. -/
axiom gt_lm_tree_edges (n : Nat) (G : SimpleGraph (Fin n)) (htree : G.IsTree) :
    G.edgeFinset.card = n - 1

end Li.ProofDb.Graph
