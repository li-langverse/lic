#!/usr/bin/env bash
# Status of all goal-directed plan loop systemd units.
set -euo pipefail
for unit in li-sim-algo-plan-loop li-httpd-plan-loop li-compiler-studio-plan-loop li-studio-ui-ux-plan-loop; do
  echo "=== $unit ==="
  systemctl --user is-active "$unit.service" 2>/dev/null || echo "inactive/missing"
  systemctl --user show "$unit.service" -p ActiveState,SubState,MainPID --no-pager 2>/dev/null || true
  echo ""
done
if command -v loginctl >/dev/null 2>&1; then
  echo "Linger: $(loginctl show-user "$(whoami)" -p Linger --value 2>/dev/null || echo '?')"
fi
