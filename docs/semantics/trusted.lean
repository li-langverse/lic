-- Trusted axioms for Li (ONLY unproved surface)
-- Every symbol here must be reviewed in RFC; keep minimal.

import Mathlib

namespace Li.Trusted

/-- Abstract IO monad for OS/SDL — user code proves against this interface. -/
axiom IO : Type → Type

axiom IO.bind : {α β : Type} → IO α → (α → IO β) → IO β
axiom IO.pure : {α : Type} → α → IO α

/-- Present one frame; axiomatized, not implemented in Lean. -/
axiom present_frame : Unit → IO Unit

/-- Read keyboard event; axiomatized. -/
axiom poll_event : Unit → IO (Option UInt32)

/-- Abstract network monad (httpd P0 — see specs/2026-05-16-li-trusted-net-rfc.md). -/
axiom Net : Type → Type

axiom Net.bind : {α β : Type} → Net α → (α → Net β) → Net β
axiom Net.pure : {α : Type} → α → Net α

/-- Placeholder: TCP accept returns connection handle as Nat until fd model lands. -/
axiom tcp_accept_stub : Unit → Net Nat

end Li.Trusted
