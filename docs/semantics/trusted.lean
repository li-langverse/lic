-- Trusted axioms for Li (ONLY unproved surface)
-- Every symbol here must be reviewed in RFC; keep minimal.

import Init.Data.Float

namespace Li.Trusted

/-- Abstract IO monad for OS/SDL — user code proves against this interface. -/
axiom IO : Type → Type

axiom IO.bind : {α β : Type} → IO α → (α → IO β) → IO β
axiom IO.pure : {α : Type} → α → IO α

/-- Present one frame; axiomatized, not implemented in Lean. -/
axiom present_frame : Unit → IO Unit

/-- Read keyboard event; axiomatized. -/
axiom poll_event : Unit → IO (Option UInt32)

/-- Abstract network monad (httpd P0 — specs/2026-05-16-li-trusted-net-rfc.md). -/
axiom Net : Type → Type

axiom Net.bind : {α β : Type} → Net α → (α → Net β) → Net β
axiom Net.pure : {α : Type} → α → Net α

/-- v1 TcpListen: bind/listen returns listen handle (Nat until Fd model). -/
axiom tcp_listen_stub : Nat → Net Nat

/-- v1 TcpConn: accept returns connection handle. -/
axiom tcp_accept_stub : Nat → Net Nat

/-- v1 TcpConn: send returns bytes written (≤ buffer length in implementation). -/
axiom tcp_send_stub : Nat → Nat → Net Nat

/-- v1 TcpConn: recv returns byte count read (0 = orderly shutdown in stub). -/
axiom tcp_recv_stub : Nat → Nat → Net Nat

/-- v1 TcpConn: close is total on valid handles. -/
axiom tcp_close_stub : Nat → Net Unit

/-- Runtime `li_rt_sqrt` (libm); model for extern seam (`std/runtime/seam.li`). -/
axiom li_rt_sqrt : Float → Float

/-- Square-root accuracy for non-negative inputs (**G-hw** / P-float `sqrt_open_bound`). -/
axiom li_rt_sqrt_square_bound (x : Float) :
    Float.abs (li_rt_sqrt x * li_rt_sqrt x - x) < 1e-12

end Li.Trusted
